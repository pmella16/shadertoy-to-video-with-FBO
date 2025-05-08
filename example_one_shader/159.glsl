// inspired by foxes' honeycomb fractal

vec3 hash(float x) { 
    return fract(cos((vec3(x) + vec3(23.32445, 132.45454, 65.78943)) * vec3(23.32445, 32.45454, 65.78943)) * 4352.34345); 
}

vec3 noise(float x) {
    float p = fract(x); 
    x -= p;
    return mix(hash(x), hash(x + 1.0), p);
}

vec3 noiseq(float x) {
    return (noise(x) + noise(x + 10.25) + noise(x + 20.5) + noise(x + 30.75)) * 0.25;
}

void mainImage(out vec4 O, vec2 U) {
    float time = iTime * 0.15;
    vec3 k1 = noiseq(time) * vec3(0.1, 0.19, 0.3) + vec3(1.3, 0.8, 0.63);
    vec3 k2 = noiseq(time + 1000.0) * vec3(0.2, 0.2, 0.05) + vec3(0.9, 0.9, 0.05);

  

    k2 += vec3((0.0 - 0.8) * 0.05);
    k1 += vec3((0.0 - 0.5) * 0.01);
    
    float g = pow(abs(cos(time * 0.8 + 9000.0)), 4.0);
    
    vec2 R = iResolution.xy;
    vec2 r1 = (U / R.y - vec2(0.5 * R.x / R.y, 0.5));
    float l = length(r1);
    vec2 rotate = vec2(cos(time), sin(time));
    r1 = vec2(r1.x * rotate.x + r1.y * rotate.y, r1.y * rotate.x - r1.x * rotate.y);
    vec2 c3 = abs(r1.xy / l);
    if (c3.x > 0.5) c3 = abs(c3 * 0.5 + vec2(-c3.y, c3.x) * 0.86602540);
    c3 = normalize(vec2(c3.x * 2.0, (c3.y - 0.8660254037) * 7.4641016151377545870));
    
    O = vec4(c3 * l * 70.0 * (g + 0.12), 0.5, 0);
    for (int i = 0; i < 1024; i++) {
        O.xzy = (k1 * abs(O.xyz / dot(O, O) - k2));
    }
    

    vec2 uv = U / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    float radius = length(uv);
    float angle = atan(uv.y, uv.x) + radius * 3.0 * iTime;
    vec2 spiralUV = vec2(cos(angle), sin(angle)) * radius;
    spiralUV = (spiralUV + 1.0) * 0.5;




}
