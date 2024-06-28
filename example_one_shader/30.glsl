/*originals https://www.shadertoy.com/view/McsXz8 https://www.shadertoy.com/view/XcsSDn https://www.shadertoy.com/view/lslyRn*/
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

// wireframe code from FabriceNeyret2: https://www.shadertoy.com/view/XfS3DK

#define O(x,a,b) smoothstep(0., 1., cos(x*6.2832)*.5+.5)*(a-b)+b  // oscillate between a & b
#define A(v) mat2(cos((v*3.1416) + vec4(0, -1.5708, 1.5708, 0)))  // rotate
#define s(p1, p2) c += .02/abs(L( u, K(p1, v, h), K(p2, v, h) )+.0011)*k;  // segment

// line
float L(vec2 p, vec3 A, vec3 B)
{
    vec2 a = A.xy,
         b = B.xy - a;
         p -= a;
    float h = clamp(dot(p, b) / dot(b, b), 0., 1.);
    return length(p - b*h) + .01*mix(A.z, B.z, h);
}

// cam
vec3 K(vec3 p, mat2 v, mat2 h)
{
    p.zy *= v; // pitch
    p.zx *= h; // yaw

    return p;
}
float nice_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
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
            p.xy*=mat2(cos(iTime*0.03),sin(iTime*0.03),-sin(iTime*0.03) ,cos(iTime*0.03));// the magic formula
a+=abs(length(p)-pa); // absolute sum of average change
pa=length(p);
}
float dm=max(0.,darkmatter-a*a*.001); //dark matter
a*=a*a; // add contrast
if (r>6) fade*=1.2-dm; // dark matter, don't render near
//v+=vec3(dm,dm*.5,0.);
v+=fade;
v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
fade*=distfading; // distance fading
s+=stepsize;
}
v=mix(vec3(length(v)),v,saturation); //color adjust
fragColor = vec4(v*.01,1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
//get coords and direction
vec2 uv=fragCoord.xy/iResolution.xy-.5;
uv.y*=iResolution.y/iResolution.x;
vec3 dir=vec3(uv*zoom,1.);
float time=iTime*speed+.25;
    vec4 C= fragColor;
    vec2 U =  fragCoord;
 vec2 R = iResolution.xy,
         u = (U+U-R)/R.y*2.,
         m = (iMouse.xy*2.-R)/R.y;
   
    float t = iTime/60.,
          o = t*0.,
          j = (u.x > 0.) ? 1.: -1.; // screen side
 
    if (iMouse.z < 1.) // not clicking
        m = vec2(sin(t*6.2832)*2., sin(t*6.2832*2.)); // fig-8 movement
   
    mat2 v = A(m.y), // pitch
         h = A(m.x); // yaw
   
    vec3 c = vec3(0), p,p2,
         k = vec3(2,3,3)/40. + .05;
   
   
     p2 = vec3(
            O(1.2,   1.,  .382*cos(iTime)), 
            O(-1.2, .218*cos(iTime), -.218), 
            O(.2, .2,    1.*cos(iTime)));
   
        k = k.brg; // shift color
      // stellated icosahedron
        //p = vec3(.382, -.618, 1); // dodecahedron
         p = vec3(0, O(o, .618, 1.), O(o, 1., -.618));
           p+= vec3(7.+cos(iTime), .7+cos(iTime), .7+cos(iTime)); 
        s( vec3(-p.y*p2.x,  p.z,    0), vec3(   0, -p.y, -p.z) )
        s( vec3(-p.y*p2.x,  p.z,    0), vec3(   0, -p.y,  p.z) )
        s( vec3(-p.y*p2.x,  p.z,    0), vec3( p.z,    0, -p.y) )
        s( vec3(-p.y*p2.x,  p.z,    0), vec3( p.z,    0,  p.y) )
        s( vec3( p.y*p2.x,  p.z,    0), vec3( p.y, -p.z,    0) )
        s( vec3( p.y*p2.x,  p.z,    0), vec3(   0, -p.y, -p.z) )
        s( vec3( p.y*p2.x,  p.z,    0), vec3(   0, -p.y,  p.z) )
        s( vec3( p.y*p2.x,  p.z,    0), vec3(-p.z,    0, -p.y) )
        s( vec3( p.y*p2.x,  p.z,    0), vec3(-p.z,    0,  p.y) )
        s( vec3(-p.y*p2.x, -p.z,    0), vec3(-p.y,  p.z,    0) )
        s( vec3(-p.y*p2.x, -p.z,    0), vec3(   0,  p.y, -p.z) )
        s( vec3(-p.y*p2.x, -p.z,    0), vec3(   0,  p.y,  p.z) )
        s( vec3(-p.y*p2.x, -p.z,    0), vec3( p.z,    0, -p.y) )
        s( vec3(-p.y*p2.x, -p.z,    0), vec3( p.z,    0,  p.y) )
        s( vec3( p.y*p2.x, -p.z,    0), vec3(   0,  p.y, -p.z) )
        s( vec3( p.y*p2.x, -p.z,    0), vec3(   0,  p.y,  p.z) )
        s( vec3( p.y*p2.x, -p.z,    0), vec3(-p.z,    0, -p.y) )
        s( vec3( p.y*p2.x, -p.z,    0), vec3(-p.z,    0,  p.y) )
        s( vec3(   0,  p.y*p2.x, -p.z), vec3(   0,  p.y,  p.z) )
        s( vec3(   0,  p.y*p2.x, -p.z), vec3( p.z,    0,  p.y) )
        s( vec3(   0,  p.y*p2.x, -p.z), vec3(-p.z,    0,  p.y) )
        s( vec3(   0, -p.y*p2.x, -p.z), vec3(   0, -p.y,  p.z) )
        s( vec3(   0, -p.y*p2.x, -p.z), vec3( p.z,    0,  p.y) )
        s( vec3(   0, -p.y*p2.x, -p.z), vec3(-p.z,    0,  p.y) )
        s( vec3(-p.z,    0, -p.y), vec3( p.z,    0, -p.y) )
        s( vec3(-p.z,    0,  p.y), vec3( p.z,    0,  p.y) )
        s( vec3(-p.z,    0, -p.y), vec3(   0,  p.y,  p.z) )
        s( vec3(-p.z,    0, -p.y), vec3(   0, -p.y,  p.z) )
        s( vec3( p.z,    0, -p.y), vec3(   0,  p.y,  p.z) )
        s( vec3( p.z,    0, -p.y), vec3(   0, -p.y,  p.z) )
     
        s( vec3(-p.z,  p.x,    0), vec3(-p.z, -p.x,    0) )
        s( vec3(-p.z,  p.x,    0), vec3( p.y, -p.y, -p.y) )
        s( vec3(-p.z,  p.x,    0), vec3( p.y, -p.y,  p.y) )
        s( vec3(-p.z, -p.x,    0), vec3( p.y,  p.y, -p.y) )
        s( vec3(-p.z, -p.x,    0), vec3( p.y,  p.y,  p.y) )
        s( vec3( p.z,  p.x,    0), vec3( p.z, -p.x,    0) )
        s( vec3( p.z,  p.x,    0), vec3(-p.y, -p.y,  p.y) )
        s( vec3( p.z,  p.x,    0), vec3(-p.y, -p.y, -p.y) )
        s( vec3( p.z, -p.x,    0), vec3(-p.y,  p.y,  p.y) )
        s( vec3( p.z, -p.x,    0), vec3(-p.y,  p.y, -p.y) )
        s( vec3( p.x,    0, -p.z), vec3(-p.x,    0, -p.z) )
        s( vec3( p.x,    0, -p.z), vec3(-p.y,  p.y,  p.y) )
        s( vec3( p.x,    0, -p.z), vec3(-p.y, -p.y,  p.y) )
        s( vec3(-p.x,    0, -p.z), vec3( p.y, -p.y,  p.y) )
        s( vec3(-p.x,    0, -p.z), vec3( p.y,  p.y,  p.y) )
        s( vec3( p.x,    0,  p.z), vec3(-p.x,    0,  p.z) )
        s( vec3( p.x,    0,  p.z), vec3(-p.y,  p.y, -p.y) )
        s( vec3( p.x,    0,  p.z), vec3(-p.y, -p.y, -p.y) )
        s( vec3(-p.x,    0,  p.z), vec3( p.y,  p.y, -p.y) )
        s( vec3(-p.x,    0,  p.z), vec3( p.y, -p.y, -p.y) )
        s( vec3(   0,  p.z,  p.x*p2.y), vec3(   0,  p.z, -p.x) )
        s( vec3(   0,  p.z,  p.x*p2.y), vec3( p.y*p2.y, -p.y, -p.y) )
        s( vec3(   0,  p.z,  p.x*p2.y), vec3(-p.y*p2.y, -p.y, -p.y) )
        s( vec3(   0,  p.z, -p.x*p2.y), vec3( p.y*p2.y, -p.y,  p.y) )
        s( vec3(   0,  p.z, -p.x*p2.y), vec3(-p.y*p2.y, -p.y,  p.y) )
        s( vec3(   0, -p.z,  p.x*p2.y), vec3(   0, -p.z, -p.x) )
        s( vec3(   0, -p.z,  p.x*p2.y), vec3( p.y*p2.y,  p.y*p2.y, -p.y*p2.x))
        s( vec3(   0, -p.z,  p.x*p2.y), vec3(-p.y*p2.y,  p.y*p2.y, -p.y*p2.x)) 
        s( vec3(   0, -p.z, -p.x*p2.y), vec3(-p.y*p2.y,  p.y*p2.y,  p.y*p2.x)) 
        s( vec3(   0, -p.z, -p.x*p2.y), vec3( p.y*p2.y,  p.y*p2.y,  p.y*p2.x)) 

 
    C = vec4(c + c*c, 1);

float a1=.5+iMouse.x/iResolution.x*2.;
float a2=.8+iMouse.y/iResolution.y*2.;
mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
dir.xz*=rot1;
dir.xy*=rot2;
vec3 from=vec3(1.,.5,0.5);
from+=vec3(time*2.,time,-2.);
from.xz*=rot1;
from.xy*=rot2;

mainVR(fragColor, fragCoord, from, dir);
    fragColor*=C;
       uv *= 2.0 * ( cos(iTime * 2.0) -2.5);
   
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    

    fragColor+= vec4(nice_star(uv,anim) * vec3(0.55,0.5,0.55)*0.1, 1.0);
}

