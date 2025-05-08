

// 2D rotation matrix function 
mat2 rotateChaos(float _angle) {
    return mat2(cos(_angle), -sin(_angle),
                sin(_angle), cos(_angle));
}

// Pseudo-random hash function
float hashNoise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}

// Generate chaotic noise 
float chaoticRandom(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Function for random chaotic displacement
vec2 chaoticDisplacement(vec2 uv, float intensity) {
    float n = sin(uv.x * 15.0 + iTime * 3.0) * cos(uv.y * 15.0 - iTime * 2.5);
    return uv + vec2(sin(n * 5.0), cos(n * 7.0)) * intensity;
}

// Random shadow pattern 
float randomShadow(vec2 uv) {
    float flicker = sin(iTime * 2.0 + hashNoise(uv) * 6.28) * 0.5 + 0.5;
    return smoothstep(0.3, 0.7, flicker);
}

// Glitchy noise pattern 
float glitchNoise(vec2 uv) {
    float flicker = step(0.95, fract(sin(iTime * 2.0 + uv.y * 50.0) * 43758.5453));
    return hashNoise(uv) * flicker;
}

float chaoticMix(float p1, float p2, float speed) {
    float flicker = step(0.5, sin(iTime * speed + chaoticRandom(vec2(p1, p2)) * 6.28));
    return mix(p1, p2, flicker);
}

const int GRID_SIZE = 20;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float aspect = iResolution.x / iResolution.y;
    uv = (uv - 0.5) * vec2(aspect, 1.0) + vec2(0.5, 0.5);
    
    // shift vertically 
    uv.y += iTime * 0.05;
    
    // slow rotation over time
    float angle = iTime * 0.05;
    uv = (uv - 0.5) * rotateChaos(angle) + 0.5;
    
    vec2 gridUV = uv * float(GRID_SIZE);
    vec2 cellID = floor(gridUV);     
    vec2 cellLocal = fract(gridUV);      
    

    float rnd = hashNoise(cellID);
    float pattern = 0.0;

    // introduce chaotic patterns
    if (rnd < 0.33) {
        pattern = chaoticMix(glitchNoise(cellLocal), randomShadow(cellLocal), 4.0);
    } else if (rnd < 0.66) {
        pattern = chaoticMix(randomShadow(cellLocal), glitchNoise(cellLocal), 5.0);
    } else {
        pattern = chaoticMix(glitchNoise(cellLocal), randomShadow(cellLocal), 6.0);
    }

    vec3 color = vec3(pattern);
    
    fragColor = vec4(color, 1.0);
}
