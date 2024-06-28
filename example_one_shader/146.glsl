#define PI 3.1415926535
#define TAU (2.0 * PI)
#define SPEED 15.0  // Increased by 50%
#define RESOLUTION iResolution
#define TIME iTime  // Use the normal time

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = i.x + i.y * 57.0 + 113.0 * i.z;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5000 * noise(p); p *= 2.02;
    f += 0.2500 * noise(p); p *= 2.03;
    f += 0.1250 * noise(p); p *= 2.01;
    return f;
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float map(vec3 pos) {
    pos.z += TIME * SPEED; // Travel forward
    pos.xy += vec2(sin(pos.z * 0.1), cos(pos.z * 0.1)) * fbm(pos * 0.1) * 2.0; // Add curves to the tunnel
    float radius = 3.0 + sin(pos.z * 0.1) * 0.5 + fbm(pos * 0.5) * 0.5;
    return length(pos.xy) - radius;
}

vec3 getColor(vec3 p) {
    float d = fbm(p * 0.5 + TIME * 0.5); // Slow down the pulsating effect
    float hue = 0.1 + 0.5 * sin(d * 5.0 + TIME * 0.5); // Adjust hue range to avoid yellow and green
    if (hue > 0.3 && hue < 0.5) hue += 0.2; // Avoid yellow range
    float sat = 0.8; // Slightly reduce saturation
    float val = 1.0 - d * 0.6; // Increase range of value to include darker colors
    return hsv2rgb(vec3(hue, sat, val));
}

vec3 getElectricColor(vec3 p) {
    float d = fbm(p * 5.0 + TIME * 5.0); // Slow down the pulsating effect
    float hue = fract(d + TIME * 0.5); // Slow down the hue shift
    hue = mod(hue + 0.1, 1.0); // Adjust hue range to avoid yellow and green
    if (hue > 0.3 && hue < 0.5) hue += 0.2; // Avoid yellow range
    float sat = 0.8; // Slightly reduce saturation
    float val = smoothstep(0.4, 0.6, sin(TIME * 5.0 + d * 10.0)) * 0.4; // Adjust value range to include more black
    return hsv2rgb(vec3(hue, sat, val));
}

vec3 getLightningColor(vec3 p) {
    float d = noise(p * 10.0 + TIME * 20.0); // High frequency noise for lightning
    float hue = fract(d + TIME * 0.5); // Color of the lightning
    hue = mod(hue + 0.1, 1.0); // Adjust hue range to avoid yellow and green
    if (hue > 0.3 && hue < 0.5) hue += 0.2; // Avoid yellow range
    float sat = 0.9; // High saturation for lightning
    float val = smoothstep(0.7, 0.9, d) * 1.0; // Make the lightning very bright but include some black
    return hsv2rgb(vec3(hue, sat, val));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / RESOLUTION.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= RESOLUTION.x / RESOLUTION.y;

    float time = TIME * SPEED;
    vec3 col = vec3(0.0);

    vec3 ro = vec3(0.0, 0.0, -time); // Set ray origin to simulate forward movement
    vec3 rd = normalize(vec3(uv, 1.0));

    float t = 0.0;
    vec3 p = ro;
    for (int i = 0; i < 100; i++) {
        float dist = map(p);
        t += dist;
        p += dist * rd;
        if (abs(dist) < 0.001) break;
    }

    vec3 normal = normalize(vec3(map(p + vec3(0.001, 0.0, 0.0)) - map(p - vec3(0.001, 0.0, 0.0)),
                                 map(p + vec3(0.0, 0.001, 0.0)) - map(p - vec3(0.0, 0.001, 0.0)),
                                 map(p + vec3(0.0, 0.0, 0.001)) - map(p - vec3(0.0, 0.0, 0.001))));

    vec3 color = getColor(p);
    color *= 0.5 + 0.5 * dot(normal, normalize(-rd));

    // Add twisting and morphing effects
    vec3 posMod = p + vec3(sin(p.z * 0.5), cos(p.z * 0.5), 0.0) * 0.5;
    vec3 twistColor = getColor(posMod);
    color = mix(color, twistColor, 0.5);

    // Add electric crackles
    for (int i = 0; i < 5; i++) {
        vec3 offset = vec3(hash(float(i)), hash(float(i) + 1.0), hash(float(i) + 2.0));
        vec3 electricPos = p + offset * 10.0;
        vec3 electricColor = getElectricColor(electricPos);
        color += electricColor * 0.025; // Tone down electric effect by 75%
    }

    // Add lightning crackles
    for (int i = 0; i < 3; i++) {
        vec3 offset = vec3(hash(float(i) + 3.0), hash(float(i) + 4.0), hash(float(i) + 5.0));
        vec3 lightningPos = p + offset * 20.0;
        vec3 lightningColor = getLightningColor(lightningPos);
        color += lightningColor * 0.05; // Tone down lightning effect by 75%
    }

    // Add plasma-like effect
    vec3 plasmaPos = p + vec3(sin(p.z * 0.1), cos(p.z * 0.1), 0.0) * 2.0;
    vec3 plasmaColor = getColor(plasmaPos);
    color = mix(color, plasmaColor, 0.2);

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
