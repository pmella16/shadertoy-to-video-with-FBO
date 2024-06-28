float gTime = 0.0;
const float REPEAT = 5.0;

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

float sdBox(vec3 p, vec3 b)
{
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float box(vec3 pos, float scale) {
    pos *= scale;
    float base = sdBox(pos, vec3(0.4, 0.4, 0.1)) / 1.5;
    pos.xy *= 5.0;
    pos.y -= 3.5;
    pos.xy *= rot(0.75);
    float result = -base;
    return result;
}

float sphere(vec3 pos, float radius) {
    return length(pos) - radius;
}

float torus(vec3 pos, float majorRadius, float minorRadius) {
    vec2 q = vec2(length(pos.xz) - majorRadius, pos.y);
    return length(q) - minorRadius;
}

float distort(float value, float amount) {
    return value + sin(value * amount) * 0.1;
}

// Function to combine multiple boxes with distortion
float box_set(vec3 pos, float iTime) {
    vec3 pos_origin = pos;
    pos = pos_origin;
    pos.y += sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8);
    float box1 = distort(box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5), 2.0);
    pos = pos_origin;
    pos.y -= sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8);
    float box2 = distort(box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5), 2.0);
    pos = pos_origin;
    pos.x += sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8);
    float box3 = distort(box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5), 2.0);
    pos = pos_origin;
    pos.x -= sin(gTime * 0.4) * 2.5;
    pos.xy *= rot(0.8);
    float box4 = distort(box(pos, 2.0 - abs(sin(gTime * 0.4)) * 1.5), 2.0);
    pos = pos_origin;
    pos.xy *= rot(0.8);
    float box5 = distort(box(pos, 0.5) * 6.0, 4.0);
    pos = pos_origin;
    float box6 = distort(box(pos, 0.5) * 6.0, 4.0);
    float result = max(max(max(max(max(box1, box2), box3), box4), box5), box6);
    return result; // Return the combined value
}

// Function to map the scene using different shapes
float map(vec3 pos, float iTime) {
    vec3 pos_origin = pos;
    float box_set1 = box_set(pos, iTime);
    float sphere1 = sphere(pos - vec3(0.0, 2.0, 0.0), 2.0);
    float torus1 = torus(pos - vec3(0.0, 0.0, 0.0), 1.5, 0.5);

    return max(max(box_set1, sphere1), torus1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
    
    // Camera position with vertical movement (sine wave) and forward momentum
    vec3 ro = vec3(2.0 * sin(gTime * 0.1), -0.2 + 0.2 * sin(gTime * 0.2), iTime * 4.0);
    vec3 ray = normalize(vec3(p, 1.5));
    ray.xy = ray.xy * rot(sin(iTime * 0.03) * 5.0);
    ray.yz = ray.yz * rot(sin(iTime * 0.05) * 3.2);
    
    float t = 0.1;
    vec3 col = vec3(0.0);
    float ac = 0.0;
    
    // Loop to trace rays and accumulate color
    for (int i = 0; i < 99; i++) {
        vec3 pos = ro + ray * t;
        pos = mod(pos - 2.0, 4.0) - 2.0;
        gTime = iTime - float(i) * 0.01;
        
        // Calculate the signed distance to the scene and accumulate color
        float d = map(pos, iTime);
        d = max(abs(d), 0.01);
        ac += exp(-d * 23.0);
        t += d * 0.55;
    }
    
    // Apply colors with some added variation
    col = vec3(ac * 0.03);
    col += vec3(1.15 * abs(sin(iTime * 0.1)), 0.15 * abs(cos(iTime * 1.7)), 0.15 * abs(sin(iTime * 0.3)));
    
    // Apply fog-like effect to the background
    col *= smoothstep(0.5, 01.0, t);
    
    fragColor = vec4(col, 4.0 - t * (0.42 + 0.42 * sin(iTime)));
}
