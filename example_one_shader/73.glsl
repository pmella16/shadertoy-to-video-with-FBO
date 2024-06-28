/* original https://www.shadertoy.com/view/lsyXDK https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/DlycWR*/
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
//get coords and direction
vec3 dir=rd;
vec3 from=ro;

//volumetric rendering
float s=0.1,fade=1.;
vec3 v=vec3(0.);
for (int r=0; r<volsteps; r++) {
vec3 p=from+s*dir*.5;
p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
float pa,a=pa=0.;
for (int i=0; i<iterations; i++) {
p=abs(p)/dot(p,p)-formuparam; // the magic formula
a+=abs(length(p)-pa); // absolute sum of average change
pa=length(p);
}
//dark matter
a*=a*a; // add contrast
if (r>6) fade*=1.2; // dark matter, don't render near
//v+=vec3(dm,dm*.5,0.);
v+=fade;
v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
fade*=distfading; // distance fading
s+=stepsize;
}
v=mix(vec3(length(v)),v,saturation); //color adjust
fragColor = vec4(v*.01,1.);
}
float cheap_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}

vec2 rotate(vec2 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
//get coords and direction
vec2 uv=fragCoord.xy/iResolution.xy-.5;
uv.y*=iResolution.y/iResolution.x;
vec3 dir=vec3(uv*zoom,1.);
float time=iTime*speed+.25;
    vec4 O =fragColor;
    vec2 C =fragCoord;
   
 O=vec4(0);
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(3),H(g*2.1),sin(2.8))*1./e/8e3
    )
    {
        p=g*d;
        p.z+=-iTime*3.5;
        a=60.;
        p=mod(p-a,a*2.)-a;
        s=5.;
          p.xy+=rotate(p.xy,-iTime/15.-length(p.xy)*1.5);
             
        for(int i=0;i++<8;){
            p=.23-abs(p);
            ;
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
     
            s*=e=1.4+sin(-iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.5*sin(iTime*.3))*2.,
                    80,
                    8.+cos(iTime*.5)*5.
                 );
         }
         g+=e=length(p.yz)/s;
    }
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5);
     
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    
vec3 from=vec3(1.,.5,0.5)+O.xyz;
from+=vec3(time*2.,time,-2.);

mainVR(fragColor, fragCoord, from, dir);
    fragColor+=O;
        fragColor*= vec4(cheap_star(uv,anim) * vec3(0.35,0.32,0.25), 1.0);
}
