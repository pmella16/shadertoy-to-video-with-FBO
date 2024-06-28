float det = 0.001, t, boxhit;
vec3 adv, boxp;

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, s, -s, c);
}

vec3 path(float t) {
    vec3 p = vec3(vec2(sin(t * 0.1), cos(t * 0.05)) * 10., t);
    p.x += smoothstep(0.0, 0.5, abs(0.5 - fract(t * 0.02))) * 10.;
    return p;
}

float fractal(vec2 p) {
    p = abs(5.0 - mod(p * 0.2, 10.0)) - 5.0;
    float ot = 1000.0;
    for (int i = 0; i < 7; i++) {
        p = abs(p) / clamp(p.x * p.y, 0.25, 2.0) - 1.0;
        if (i > 0) ot = min(ot, abs(p.x) + 0.7 * fract(abs(p.y) * 0.05 + t * 0.05 + float(i) * 0.3));
    }
    ot = exp(-10.0 * ot);
    return ot;
}

vec3 rainbow(float gray, float transitionSpeed) {
    // Rainbow coloring based on fractal value
    float tGray = t * transitionSpeed;
    vec3 tint = vec3(
        abs(sin(tGray + gray)),
        abs(sin(tGray + gray + 2.0)),
        abs(sin(tGray + gray + 4.0))
    );

    return tint;
}

float cube(vec3 p, vec3 size) {
    vec3 d = abs(p) - size;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float de(vec3 p) {
    boxhit = 0.0;
    vec3 p2 = p - adv;
    p2.xz *= rot(t * 0.2);
    p2.xy *= rot(t * 0.1);
    p2.yz *= rot(t * 0.15);
    float b = cube(p2, vec3(1.0));
    p.xy -= path(p.z).xy;
    float s = sign(p.y);
    p.y = -abs(p.y) - 3.0;
    p.z = mod(p.z, 20.0) - 10.0;
    for (int i = 0; i < 5; i++) {
        p = abs(p) - 1.0;
        p.xz *= rot(radians(s * -45.0));
        p.yz *= rot(radians(90.0));
    }
    float f = -cube(p, vec3(5.0, 5.0, 10.0));
    float d = min(f, b);
    if (d == b) boxp = p2, boxhit = 1.0;
    return d * 0.7;
}

vec3 march(vec3 from, vec3 dir) {
    vec3 p, n, g = vec3(0.0);
    float d, td = 0.0;
    vec3 prevTint = vec3(0.0); // Initialize the previous tint color

    for (int i = 0; i < 80; i++) {
        p = from + td * dir;
        d = de(p);
        if (d < det && boxhit < 0.5) break;

        td += max(det, abs(d));

        float gray = fractal(p.xy) + fractal(p.xz) + fractal(p.yz);
        vec3 tint = rainbow(gray, 0.1); // Adjust the transition speed as needed

        // Smoothly interpolate between previous tint and current tint
        float blendFactor = 0.02; // Adjust this value for smooth transitions
        tint = mix(prevTint, tint, blendFactor);

        g += tint / (3.0 + d * d * 2.0) * exp(-0.0015 * td * td) * step(5.0, td) / 2.0 * (1.0 - boxhit);

        // Update the previous tint for the next iteration
        prevTint = tint;
    }

    return g;
}

mat3 lookat(vec3 dir, vec3 up) {
    dir = normalize(dir);
    vec3 rt = normalize(cross(dir, normalize(up)));
    return mat3(rt, cross(rt, dir), dir);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    t = iTime * 7.0;
    vec3 from = path(t);
    adv = path(t + 6.0 + sin(t * 0.1) * 3.0);
    vec3 dir = normalize(vec3(uv, 0.7));
    float gray = fractal(from.xy) + fractal(from.xz) + fractal(from.yz);
    vec3 col = march(from, dir);
    col *= rainbow(gray, 0.0001); // Adjust the transition speed as needed (0.0001 is just an example)
    col *= vec3(1.0, 0.9, 0.8);
    fragColor = vec4(col, 1.0);
}
