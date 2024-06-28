// wireframe code modified from FabriceNeyret2: https://www.shadertoy.com/view/XfS3DK

#define H(a) (cos(radians(vec3(-30, 60, 150))+(a)*6.2832)*.5+.5)  // hue
#define A(v) mat2(cos((v*3.1416) + vec4(0, -1.5708, 1.5708, 0)))  // rotate
#define s(a, b) c = max(c, .01/abs(L( u, K(a, v, h), K(b, v, h) )+.02)*k*10.*o); // segment
//#define s(a, b) c += .02/abs(L( u, K(a, v, h), K(b, v, h) )+.02)*k*o*(1.-i);  // alt segment


float mytanh(float x) {
    return (exp(2.0 * x) - 1.0) / (exp(2.0 * x) + 1.0);
}

vec2 mytanh(vec2 v) {
    return vec2(mytanh(v.x), mytanh(v.y));
}

vec3 mytanh(vec3 v) {
    return vec3(mytanh(v.x), mytanh(v.y), mytanh(v.z));
}


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

void mainImage( out vec4 C, in vec2 U )
{
    vec2 R = iResolution.xy,
         u = (U+U-R)/R.y*1.2,
         m = (iMouse.xy*2.-R)/R.y;
    
    float t = iTime/60.,
          l = 15.,  // loop size
          j = 1./l, // increment size
          r = .8,   // scale size
          o = .1,   // brightness
          i = 0.;   // starting increment
    
    if (iMouse.z < 1.)
        m = sin(t*6.2832 + vec2(0, 1.5708)); // move in circles
        m.x *= 2.; // stretch mouse x (circle to ellipse)
    
    mat2 v = A(m.y), // pitch
         h; // yaw
    
    vec3 p = vec3(0, 1, -1),    // cube coords
         c = .2*length(u)*H(t), // background
         k;
    
    // cubes
    for (; i<1.; i+=j)
    {
        k = H(i+iTime/3.)+.2; // cube color
        h = A(m.x+i); // rotate
        p *= r; // scale
        s( p.yyz, p.yzz )
        s( p.zyz, p.zzz )
        s( p.zyy, p.zzy )
        s( p.yyy, p.yzy )
        s( p.yyy, p.zyy )
        s( p.yzy, p.zzy )
        s( p.yyz, p.zyz )
        s( p.yzz, p.zzz )
        s( p.zzz, p.zzy )
        s( p.zyz, p.zyy )
        s( p.yzz, p.yzy )
        s( p.yyz, p.yyy )
    }
    
    C = vec4(mytanh(c*c*3.), 1);
}