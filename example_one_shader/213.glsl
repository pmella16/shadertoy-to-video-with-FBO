


mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

const float pi = acos(-1.0);
const float pi2 = pi * 0.5;

vec2 pmod(vec2 p, float r) {
    float a = atan(p.x, p.y) + pi / r;
    float n = pi2 / r;
    a = floor(a / n) * n;
    return p * rot(-a);
}

float box(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float ifsBox(vec3 p) {
    for (int i = 0; i < 2; i++) {
        p = abs(p) - 0.15;
       
    }
    return box(p, vec3(2.5, 2.5, 2.5));
}

float hole(vec3 p, float radius) {
    return length(p.xy) - radius;
}

float map(vec3 p, vec3 cPos) {
    vec3 p1 = p;
    p1.x = mod(p1.x - 10.0, 20.0) - 10.0;
    p1.y = mod(p1.y - 10.0, 20.0) - 10.0;
   
     p1.xy *= rot(iTime * 1.1); // Rotate with time for animation
     
    // Oscillating pmod with time-based rotation
    float rotationAngle = sin(iTime) * 0.5; // Rotate back and forth between -0.5 and 0.5
  
    float d = ifsBox(p1);
    float holeDist = hole(p1, 1.5);
    return min(d, holeDist);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float loopTime = 16.0;
    float time = mod(iTime, loopTime);

    vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
  vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
  

    // Polar coordinates
    float radius = length(uv);
    float angle = atan(uv.y, uv.x);

    // ----- Parameters -----
    float waveFrequency = 20.0;
    float angleTwist = 14.0;
    float speed1 = 0.5;
    float speed2 = 0.3;
    float brightness = 0.9;
    float baseLight = 0.2;
    // ----------------------

    // Hue for color variation
    float huy = sin(radius * waveFrequency - iTime * speed1)
              + cos(angle * angleTwist + iTime * speed2);

    // Rainbow coloring
    // Camera setup
    vec3 cPos = vec3(0.0, 0.0, -1.0+iTime);
    vec3 cDir = normalize(vec3(0.0, 0.0, 5.0)); 
    vec3 cUp = vec3(sin(iTime * 0.25), cos(iTime * 0.5), .0);

    vec3 cSide = cross(cDir, cUp)/huy;
    vec3 ray = normalize(cSide * p.x + cUp * p.y + cDir);

    // Raymarching
    float acc = 1.0;
    float acc2 = 1.0;
    float t = 10.0;
    for (int i = 1; i < 39; i++) {
        vec3 pos = cPos + ray * t/huy;
         pos.x+=cos(iTime);
  pos.y+=sin(iTime);
        float dist = map(pos, cPos);
        dist = max(abs(dist), 0.03);
        float a = exp(-dist * 10.0);
        if (mod(length(pos) + 10.0 * iTime, 15.0) < 3.0) {
            a *= 2.0 + sin(iTime * 1.0);
            acc2 += a;
        }
        acc += a;
        t += dist * 0.5;
    }

    // Reduced frequency glow (slower oscillation)
    float glow = exp(-t * 0.15) * (1.0 + 0.25 * sin(iTime * 0.25)); // slower oscillation

    // RICH COLOR PALETTE BLEND
    vec3 palette1 = vec3(0.9, 0.3, 0.6); // magenta pink
    vec3 palette2 = vec3(0.2, 0.9, 1.0); // cyan blue
    vec3 palette3 = vec3(1.0, 1.0, 0.2); // yellow
    vec3 palette4 = vec3(1.0, 0.4, 0.0); // orange
    vec3 palette5 = vec3(0.5, 0.0, 1.0); // purple
    vec3 palette6 = vec3(0.0, 1.0, 0.5); // green

    // Generate a dynamic color palette shift across multiple colors
    float paletteMix = 0.5 + 0.5 * sin(iTime * 1.5 + p.x * 0.1); // Add spatial variation
    vec3 flashColor = mix(palette1, palette2, paletteMix);
    flashColor = mix(flashColor, palette3, paletteMix * 0.5);
    flashColor = mix(flashColor, palette4, paletteMix * 0.3);
    flashColor = mix(flashColor, palette5, paletteMix * 0.8);
    flashColor = mix(flashColor, palette6, paletteMix * 0.6);

    // Final color mix (increased brightness)
    vec3 col = (glow * 0.5 + flashColor * 3.0) * vec3( // increased glow and flashColor brightness
        acc * 0.04,
        acc * 0.025 + acc2 * 0.02,
        acc2 * 0.035
    );

    // Atmospheric fog
    vec3 fogColor = vec3(0.12, 0.08, 0.18);
    col = mix(fogColor, col, exp(-t * 0.010));

    // Vignette
    float vignette = 1.0 - 0.3 * smoothstep(0.3, 1.0, length(p));
    col *= vignette;

    // Output
    col = pow(col, vec3(1.0));
    float alpha = 1.0 - smoothstep(0.0, 0.7, t * 0.1);
    fragColor = vec4(col, alpha);
}