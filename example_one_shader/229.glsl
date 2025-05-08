// Inspired by @XorDev's "3D Fire".

const float PI = radians(180.);


float mytanh(float x) {
    return (exp(2.0 * x) - 1.0) / (exp(2.0 * x) + 1.0);
}

vec2 mytanh(vec2 v) {
    return vec2(mytanh(v.x), mytanh(v.y));
}

vec3 mytanh(vec3 v) {
    return vec3(mytanh(v.x), mytanh(v.y), mytanh(v.z));
}
vec4 mytanh(vec4 v) {
    return vec4(mytanh(v.x), mytanh(v.y), mytanh(v.z), mytanh(v.w));
}



float sdCone(vec3 p) {
    return abs(length(p.xy) + p.z * .4 - .5);
}

float sdStar( in vec2 p, in float r, in int n, in float m) {
    float an = PI/float(n);
    float en = PI/m;  // m is between 2 and n
    vec2  acs = vec2(cos(an),sin(an));
    vec2  ecs = vec2(cos(en),sin(en)); // ecs=vec2(0,1) for regular polygon

    float bn = mod(atan(p.x,p.y),2.0*an) - an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp( -dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return length(p); // *sign(p.x);
}

float sdStar3D(vec3 p) {
    float d = sdStar(p.xy, 6.0, 5, 0.6);
    return abs(d + p.z*0.5 - 0.5);
}

mat2 rot2(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

void mainImage(out vec4 o, vec2 sp) {
    float z = 0.; // Raymarched depth
    vec3 vp = normalize(vec3(sp*2.,0)-iResolution.xyy);
    o = vec4(0);



    for (int i = 0; i < 70; i++) {
        vec3 p = z * vp; // Raymarch sample point
        p.z += 5.5;

      
    
      
     
        
        for (float s = 0.8; s < 25.; s /= 0.6)
            p += 2.5*cos(s*(p.yzx - vec3(iTime/.1, iTime, s)))/s;
         p.z += 5.5;
        float d = 0.01 + sdStar3D(p.zxy)/7.; // SDF
        o += (sin(sin(iTime*0.02)*5.0 + p.y/5.5 + length(p.xz)/1.5 + vec4(9,2,1,0)) + 1.1) / d; // RGB
        z += d; // raymarching step
    }

    o = mytanh(o / 1e3); // Tone mapping
}