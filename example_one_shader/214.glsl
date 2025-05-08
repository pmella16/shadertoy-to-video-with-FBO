// Concepts and Ideas taken from: https://www.youtube.com/watch?v=MpDUW_bvihE
// 3D effect on 2D grid
float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdfCircle(vec2 p, vec2 center, float radius) {
    return length(p - center) - radius;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - .5*iResolution.xy)/iResolution.y;
    vec2 st = uv * vec2(200.0, 200.0) + vec2(175.0, 100.0); // Rectangular grid: 350x200, centered
    
    float margin = 10.0;
    float size = 6.0;
    
    vec2 grid = mod(st - margin, size);
    vec2 id = floor((st - margin) / size);
    
    float cols = (350.0 - margin*2.0) / size;
    float rows = (200.0 - margin*2.0) / size;
    
    float sdf = 1e10;
    vec3 color = vec3(0.0);
    float totalWeight = 0.0;
    if (id.x >= 0.0 && id.x < cols && id.y >= 0.0 && id.y < rows) { // Neighbours' logic for a cleaner visual. 
        for (float dx = -1.0; dx <= 1.0; dx++) {
            for (float dy = -1.0; dy <= 1.0; dy++) {
                vec2 neighborId = id + vec2(dx, dy);
                if (neighborId.x >= 0.0 && neighborId.x < cols && neighborId.y >= 0.0 && neighborId.y < rows) {
                    vec2 center = (neighborId + 0.5) * size + margin;
                    vec2 centerOffset = center - vec2(175.0, 100.0);
                    float r = length(centerOffset);
                    float theta = atan(centerOffset.y, centerOffset.x);
                    float maxDist = 100.0;
                    float angle = r / maxDist * 12.;
                    float scl = mix(0.05, 0.03, r / maxDist);
                    float wave1 = sin(angle + 2.*iTime) * 60.0 * scl;
                    float rOffset = wave1;
                    vec2 finalCenter = vec2(175.0, 100.0) + vec2(
                        (r + rOffset) * cos(theta),
                        (r + rOffset) * sin(theta)
                    );
                    float d = sdfCircle(st, finalCenter, 2.);
                    float weight = 1.0 / (1.0 + d * d);
                    sdf = smin(sdf, d, 0.5);
                    vec3 neighborColor = vec3(.8) + vec3(0.1, 0.5, 0.2) * sin(angle * iTime *.2);
                    color += neighborColor * weight;
                    totalWeight += weight;
                }
            }
        }
        
        if (sdf < 0.0) {
            color /= totalWeight;
            fragColor = vec4(color, 1.0);
            return;
        }
    }
    
    color = pow(color, vec3(0.4545));
    fragColor = vec4(vec3(0.0), 1.0);
}