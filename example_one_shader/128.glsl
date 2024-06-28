float PI = acos(-1.);

vec2 pmod(vec2 p,float n){
  float np = 2.*PI/n;
  float r = atan(p.x,p.y)-0.5*np;
  r = mod(r,np)-1.5*np;
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
    for(int i = 0;i<12;i++){
        if(z.x+z.y<0.0)z.xy = -z.yx,col.z+=1.;
        if(z.x+z.z<0.0)z.xz = -z.zx,col.y+=1.;
        if(z.z+z.y<0.0)z.zy = -z.yz,col.x+=10.;      
        z *= scale;
        z.xyz += offset*(1.0-scale);
    }
    return vec4(col,(cube(z.xyz,vec3(0.5)))/z.w);
}

float bpm = 128.;
vec4 dist(vec3 p,float t){
    p.xz *= rot(iTime);
    p.xz = pmod(p.xz,100.);
    p.x -= 5.1;
     
    p.xy *= rot(0.3);
    p.xz *= rot(0.25*PI);
    p.yz *= rot(PI*0.5);
    p.xy *= rot(iTime);
    float s =1.;
    p.z = abs(p.z)-1.;
    p = abs(p)-s*1./abs(iTime);
    p = abs(p)-s*1.;
    p = abs(p)-s*1.;
    p = abs(p)-s*1.;

    vec4 sd = tetcol(p,vec3(1),3.0,vec3(0.));
    float d= sd.w;
    vec3 col = 1.0-0.05*sd.xyz-0.3;
    col *= exp(-2.5*d)*1.;
    return vec4(col,d);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec2 p = (uv-0.5)*2.;
    p.y *= iResolution.y/iResolution.x;
   
    float rsa =0.1+mod(iTime*0.0,32.);
   
    float rkt = iTime*1.+0.5*PI+1.05;
    vec3 of = vec3(0,0,5);
 
    vec3 ro = of+vec3(rsa*cos(rkt),0.5,rsa*1.*sin(rkt));
   
    vec3 ta = of+vec3(0,1.3,0);
    vec3 cdir = normalize(ta-ro);
    vec3 side = cross(cdir,vec3(1,0,2));
        side.xz *= rot(iTime);
       
    vec3 up = cross(side,cdir);
    vec3 rd = normalize(p.x*side+p.y*up+0.054*cdir);

    float d,t= 0.;
    vec3 ac = vec3(0.);
    float ep = 0.0001;
    for(int i = 0;i<70;i++){
        vec4 rsd = dist(ro+rd*t,t);
        d = rsd.w;
        t += d;
        ac += rsd.xyz;
        if(d<ep) break;
    }

    vec3 col = vec3(0.04*ac);
 
    if(col.r<0.1&&(col.b<1.1&&col.g<0.1)) col =vec3(0.);
fragColor = vec4(col, 1.0 );

}


