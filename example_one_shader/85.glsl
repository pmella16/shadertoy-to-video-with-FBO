/* originals https://www.shadertoy.com/view/lXsGRn https://www.shadertoy.com/view/lfjSWc https://www.shadertoy.com/view/msKBzc*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(53,53,41))*.5+.5)

#define PHI 1.61803
#define PI  3.14159

// Virtually the same as your original function, just in more compact (and possibly less reliable) form.
float smoothNoise(vec2 p) {
	
	vec2 i = floor(p); p-=i; p *= p*(3.-p-p); 
    
    return dot(mat2(fract(exp(sin(vec4(0, 1, 27, 28) + i.x+i.y*37.)) * 1e5))*vec2(0.1-p.y,p.y), vec2(1.-p.x, p.x));

}

// Also the same as the original, but with one less layer.
float fractalNoise(vec2 p) {
    
    return smoothNoise(p)*.5333 + smoothNoise(p*2.)*.2667 + smoothNoise(p*4.)*.1333 + smoothNoise(p*8.)*.0667;
    
    //Similar version with fewer layers. The highlighting sample distance would need to be tweaked.
    //return smoothNoise(p)*.57 + smoothNoise(p*2.45)*.28 + smoothNoise(p*6.)*.15;
    
    // Even fewer layers, but the sample distance would need to be tweaked.
    //return smoothNoise(p)*.65 + smoothNoise(p*4.)*.35;
    
}

// Standard noise warping. Call the noise function, then feed a variation of the result
// into itself. Rinse and repeat, etc. Completely made up on the spot, but keeping your 
// original concept in mind, which involved combining noise layers travelling in opposing
// directions.
float warpedNoise(vec2 p) {
    
    vec2 m = vec2(-iTime, iTime)*.15;//vec2(sin(iTime*0.5), cos(iTime*0.5));
    
    
    float x = fractalNoise(abs(p) + m);
    float y = fractalNoise(p + m.yx + x);
    float z = fractalNoise(p - m - x + y);
    return fractalNoise(p + vec2(x, y) + vec2(y, z) + vec2(z, x) + length(vec3(x, y, z))*0.25);
    
    
}

// Zucconis Spectra color (https://www.shadertoy.com/view/cdlSzB)
vec3 bump3y (vec3 x, vec3 yoffset) {
    vec3 y = 1. - x * x;
    y = clamp((y-yoffset), vec3(0), vec3(1));
    return y;
}


vec3 spectral_zucconi6(float x) {
    x = fract(x/2.);
    const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
    const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
    const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);
    const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
    const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
    const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);
    return bump3y(c1 * (x - x1), y1) + bump3y(c2 * (x - x2), y2) ;
}


vec3 colNoise(vec2 uv, float colShift) {
    float nl = warpedNoise(uv*2.);
    // Take two noise function samples near one another.
    float n = warpedNoise(uv * 6.);
    float n2 = warpedNoise(uv * 6. + .03*sin(nl));
    
    // Highlighting - Effective, but not a substitute for bump mapping.
    //
    // Use a sample distance variation to produce some cheap and nasty highlighting. The process 
    // is vaguely related to directional derivative lighting, which in turn is mildly connected to 
    // Calculus from First Principles.
    float bump = max(n2 - n, 0.)/.12*.7071;
    float bump2 = max(n - n2, 0.)/.02*.7071;
    
    // Ramping the bump values up.
    bump = bump*bump*.5 + pow(bump, 4.)*.5;
    bump2 = bump2*bump2*.5 + pow(bump2, 4.)*.5;
    
    vec3 col = spectral_zucconi6(nl+n*0.5+colShift)*(vec3(1.000,0.200,0.973)*vec3(1.2*bump, (bump + bump2)*.4, bump2)*.3);

    return col;
}

mat2 rot(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a));}


// cheapo noise function
float n21(vec2 p) {
    p = fract(p*vec2(234.42,725.46));
    p += dot(p, p+54.98);
    return fract(p.x*p.y);
}

vec2 n22(vec2 p) {
    float n = n21(p);
    return vec2(n, n21(p+n));
}

// Fork of "Fractal 17_gaz" by gaz. https://shadertoy.com/view/tltfD4

#define PHI 1.61803

#define SIN(x) (.5+.5*sin(x))
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)

// Zucconis Spectra color (https://www.shadertoy.com/view/cdlSzB)

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


vec2 foldSym(vec2 p, float N) {
    float t = atan(p.x,-p.y);
    t = mod(t+PI/N,2.0*PI/N)-PI/N;
    p = length(p.xy)*vec2(cos(t),sin(t));
    p = abs(p)-0.25;
    p = abs(p)-0.25;
    return p;
}

float beautiful_happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
void mainImage(out vec4 O, vec2 C)
{

vec3 mouse = vec3(iMouse.xy/iResolution.xy - 0.5,iMouse.z-.5);

  float dm = SIN(-.5*PI+.21*iTime);
    vec3 r=iResolution,naturals;  
    vec2 uv2 = (C-.5*r.xy)/r.y;
    vec4 O2 = O;
    // background color
    O2 = vec4(0, 0, 0, 1);
    
    O2.rgb += vec3(0.082,0.106,0.118);
    O2.rgb *= mix(.3, 1., (1.3-pow(dot(uv2, uv2), .5))); // vignette
  
   
    float g =0.0;
    for(float i=0.,g=0.,e,l,s;
        ++i<150.;
        e<mix(.006, 0.0025, dm)?O2.xyz+=mix(
                r/r,
                zucc(g*.8+.15*iTime),
                1.
            )*.9/i:naturals
    )
    {
        naturals=vec3(g*uv2,g-6.+6.*dm);
         naturals.xz*=mat2(cos(mouse.x*5.),sin(mouse.x*5.),-sin(mouse.x*5.),cos(mouse.x*5.));
           naturals.yz*=mat2(cos(mouse.y*5.),sin(mouse.y*5.),-sin(mouse.y*5.),cos(mouse.y*5.));
  
        naturals=R(naturals,normalize(vec3(1,3,5)),iTime*.0);
        naturals=abs(naturals) +.1;
           
        naturals.y>naturals.x?naturals=naturals.yxz:naturals;
        naturals.z>naturals.x?naturals=naturals.zyx:naturals;
        naturals.y>naturals.z?naturals=naturals.xzy:naturals;

        s=2.;
        naturals.xy = foldSym(naturals.xy, 5.);
   
        for(int j=0;j++<3;)
            s*=l=2.2/min(dot(naturals,naturals), .8),
            naturals.x = abs(naturals.x) - 0.01,
            naturals=abs(naturals)*l-vec3(2. + .4*cos(iTime*1.0),.1+.9*SIN(1.0*iTime),5.);
            
            naturals.xy = foldSym(naturals.xy, PHI);
            naturals.yz *= rot(.75*2.*PHI);
            
        g+=e=length(naturals.xz)/s;
          
    }
   
   O2.rgb = pow(O2.rgb*1.2, vec3(1.1));

    O=vec4(0);
      vec2 uv = (C.xy - .5*iResolution.xy)/iResolution.y;
    
    uv.x = abs(uv.x);
   
    vec3 col = vec3(0);
    // vec3 col = colNoise(uv*2.) + colNoise(uv)*1.2 + .25*colNoise(uv*.4)+.1*colNoise(uv*.1);
    
    for(float i=.0; i<=1.1; i+=.21) {   
        float z = fract(i-.2*-iTime);
        float fade = smoothstep(.8, .1, z); // 
        //uv += 0.2*n22(vec2(i*412., 52423.*i));
        uv *= rot(10.*PI/PHI+ PI/12.*sin(-.0*iTime));       // Rotate layer
        vec2 UV = uv*1.5*z+ + n22(vec2(i*51., 4213.*i));  // Scale and offset layer by random value
      
        col += colNoise(UV, -iTime*.11+z)*fade;
    }
    
    	col = vec3(pow(max(col, 0.0), vec3(1./2.2)))*3.;

    vec3 natur,q,r2=iResolution,
    d=normalize(vec3((C*2.-r2.xy)/r2.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        natur=g*d;
        natur.z+=iTime*1.5;
        a=30.;
        natur=mod(natur-a,a*2.)-a;
        s=3.;
        for(int i=0;i++<8;){
            natur=.3-abs(natur);
            
            natur.x<natur.z?natur=natur.zyx:natur;
            natur.z<natur.y?natur=natur.xzy:natur;
             natur.z<natur.x?natur=natur.zyx:natur;
            s*=e=1.4+sin(iTime*.234)*.1;
            natur=abs(natur)*e-
                vec3(
                    10.*cos(iTime*.3+.5*sin(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.2)*5.
                 )*O2.xyz;
         }
         g+=e=length(natur.yz)/s;
         uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    O+= vec4(beautiful_happy_star(uv, anim) * vec3(0.55,0.5,0.55)*0.1, 1.0);
    }
}