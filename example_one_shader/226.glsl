#define PI 3.141592

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float rand(float p)
{
    return fract(sin(p * 1234.4444) * 555.222);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);
    
    float rep = 20.0;
    float r = length(uv);
    // float a = pow(r, -0.2) + iTime * 0.1;
    float a = log(r) - iTime * 0.3;
    a *= rep / PI;
    float ida = floor(a);
    float theta  = atan(uv.y, uv.x);
    float b = theta + sin(iTime + ida * 0.6) * 0.7;
    b *= rep / PI;
    float idb = floor(b);
    vec2 p = vec2(a, b);
    p = fract(p) - 0.5;
    
    // float size = (sin(ida * 0.3) + 1.0) * 0.5 * 0.5;
    float size = 0.4;
    float d = sdBox(p, vec2(size));
    d = max(d, -sdBox(p, vec2(size) - 0.01));
    vec3 col = vec3(smoothstep(0.1, 0.0, d));
    col += vec3(rand(ida) * 0.5);    
    col.r += 0.3;
    col += 1.0 - min(1.0, pow(r, 0.6));
    
    fragColor = vec4(col, 1.0);
}
