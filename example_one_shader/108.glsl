/*originals https://www.shadertoy.com/view/7dcyRr https://www.shadertoy.com/view/3ltBD8 https://www.shadertoy.com/view/DtGyWh*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(35,53,31))*.5+.5)


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
    for(int i = 0;i<12;i++){
        if(z.x+z.y<0.0)z.xy = -z.yx,col.z+=1.;
        if(z.x+z.z<0.0)z.xz = -z.zx,col.y+=1.;
        if(z.z+z.y<0.0)z.zy = -z.yz,col.x+=1.;       
        z *= scale;
        z.xyz += offset*(1.0-scale);
    }
    return vec4(col,(cube(z.xyz,vec3(1.5)))/z.w);
}

float bpm = 128.;
vec4 dist(vec3 p,float t){
    p.xy *= rot(PI);
    p.xz = pmod(p.xz,24.);
    p.x -= 5.1;
    
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

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
    
    vec3 natur,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        natur=g*d;
        
         
        natur.z+=-iTime*0.0;
        a=30.;
        natur=mod(natur-a,a*2.)-a;
        s=7.;
   
        for(int i=0;i++<8;){
            natur=.3-abs(natur);
            
            natur.x<natur.z?natur=natur.zyx:natur;
            natur.z<natur.y?natur=natur.xzy:natur;
            natur.y<natur.x?natur=natur.zyx:natur;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            natur=abs(natur)*e-
                vec3(
                    7.+cos(iTime*.3+.05*cos(iTime*.3))*3.,
                    120,
                    5.+cos(iTime*.5)*5.
                 );
         }
    
         g+=e=length(natur.yx)/s;
    }
    
    
    vec2 uv = C/iResolution.xy;
        vec2 p = (uv-0.5)*2.;
    p.y *= iResolution.y/iResolution.x;
   
    float rsa =0.51+mod(iTime*0.0,32.);
    float rkt = iTime*1.+0.5*PI+1.05;
    vec3 of = vec3(0,0,0);
    vec3 ro = of+vec3(rsa*cos(rkt),-1.2,rsa*sin(rkt));
    vec3 ta = of+vec3(0,-1.0+cos(iTime*0.5),0);
    vec3 cdir = normalize(ta-ro);
    vec3 side = cross(cdir,vec3(0,1,5));
    vec3 up = cross(side,cdir);
    vec3 rd = normalize(p.x*side+p.y*up+0.4*cdir);
  
    float d2,t= 0.;
    vec3 ac = vec3(0.);
    float ep = 0.0001;
    for(int i = 0;i<100;i++){
        vec4 rsd = dist(ro+rd*t,t);
        d2 = rsd.w;
        t += d2;
        ac += rsd.xyz;
        if(d2<ep) break;
    }

    vec3 col = vec3(0.04*ac); 
    O=vec4(col,1.);
}