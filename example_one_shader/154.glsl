//Copyright (c) 2021 Butadiene
//Released under the MIT license
//https://opensource.org/licenses/mit-license.php

float PI = acos(-1.);

vec2 pmod(vec2 p,float n){
  float np = 2.*PI/n;
  float r = atan(p.x,p.y)-0.5*np;
  r = mod(r,np)-0.5*np;
  return length(p.xy)*vec2(cos(r),sin(r));
}
mat2 rot(float r){
    vec2 s = vec2(cos(r),sin(r));
    return mat2(s.x,s.y,-s.y,s.x);
}
float cube(vec3 p,vec3 s){
    vec3 q = abs(p);
    vec3 m = max(s-q,0.);
    return length(max(q-s,0.))-min(min(m.x,m.y),m.z);
}
vec4 tetcol(vec3 p,vec3 offset,float scale,vec3 col){
    vec4 z = vec4(p,1.);
    for(int i = 0;i<20;i++){
        if(z.x+z.y<0.0)z.xy = -z.yx,col.z+=1.;
        if(z.x+z.z<0.0)z.xz = -z.zx,col.y+=1.;
        if(z.z+z.y<0.0)z.zy = -z.yz,col.x+=1.;       
        z *= scale;
        z.xyz += offset*(1.0-scale);
    }
    return vec4(col,(cube(z.xyz,vec3(1.5)))/z.w);
}

float bpm = 120.;
vec4 dist(vec3 p,float t){
    p.xy *= rot(PI);
    p.xz = pmod(p.xz,24.);
    p.x -= 5.1;
 
    p.yz *= rot(iTime*0.5);

    float s =1.;
    p.z = abs(p.z)-3.;
    p = abs(p)-s*8.;
    p = abs(p)-s*4.;
    p = abs(p)-s*2.;
    p = abs(p)-s*1.;

    vec4 sd = tetcol(p,vec3(1),1.8,vec3(0.));
    float d= sd.w;
    vec3 col = 1.-0.1*sd.xyz-0.3;
    col *= exp(-2.5*d)*2.;
    return vec4(col,d);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec2 p = (uv-0.5)*2.;
 
   
    float rsa =0.1+mod(iTime*0.0005,32.);
    float rkt = iTime*5.+0.5*PI+1.05;
    vec3 of = vec3(0,0,0);
    vec3 ro = of+vec3(rsa*cos(rkt),-1.2,rsa*sin(rkt));
    
    vec3 ta = of+vec3(1.+cos(iTime),-1.3,1.+sin(iTime));
      ro.yx *= rot(iTime*0.5);
         ro.zx *= rot(iTime*0.5);
    vec3 cdir = normalize(ta-ro);
    vec3 side = cross(cdir,vec3(0,1,0));
    vec3 up = cross(side,cdir);
    vec3 rd = normalize(p.x*side+p.y*up+0.4*cdir);
  
    float d,t= 0.;
    vec3 ac = vec3(0.);
    float ep = 0.0001;
    for(int i = 0;i<66;i++){
        vec4 rsd = dist(ro+rd*t,t);
        d = rsd.w;
        t += d;
        ac += rsd.xyz;
        if(d<ep) break;
    }

    vec3 col = vec3(0.04*ac);
 
    if(col.r<0.1&&(col.b<0.1&&col.g<0.1)) col =vec3(0.);
	fragColor = vec4(col, 1.0 );

}

