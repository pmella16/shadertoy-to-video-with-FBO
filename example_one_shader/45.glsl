/*original https://www.shadertoy.com/view/mtyfDK  https://www.shadertoy.com/view/DtVBRD /*original https://www.shadertoy.com/view/lslyRn,  original https://www.shadertoy.com/view/lsyXDK https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/DlycWR and other*/
/*https://www.shadertoy.com/view/Ns3cDN*/
#define iterations 13
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000

#define brightness 0.0055
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
p=abs(p)/dot(p,p)-formuparam;
            p.xy*=mat2(cos(iTime*0.02),sin(iTime*0.02),-sin(iTime*0.02),cos(iTime*0.02));// the magic formula
a+=abs(length(p)-pa); // absolute sum of average change
pa=length(p);
}
float dm=max(0.,darkmatter-a*a*.001); //dark matter
a*=a*a; // add contrast
if (r>6) fade*=1.3; // dark matter, don't render near
//v+=vec3(dm,dm*.5,0.);
v+=fade;
v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
fade*=distfading; // distance fading
s-=stepsize;
}
v=mix(vec3(length(v)),v,saturation); //color adjust
fragColor = vec4(v/4.*.030,0.);
}
float nice_lucky_lovely_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
mat2 r2d(float a) {
float c = cos(a), s = sin(a);
    return mat2(
        c, s,
        -s, c
    );
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
//get coords and direction
vec2 uv=fragCoord.xy/iResolution.xy-.5;
    vec2 uv2=fragCoord.xy/iResolution.xy-.5;
        vec2 uv3=fragCoord.xy/iResolution.xy-.5;
        vec2 uv4=fragCoord.xy/iResolution.xy-.5;
uv.y*=iResolution.y/iResolution.x;
vec3 dir=vec3(uv*zoom,1.);
float time=iTime*speed+.25;
    vec4 O=fragColor;
    vec2 C=fragCoord;
        // anim between 0.9 - 1.1
    float anim = sin(iTime * 10.0) * 0.1 + 1.0;    
O=vec4(0);
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    float ratio = iResolution.y / iResolution.x;
float divider = float(iMouse.x / iResolution.x * 10.0) + 1.0;
float intensity = float(iMouse.y / iResolution.y * 10.0) + 1.0;

float coordX = fragCoord.x / iResolution.x;
float coordY = fragCoord.y / iResolution.x;

float ball1x = sin(iTime * 2.1) * 0.5 + 0.5;
float ball1y = cos(iTime * 1.0) * 0.5 + 0.5;
float ball1z = sin(iTime * 2.0) * 0.1 + 0.2;

float ball2x = sin(iTime * 1.0) * 0.5 + 0.5;
float ball2y = cos(iTime * 1.8) * 0.5 + 0.5;
float ball2z = cos(iTime * 2.0) * 0.1 + 0.2;

float ball3x = sin(iTime * 0.7) * 0.5 + 0.5;
float ball3y = cos(iTime * 1.5) * 0.5 + 0.5;
float ball3z = cos(iTime * 1.0) * 0.1 + 0.2;

vec3 ball1 = vec3(ball1x, ball1y * ratio, ball1z);
vec3 ball2 = vec3(ball2x, ball2y * ratio, ball2z);
vec3 ball3 = vec3(ball3x, ball3y * ratio, ball3z);
uv2.xy+=ball1.xy* vec2(coordX, coordY);
uv3.xy+=ball2.xy* vec2(coordX, coordY);
uv4.xy+=ball3.xy* vec2(coordX, coordY);
float sum = 0.0;
sum += ball1.z / distance(ball1.xy, vec2(coordX, coordY));
sum += ball2.z / distance(ball2.xy, vec2(coordX, coordY));
sum += ball3.z / distance(ball3.xy, vec2(coordX, coordY));

    sum = pow(sum / intensity, divider);
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
   
    {
        p=g*d;
        p.z+=iTime*2.0;
        a=10.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
           
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            p.y<p.x?p=p.zyx:p;
           
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.05*cos(iTime*.3))*.1,
                    100,  10.+cos(iTime*.5)*5.
                 );
         }
       
         g+=e=length(p.zy)/s;
    }
float time2 = iTime;
    float rotTime = sin(time2);
   
    vec3 color1 = vec3(0.8, 0.5, 0.3);
    vec3 color2 = vec3(rotTime, 0.2, 0.3);
   


    vec3 destColor = vec3(2.0 * rotTime, .0, 0.5);
    float f = 10.15;
    float maxIt = 18.0;
    vec3 shape = vec3(0.);
    for(float i = 0.0; i < maxIt; i++){
        float s = sin((time / 111.0) + i * cos(iTime*0.02+i)*0.05+0.05);
        float c = cos((time / 411.0) + i * (sin(time*0.02+i)*0.05+0.05));
        c += sin(iTime);
        f = (.01) / abs(length(uv / vec2(c, s)) - 0.4);
        f += exp(-400.*distance(uv, vec2(c,s)*0.5))*2.;
        // Mas Particulas
        f += exp(-200.*distance(uv, vec2(c,s)*-0.5))*2.;
        // Circulito
        f += (.008) / abs(length(uv/2. / vec2(c/4. + sin(time*.6), s/4.)))*0.4;
        float idx = float(i)/ float(maxIt);
        idx = fract(idx*2.);
        vec3 colorX = mix(color1, color2,idx);
        shape += f * colorX;
       
        // todo: sacar el sin
        uv *= r2d(sin(iTime*0.2) + cos(i*50.*f+iTime)*f);
    }
   
vec3 from=vec3(1.,.5,0.5)*O.xyz;
from+=vec3(time*2.,time,-2.);


mainVR(fragColor, fragCoord, from, dir);
   
            fragColor+= vec4(nice_lucky_lovely_star(uv2,anim) * vec3(0.55,0.5,0.55)*0.07, 1.0);
             fragColor+= vec4(nice_lucky_lovely_star(uv3,anim) * vec3(0.15,0.2,0.55)*0.017, 1.0);
              fragColor+= vec4(nice_lucky_lovely_star(uv4,anim) * vec3(0.15,0.5,0.25)*0.017, 1.0);
                fragColor*= vec4(shape, 1.0);
}

