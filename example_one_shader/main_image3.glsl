
// Octahedron SDF - https://iquilezles.org/articles/distfunctions/
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}

// Custom gradient - https://iquilezles.org/articles/palettes/
vec3 palette(float t) {
    return .5+.5*cos(6.28318*(t+vec3(.6,.3,.9)));
}

// 2D rotation function
mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// Scene distance
float map(vec3 p) {
    p.z -= iTime * .4;
    // Space repetition
    p.xy = fract(p.xy) - .5;     // spacing: 1
    p.z =  mod(p.z, .25) - .125; // spacing: .25
    float circle = length(p) - (sin(iTime) + 4.) /3. * .08  ; // distance to a sphere of radius 1
    float octa = sdOctahedron(p, .2); 
    return max(-circle, octa);
    return octa;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;

    // Initialization
    vec3 ro = vec3(0, 0, -3);         // ray origin
    vec3 rd = normalize(vec3(uv, 1)); // ray direction
    vec3 col = vec3(0);               // final pixel color

    float t = 0.; // total distance travelled

    // Raymarching
    int i = 0;
    for (i; i < 80; i++) {
        vec3 p = ro + rd * t;     // position along the ray
        
        p.xy *= rot2D(t*.15 * 1.);     // rotate ray around z-axis

        p.y += sin(t*(.5+1.)*.5)*.5;  // wiggle ray
        //p.x += sin(t*(.5+1.)*.5)*.5;  // wiggle ray

        float d = map(p);         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > 100.) break;      // early stop if too far
    }

    // Coloring
    col = vec3(t*.04 + float(i)*.005); 
    col = palette(t);
    // color based on distance

    fragColor = vec4(col, 1);
}
