#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

#define rot2(spin) mat2(sin(spin),cos(spin),-cos(spin),sin(spin))
#define pi acos(-1.0)

#define k 1.323
float cheap_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec2 centered = C.xy*2.0-iResolution.xy;
    vec2 uv = centered/iResolution.y;
   
    float grey = 0.0;
   
    // instead of iTime i have pi/6.0 for a static shape
    const mat2 rot = rot2(pi/6.0);
   
    // using pow for seamless "infinite" zoom
    // it loops after 3 seconds, pow makes the zoom speed
    // seamless between loops
    float scale = 1.0/pow(k,fract(-iTime/3.0)*6.0+3.0);
    // there is a full rotation every 6 seconds.
   
    uv *= scale*rot2(pi*-iTime/6.0);
    int i;
    for(i = 0; i < 40; i++) {
        uv *= k * -rot;
       
        if(uv.y > 1.0) {
            break;
        }
    }
   
    scale *= pow(k,float(i));
    grey = (uv.y-1.0)/scale*iResolution.y/3.0;

    if (mod(i, 2) == 1) {
        grey = 1.0 - grey;
    }
   
    uv /= scale;
   
    float len = dot(centered,centered);
    if (len < 20.0*20.0) {
        grey = mix(0.5,grey,sqrt(len)/20.0);
    }

    uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1

    vec3 natur,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(1),H(g*.1),.8)*1./e/8e3
    )
    {
        natur=g*d;
        natur.z+=iTime*0.0;
        a=30.;
        natur=mod(natur-a,a*2.)-a;
        s=6.;
        for(int i=0;i++<8;){
            natur=.3-abs(natur);
            natur.x<natur.z?natur=natur.zyx:natur;
            natur.z<natur.y?natur=natur.xzy:natur;
            natur.y==natur.x?natur=natur.zyx:natur;
            s*=e=1.6+sin(iTime*.1)*.1;
            natur=abs(natur)*e-
                vec3(
                    5.+sin(iTime*.3+.5*sin(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 )+grey;
         }
         g+=e=length(natur.yz)/s;
    }
    O+= vec4(cheap_star(uv, anim) * vec3(0.55,0.5,0.55)*0.2, 1.0);
}
