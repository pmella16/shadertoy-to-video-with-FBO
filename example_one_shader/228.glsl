#define pi 3.14159
#define thc(a,b) mytanh(a*cos(b))/mytanh(a)
#define mlength(p) max(abs((p).x),abs((p).y))
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

// Rainbow color function for more vibrant colors
vec3 rainbow(float t) {
    t = fract(t);
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.333, 0.667)));
}


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



void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 res = iResolution.xy;
    vec2 uv = (fragCoord - 0.5 * res) / res.y;
    vec2 ouv = uv;
    float t = iTime;
    vec3 s = vec3(0);
    float n = 45.;
    float k = 4. / res.y;
    
    // Static position instead of moving with time
    vec2 p = vec2(0.0, 0.0);
    
    for (float i = 0.; i < n; i++) {
        float io = 2. * pi * i / n;
        float a = atan(uv.y, uv.x);
        
        // Keep original uv, don't add side movements
        // Only use depth scaling for z-movement effect
        float depthScale = 1.0 - (i/n) * (0.8 + 0.2 * sin(t * 0.5));
        vec2 newUV = ouv * depthScale;
        
        float sc = 10. + 0.2 * i;
        vec2 ipos = floor(sc * newUV) + 0.5;
        vec2 fpos = fract(sc * newUV) - 0.5;
        float th = 0.5 + 0.5 * thc(4., 10. * ipos.x - 4. * t + 4. * io);
        float th2 = 0.5 + 0.5 * thc(4., length(ipos) + 2. * t + 1.5 * io);
        float d = length(fpos-p);
        float d2 = mlength(fpos-p);
        float r2 = (0.5 + 0.5 * cos(io + t)) * th2;
        float s2 = step(abs(d2 - 0.3 * r2), 0.02);
        
        // More vibrant colors using rainbow function
        vec3 circleColor = rainbow(i/n + t * 0.1);
        vec3 glowColor = rainbow(i/n - t * 0.15);
        vec3 rimColor = rainbow(i/n * 2.5 + t * 0.2);
        
        // Enhanced glow
        s = max(s, exp(-3. * r2) * (1.-r2) * i * smoothstep(-k, k, -abs(d-r2) + 0.01) / n * circleColor * 1.5);
        
        float v = mix(10., 40., th);
        s += 0.3 * smoothstep(-k, k, -d + i/n * mix(0.12, 0.05, th)) * glowColor;
        s = max(s, exp(-v * d) * pow(i/n, 2.) * glowColor);
        
        // Add rim effects with more colors
        s = max(s, exp(-v * abs(d2-r2)) * pow(i/n, 2.) * rimColor * 0.7);
        s = max(s, r2 * s2 * pow(i/n, 2.) * rimColor);
    }
    
    // Enhanced contrast with brighter colors
    vec3 col = 0.05 + vec3(s) * 1.2;
    
    // Apply vignette effect but less aggressively
    col *= 1.0/(0.8 + 0.4 * length(ouv));
    
    // Add subtle color tint based on position
    col += 0.05 * rainbow(length(ouv) * 0.5 + t * 0.1);
    
    // Enhance overall brightness
    col = pow(col, vec3(0.85));
    
    fragColor = vec4(col, 1.0);
}