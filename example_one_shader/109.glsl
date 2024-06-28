/*originals https://www.shadertoy.com/view/7dcyRr https://www.shadertoy.com/view/DtGyWh*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(35,43,51))*.5+.5)


float PI = acos(-1.);
mat2 rot(float r){
    vec2 s = vec2(cos(r),sin(r));
    return mat2(s.x,s.y,-s.y,s.x);
}
float cube(vec3 p,vec3 s){
    vec3 q = abs(p);
    vec3 m = max(s-q,0.);
    return length(max(q-s,0.))-min(min(m.x,m.y),m.z);
}

vec4 map( in vec3 p )
{
   float d = cube(p,vec3(1.0));
vec3 col = vec3(0);
   float s = 1.0;
   float ite = 4.0;
   for( int m=0; m<4; m++ )
   {
      vec3 a = mod( p*s, 2.0 )-1.0;
      s *= 3.0;
      vec3 r = abs(1.1 - 3.0*abs(a));

      float da = max(r.x,r.y);
      float db = max(r.y,r.z);
      float dc = max(r.z,r.x);
      float k = 2.0*pow(abs(sin(0.5*iTime)),0.2);
       if(r.x<r.y)col.z+=1.2*abs((float(m)-k))/ite;
        if(r.y>r.z)col.y+=1.*abs((float(m)-k))/ite,col.z += 0.2*abs((float(m)-k))/ite;
        if(r.x>r.z)col.x+=1.2*abs((float(m)-k))/ite;
      float c = (min(da,min(db,dc))-1.0)/s;

      d = max(d,c);
   }

   return vec4(col,d);
}
#define BOXITER 5.

float cnbox(vec3 ps,float t, float k){
    ps.xy *= rot(0.25*3.14);
    ps.xz *= rot(0.25*3.14);
    ps.xy *= rot(1.*t*3.14);
    ps.xz *= rot(1.*t*3.14);
    float sc = 0.45;
    ps = abs(ps);
    vec3 pk = ps;
    if(k>1.){
        for(int i = 0;i<int(BOXITER)+1;i++){
            if(float(i)<floor(k)-1.){
            ps = abs(ps)-sc/pow(2.,4.+float(i));
            }else if(BOXITER>k){
             ps = mix(ps,abs(ps)-sc/pow(2.,4.+float(i)),clamp(k-1.-float(i),0.0,1.0));
             break;
            }else{
                 ps = mix(ps,pk,clamp(k-1.-float(i),0.0,1.0));
            }
        }
    }
    float sac = pow(2.2,k-1.);
    if(BOXITER<k)
    sac = mix(sac,1.0,pow(k-BOXITER,0.4));
    float d1 = cube(ps,sc*0.5*vec3(0.2,0.2,0.2)/sac);
    return d1;
}
float ease_in_out_cubic(float x) {
	return x < 0.5 ? 4. * x * x * x : 1. - pow(-2. * x + 2., 3.) / 2.;
}

vec4 dist(vec3 p){
    vec3 p1 = p;
    float k = 2.;
    float ksstx = clamp(3.*(fract(0.1*iTime)-2./3.),0.0,1.0);
    float kssty = clamp(3.*(fract(0.1*iTime)-1./3.),0.0,1.0);
    float ksstz = clamp(3.*fract(0.1*iTime),0.0,1.0);
    p.yz *= rot(0.015*3.14*iTime);
     p.zx *= rot(0.015*3.14*iTime);
    p.x += 4.*ease_in_out_cubic(ksstx);
    p.y += 4.*ease_in_out_cubic(kssty);
    p.z += 4.*ease_in_out_cubic(ksstz);
    p = mod(p,k)-0.5*k;
    
    
    vec4 sd = map(p);
    float d= sd.w;
    vec3 col = 0.4*sd.xyz;
    col *= exp(-2.5*d)*2.6;
    vec3 ps = p1-vec3(1.);
    float ktx = 0.3;
    float kt = fract(iTime*ktx);
    float d1 = cnbox(ps,ease_in_out_cubic(kt),1.+mod(ease_in_out_cubic(kt)+floor(iTime*ktx),BOXITER));
    return vec4(col,min(d,d1));
}

vec3 gn(vec3 p){
vec2 e = vec2(0.001,0.);
return normalize(vec3(dist(p+e.xyy).w-dist(p-e.xyy).w,
dist(p+e.yxy).w-dist(p-e.yxy).w,
dist(p+e.yyx).w-dist(p-e.yyx).w

));

}
  //https://www.shadertoy.com/view/lsKSWR
float vig(vec2 uv)
{
   float time = iTime;
   uv *=  1.0 - uv.yx;
   float vig = uv.x*uv.y;
   vig = pow(vig, 0.45);
   return vig;
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
        
         vec4 rsd = dist( natur);
         natur+=rsd.xyz;
        natur.z+=iTime*2.0;
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
                 )+rsd.xyz;
         }
       //  g+=e=length(p.yz)/s;
         g+=e=length(natur.yx)/s;
    }
}