#define PI 3.14159265359

// Hash function for noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 2D noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    for (int i = 0; i < 6; ++i) {
        v += a * noise(p);
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;
    float t = iTime * 0.3;

    // Base distortion field
    vec2 distort = vec2(fbm(p + t), fbm(p + vec2(10.0, -5.0) - t));
    p += distort * 0.2;

    // Recursive rotation madness
    float angle = t + fbm(p * 2.0) * PI;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    p = rot * p;
    
    // Layer 1: Cosmic fractal swirl
    vec3 col = vec3(0.0);
    vec2 q = p * 3.0;
    float swirl = 0.0;
    for (float i = 1.0; i <= 5.0; i += 1.0) {
        float freq = i * 2.0;
        swirl += sin(q.x * freq + t * i) * cos(q.y * freq + t * i * 1.2) / i;
        q = rot * q + vec2(fbm(q + t), fbm(q - t)) * 0.5;
    }

    // Layer 2: Hyperspace color waves
    col.r = sin(swirl * 10.0 + t + length(p)) * 0.5 + 0.5;
    col.g = cos(swirl * 8.0 + t * 1.4 + distort.x) * 0.5 + 0.5;
    col.b = sin(swirl * 12.0 + t * 0.8 + distort.y) * 0.5 + 0.5;

    // Layer 3: Feedback distortion
    vec2 fb = p + col.rg * 0.15;
    float fbNoise = fbm(fb * 4.0 + t);
    col += vec3(fbNoise, fract(fbNoise * 2.0), sin(fbNoise * 5.0)) * 0.4;

    // Layer 4: Pulsing void rings
    float d = length(fb);
    float voidRing = sin(d * 25.0 - t * 6.0) * cos(d * 15.0 + t * 4.0);
    voidRing = smoothstep(0.2, 0.8, abs(voidRing));
    col *= mix(1.0, 0.2, voidRing);

    // Layer 5: Glitchy tendrils
    float tendrils = fbm(vec2(d * 10.0, t * 2.0));
    tendrils = pow(tendrils, 3.0) * sin(p.x * 20.0 + t * 5.0);
    col += vec3(0.8, 0.2, 1.0) * tendrils * 0.5;

    // Layer 6: Kaleidoscope effect
    vec2 kaleid = abs(fract(p * 2.0) - 0.5);
    float kaleidMix = smoothstep(0.1, 0.4, min(kaleid.x, kaleid.y));
    col = mix(col, col.gbr, kaleidMix);

    // Final chaos: Color warping and bloom
    col = pow(col, vec3(1.8 - sin(t) * 0.5));
    col += fbm(p * 8.0 + t) * 0.3;
    col *= 1.0 + sin(t * 10.0 + d * 50.0) * 0.2; // Flickering glow

    // Output with a slight vignette
    float vig = smoothstep(1.5, 0.5, length(uv * 2.0 - 1.0));
    fragColor = vec4(col * vig, 1.0);
}
//NOSTRA