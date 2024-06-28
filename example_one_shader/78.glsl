// Fork of "Simple Cubes Tunnel 2" by rafaelbeckel. https://shadertoy.com/view/DtyGRh
// 2024-01-28 04:37:53

// I applied the distortion effect from https://www.shadertoy.com/view/lcs3DH
// into my old cubes tunnel, but while tweaking I unintentially arrived
// in this water-like effect which looks cool, so I decided to save it
// as-is while I continue working on it.

vec3 colorForPoint(vec3 p) {
    vec3 cubePos = vec3(floor(p.x) + 0.5, floor(p.y) + 0.5, floor(p.z) + 0.5);
    float t = p.z * 0.1;
    vec3 color = 0.5 + 0.5 * sin(t * vec3(1.0, 2.0, 3.0) + vec3(0.0, 2.0, 4.0));

    // Blinking effect
    float blinkSeed = sin(dot(cubePos, vec3(37.2187, 51.9898, 98.233))) * 43758.5453;
    float blinkFactor = 0.5 + 0.5 * sin(iTime * 0.2 + blinkSeed);
    float blinkThreshold = 0.988;
    if (blinkFactor > blinkThreshold) {
        float intensity = smoothstep(blinkThreshold, 1.0, blinkFactor);
        color = mix(color, vec3(1.0), intensity);
    }

    return color;
}

mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

void mainImage(out vec4 O, vec2 u) {
    vec3 R = iResolution, C,
         P = vec3(0, 0, iTime * 2.),
         D = normalize(vec3(u, R.y) - 0.5 * R);

    D.xy *= mat2(cos( iTime*.1 - vec4(0,11,33,0)));

    float t = 0., d = 1., i = 0.;
    for (; i++ < 80. && d > .001; P += d * D) {
        // these two lines are the only changes I did to my old shader
        P.xy *= rot2D(t*.05);
        P.y += sin(t*(iTime*.0001)*.5)*.35;

        C = ceil(P) - 0.5,
        C = abs(P - C) - 0.03 - 0.17 * fract(sin(dot(C, R + 71.)) * 1e4),
        t += d = min(max(C.x, max(C.y, C.z)), 0.) + 0.8 * length(max(C, 0.));
    }

    O = t > 0.
        ? vec4(colorForPoint(P), 1.0)
        : O * 0.;
}
