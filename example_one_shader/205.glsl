#define PI 3.1415926
#define STEPS 100
#define R iResolution.xy


vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}



float SDF(vec3 pos) {
    vec3 roundedPos = myround(pos);
    return smoothstep(distance(pos, ceil(pos))-0.1, distance(pos, myround(pos))-0.4, 0.2+sin(iTime)*0.1);
}

vec3 rayMarching(vec2 uv) {
    vec3 cameraPos = vec3(1.3,0., -10000.+iTime*.5);
    vec3 f = normalize(-cameraPos);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = normalize(cross(f, r));
    vec3 rayDir = normalize(r * uv.x + u * uv.y + f);
    vec3 cubePos = vec3(0., 1.5, 0.);
    float traveled = 0.;
    for(int i = 0; i < STEPS; i++) {
        float dist = SDF(cameraPos + traveled * rayDir - cubePos);
        if(dist < 0.0001) {
            return vec3(dist, dist*abs(sin(iTime*PI))*9242.1, dist*9125.);
        }
        traveled += dist;
        if (traveled > 100.) {
            break;
        }
    }
    //return vec3(0.);
    return vec3(fract(traveled*0.1), fract(traveled*0.1), fract(traveled));
}

void mainImage(out vec4 fragColor, in vec2 u) {
    vec2 uv = (u + u - R) / R.y;
    fragColor = vec4(rayMarching(uv), 1.);
}
