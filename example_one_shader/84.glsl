// Fork of "Fractal 17_gaz" by gaz. https://shadertoy.com/view/tltfD4

#define PHI 1.61803
#define PI 3.141592
#define SIN(x) (.5+.5*sin(x))
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)

// Zucconis Spectra color (https://www.shadertoy.com/view/cdlSzB)
vec3 bump3y (vec3 x, vec3 yoffset)
{
    vec3 y = 1. - x * x;
    y = clamp((y-yoffset), vec3(0), vec3(1));
    return y;
}


vec3 zucc(float x) {
    x = fract(x);
    const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
    const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
    const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);
    const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
    const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
    const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);
    return bump3y(c1 * (x - x1), y1) + bump3y(c2 * (x - x2), y2) ;
}

mat2 rot(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }


vec2 foldSym(vec2 p, float N) {
    float t = atan(p.x,-p.y);
    t = mod(t+PI/N,2.0*PI/N)-PI/N;
    p = length(p.xy)*vec2(cos(t),sin(t));
    p = abs(p)-0.25;
    p = abs(p)-0.25;
    return p;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    vec3 r = iResolution,p,
         col = vec3(0);

    vec2 uv = (fragCoord-.5*r.xy)/r.y;
           
    // motion to center
    float dm = SIN(-.5*PI+.21*iTime);
    
    // line width
    float lw = mix(.006, 0.0025, dm);
   
    // background color
    col += vec3(0.082,0.106,0.118);
    col *= mix(.3, 1., (1.3-pow(dot(uv, uv), .5))); // vignette
  
   
    float g = 0., e, l, s;
    
    for(float i=0.; ++i<150.; e < lw ? col +=mix(
                r/r,
                zucc(g*.8 + .15*iTime),
                1.
            )*.9/i :p
    ) {
        p = vec3(g*uv,g-6.+6.*dm);
        
  
        p = R(p, normalize(vec3(1,3,5)),iTime*.2);
        p = abs(p) +.1;
           
        p.y > p.x ? p = p.yxz : p;
        p.z > p.x ? p = p.zyx : p;
        p.y > p.z ? p = p.xzy : p;

        s=2.;
        
        p.xy = foldSym(p.xy, 5.);
   
        for(int j=0;j++<3;) {
        
            s *= l = 2.2/min(dot(p,p), .8);
            p.x = abs(p.x) - 0.01;
            p=  abs(p) * l - vec3(2. + .4*sin(iTime*.5), .1+.9*SIN(.1*iTime),5.);
        }
            
        p.xy = foldSym(p.xy, PHI);
        p.yz *= rot(.75*2.*PHI);
            
        g += e =length(p.xz)/s;
          
    }
   
    col = pow(col*1.2, vec3(1.1));
   
    fragColor = vec4(col, 1); 
    
}