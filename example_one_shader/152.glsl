float box(vec3 p, vec3 r) {
    p = abs(p) - r;
    p = p + tan((p + r) * 0.7);
    return max(max(p.x, p.y), p.z);
}

float sdf(vec2 uv) {
    vec3 dir = normalize(vec3(uv, abs(uv.y) + length(uv)));
    float l = atan(uv.y, uv.x) * 3.0 - length(uv);
    dir = cos(l - iTime) * dir + sin(l - iTime) * vec3(-dir.y, dir.x, dir.z);
    dir.yx = cos(-iTime + dir.y) * dir.xz + sin(-iTime * 1.3 - dir.x) * vec2(-dir.z, dir.x);
    
    float d = box(dir + vec3(uv, length(uv) * 0.2), cos(dir));
    return d;
}

vec3 hue_shift(vec3 col, float hue) {
    return mix(vec3(dot(vec3(0.333), col)), col, cos(hue)) + cross(vec3(0.577), col) * sin(hue);
}

vec3 get_normal(vec2 uv) {
    vec2 e = vec2(1.0 / sqrt(sqrt(sdf(uv))), length(uv) * 0.1);
    float nx = (sdf(uv - e.xy) - sdf(uv + e.xy)) / (2.0 * e.x);
    float ny = (sdf(uv - e.yx) - sdf(uv + e.yx)) / (2.0 * e.x);
    vec3 n = normalize(vec3(nx, ny, -1.));
    return n;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float mr = min(iResolution.x, iResolution.y);
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / mr * 3.0;
    uv /= pow(dot(uv, uv), 0.8);
    
    float d = sdf(uv) * 0.2;
    vec3 n = abs(get_normal(uv)) / (1.0 + 0.5 * sqrt(length(uv)));
    vec3 col = smoothstep(n, n + cos(n - vec3(2, 3, 1) + 1.5), vec3(hue_shift(n, d - iTime)));
    col.gb = col.bg;
    col = sqrt(sqrt(abs(col)));
    col = cos(col * cos(vec3(d*d, d - col.b, 2.5)) + 0.5 + col.b * 0.3);
    col = hue_shift(col, d);
    fragColor = vec4(col,1.0);
}