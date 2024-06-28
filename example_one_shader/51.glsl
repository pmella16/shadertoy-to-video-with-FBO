// Author: bitless
// Title: Strange Wave

// Thanks to Patricio Gonzalez Vivo & Jen Lowe for "The Book of Shaders"
// and Fabrice Neyret (FabriceNeyret2) for https://shadertoyunofficial.wordpress.com/
// and Inigo Quilez (iq) for  https://iquilezles.org/www/index.htm
// and whole Shadertoy community for inspiration.

#define r( n ) fract(sin(n)*43758.5453) //random
#define n(v) mix(r(floor(v)),r(floor(v)+1.),smoothstep(0.,1.,fract(v))) 
#define h(v) ( .6 + .6 * cos(6.3*(v) + vec4(0,23,21,0) ) ) //hue

void w(vec2 u, float s, inout vec4 C)
{
    float   t = n(u.x)*n(u.x-s-iTime)+.4 //top edge
            ,b = n(u.x+5.)*n(u.x-9.-s-iTime)-.8; //bottom edge
    
    C = mix(C, 
            h(s*.2+iTime*.3+u.x*.1), 
            pow(abs((u.y-b)/(t-b)-.5)*2.,9.)+.05)*smoothstep(0.,5./iResolution.y,(t-u.y)*(u.y-b));
}

void mainImage( out vec4 C, in vec2 g)
{
    vec2 r = iResolution.xy
        ,u = (g+g-r)/r.y;
    C = vec4(0);
        
    u.x-=iTime/5.;
    for (float s = 1.5; s > 0.; s-=.1)
        w(u*vec2(2.,1.+s),-s,C);
}