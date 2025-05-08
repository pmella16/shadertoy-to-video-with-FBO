float colors = 7.;
float zoom = 1.;

float pi = 3.14159;

//Credit: https://www.shadertoy.com/view/XcKSRd 
vec3 plane2sphere(vec2 p) {
    float r = length(p);
    float c = 2.*r / (dot(p, p)+1.);
    return vec3(p*c/r, sin(2.*atan(r) - pi / 2.));
}
vec3 rotate(vec3 v, float xz, float yz) {
    float c1 = cos(yz);
    float s1 = sin(yz);
    float c2 = cos(xz);
    float s2 = sin(xz);
    vec3 u = vec3(v.x, c1*v.y-s1*v.z, c1*v.z+s1*v.y);
    return vec3(c2*u.x-s2*u.z, u.y, c2*u.z+s2*u.x);
}

bool range(float val,float targ,float rang){
    return abs(val - targ) - rang < 0.;
}
vec3 palette(float t)
{
    vec3 a = vec3(0.5,0.5,0.5);
    vec3 b = vec3(0.5,0.5,0.5);
    vec3 c = vec3(1.,1.,1.);
    vec3 d = vec3(0.333,0.666,1.);
    
    return a + b * cos(6.28318 * (c * t + d));
}
float zig(float x){
    return (mod(x,2.) - 1.) * sign(mod(x,4.) - 2.);
}
float zag(float x,float r,float a,float s){
    return (sin(a) * -r) / 
        sin(2. * pi - sin(a) - (zig(s * x) * pi / s));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord * 2. / iResolution.xy - 1.;
    uv.x *= iResolution.x / iResolution.y;    
    uv /= zoom;
    
    
    vec2 mouse = iTime * vec2(0.2,0.3) * .1; //iMouse.xy == vec2(0) ? vec2(0.2*iTime, 0.) : (iMouse.xy * 2.0 - iResolution.xy) / iResolution.y;
    vec3 v = rotate(plane2sphere(uv), -8.*mouse.x, 8.*mouse.y);
    vec2 p = vec2(atan(v.y, v.x), asin(v.z)) / (pi / 2.);
    
    vec2 pol = vec2(mod(.5 + ((p.x + 2.) / 4.),1.), 1. - abs(p.y));
    
    float[] values = float[](
        abs(sin(pol.x * pi * 9. - iTime * 1.2)) * .15 + .1,
        zig(pol.x * 44. + iTime * 2.3) * .05 + .32 + (sin(iTime * 2.) * 0.03),
        zig(pol.x * 52. - iTime * 1.5) * .08 + .38 + (cos(iTime * 2.) * 0.03),
        (-abs(sin(pol.x * pi * 17. + iTime * 3.7)) + 1.) * 0.15 + .42 + (sin(iTime * 2. + pi/2.) * 0.05),
        abs(sin(pol.x * pi * 28. - iTime * 7.2)) * .03 + .68,
        zig(pol.x * 60. + iTime * 2.5) * .3 + 0.6,
        cos((pol.x * 60. + iTime * 2.5 + 60./2.) * pi / 2. ) * .02 + 0.84,
        zag(pol.x,0.80,1.2,80.)
    );
    
    bool[] conds = bool[](
        pol.y <= 0.01,
        pol.y <= 0.05,
        pol.y <= 0.08,
        pol.y <= 0.1,
        pol.y <= values[0] - .02,
        range(pol.y,values[0], .02),
        pol.y <= 0.19,
        pol.y <= 0.21,
        pol.y <= values[1] -0.03,
        pol.y <= values[1],
        
        -sin(pol.x * pi * 16. + sin(iTime) * 6.4 + iTime * 3.) * 0.1 + 0.35 > pol.y && 
        pol.y > sin(pol.x * pi * 16. + sin(iTime) * 7.5 + iTime * 3.) * 0.1 + 0.45,
        
        -sin(pol.x * pi * 16. + sin(iTime) * 6.4 + iTime * 3.) * 0.1 + 0.37 > pol.y && 
        pol.y > sin(pol.x * pi * 16. + sin(iTime) * 7.5 + iTime * 3.) * 0.1 + 0.43,
        
        range(mod(pol.x + iTime * -0.3, 0.04),0., 0.002) && pol.y <= values[6] - 0.03,
        pol.y <= values[2] -0.03,
        pol.y <= values[2],
        range(mod(pol.x + iTime * 0.1 + p.y * 0.2, 0.1),0., 0.01),
        pol.y <= values[3] -0.03,
        pol.y <= values[3],
        
        pol.y <= 0.62,
        pol.y <= 0.65,
        pol.y <= values[4],
        pol.y <= values[5],
        pol.y <= values[6] - 0.03,
        pol.y <= values[6],
        pol.y <= values[7] - 0.05,
        pol.y <= values[7],
        pol.y <= 0.96
    );
    
    float coloffset = iTime * 3. + pol.x * colors  + pol.y * colors;
    if(p.y > 0.){
        coloffset += 0.5 * colors;
    }
    
    vec3 col = palette((float(conds.length()) + coloffset) / colors) ;
    for(int i = 0; i < conds.length(); i++){
        if(conds[i]){
            col = palette((float(i) + coloffset) / colors ) ;
            break;
        }
    }
    
    
    fragColor = vec4(col,1.0);
}