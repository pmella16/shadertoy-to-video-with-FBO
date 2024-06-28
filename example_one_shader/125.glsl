float sdSphere(vec3 o, float r, vec3 p) { return length(p-o)-r; }
float sdBox(vec3 o, vec3 r, vec3 p) {
    vec3 q = abs(p-o)-r;
    return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.);
}
vec3 rotated_x(vec3 v, float a) {
    return vec3(
        v.x,
        (v.y*cos(a)) - (v.z*sin(a)),
        (v.y*sin(a)) + (v.z*cos(a))
    );
}
vec3 rotated_y(vec3 v, float a) {
    return vec3(
        (v.x*cos(a))+(v.z*sin(a)),
        v.y,
        (v.z*cos(a))-(v.x*sin(a))
    );
}
vec3 rotated_z(vec3 v, float a) {
    return vec3(
        (v.x*cos(a))+(v.y*sin(a)),
        (v.y*cos(a))-(v.x*sin(a)),
        v.z
    );
}

vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}
float map(vec3 p) {
    float b1 = sdBox(vec3(0), vec3(.1), p-myround(p));
    return b1;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 rep = vec2(1.0);
    float pi = 3.141592653;
    
    // normalizing and fractionating space
    vec2 uv = fragCoord.xy/iResolution.xy;
    uv = fract(uv*rep);
    uv = uv * 2.0 - 1.0;
    uv.x *= (iResolution.x*rep.y) / (iResolution.y*rep.x);

    // vec3 ro = vec3((cos(iTime)+1.)/2., (sin(iTime)+1.)/2., -3.+fract(iTime));
    vec3 ro = vec3(.5, .5, fract(iTime/1.5));
    vec3 rd = normalize(vec3(uv, 1));
    // rd = rotated_z(rd, iTime/10.);
    rd = rotated_x(rd, (-iMouse.y/iResolution.y+.5)*(pi/2.));
    rd = rotated_y(rd, (iMouse.x/iResolution.x-.5)*(pi/2.));

    float t = 0.0;
    float i;
    float a;
    for (i = 0.0 ; i < 50.0 ; i++) {
        a = map(ro);
        ro += rd*a;
        t += length(rd*a);
        if (a < 0.0000001 || t > 100.0) break;
    }

    fragColor = vec4(t/10.);
}
