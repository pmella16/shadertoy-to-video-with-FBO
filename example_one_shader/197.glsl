vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float rect(vec2 p, vec2 c) {
    p = abs(p)-c;
    return step(length(max(vec2(0.),p)) + min(0., max(p.x, p.y)), 0.);
}

mat2 rot(float a) {
    float s=sin(a);
    float c=cos(a);
    return mat2(c,s,-s,c);
}

#define PI 3.14159265359
float poly(vec2 uv, vec2 p, float s, float dif,int N,float a) {
    vec2 st = p - uv ;
    float a2 = atan(st.x,st.y)+a;
    float r = PI*2. /float(N);
    float d = cos(floor(.5+a2/r)*r-a2)*length(st);
    float e = 1.0 - smoothstep(s,s+dif,d);
    return e;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = (fragCoord.xy / iResolution.xy) - 0.5;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 col = vec3(0.);

    vec3 color;
    
    const float iter = 19.;
    float acumDif = 0.;
    float l2 = 0.;
    for (int i=0; i<int(iter); i++) {

        col = max(col, poly(p, vec2(0.9, 1.72), 0.85, 0.14, 3, 0.5));
        p.x=abs(p.x);
        p*=rot(10.8 + sin(iTime/6.0)) * 0.97;
        p-=vec2(-0.05, 0.45);
        p*=1.15;
        float l = length(p);
        acumDif += abs(l - l2);
        l2 = l;
    }
    
    acumDif /= iter;
    float c = acumDif;
    color = hsv2rgb(vec3(c*c*50., c+0.5, c*c*10.));
    
    if (col.x >= 0.13 || col.y >= 0.15) {
        col = smoothstep(vec3(sin(iTime/2.0)+p.y, col.yz), color, vec3(0.5, 0.6, 0.7));
    } else {
        col /= color;
    }
    
    fragColor = vec4(col, 1.0);
}