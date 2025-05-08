// Jaggies: Triangle wave interference patterns 
//
// Creative Commons Attribution-NonCommercial-ShareAlike      //   //
// 3.0 Unported License                                       //  //
//                                                            // //
// by Val "valalalalala" GvM 💃 2025


vec2 toUv(vec2 at) {
    return (at * 2. - iResolution.xy) / min(iResolution.x, iResolution.y);
}
vec2 moose() {
    return toUv(iMouse.xy) * step(3e-3, iMouse.z + iMouse.w);
}


const float BIG = 99733., FIG =  15873., TAU = 99733. / 15873.;
const vec3 GIG = vec3(TAU, BIG / TAU, FIG / TAU);

float triangle(float f) {
    return abs(fract(f)-.5);
}
vec2 triangle(vec2 v) {
    return vec2(triangle(v.x), triangle(v.y));
}
vec3 triangle(vec3 v) {
    return vec3(triangle(v.x), triangle(v.y), triangle(v.z));
}
float magicFloat( vec2 uv ) {
    return dot(uv, GIG.xy);
}
float hash( float f ) {
    return fract(triangle(f * GIG.x) * f * GIG.z * .1331 );
}
float hash(vec2 uv) { 
    return hash(magicFloat(uv));
}
float atanA(float f) {
  float x = fract(f) * 2.0 - 1.0;
  return x / (abs(x) + 1.0);
}
float atanB(float f, float k) {
    return (fract(f) - 0.5) / (abs(fract(f) - 0.5) + k);
}
float atanC(float f) {
    return (fract(f) - 0.5) / (1.0 + fract(f) * (1.0 - fract(f)));
}
vec3 pow3(vec3 v, float f) {
    return vec3(pow(v.x, f), pow(v.y, f), pow(v.z, f));
}
void mainImage(out vec4 to, in vec2 at) {
    vec2 uv = toUv(at);

#if 1
    vec2 ms = moose();
    float a = atanB(uv.x/uv.y + iTime *.1, ms.x); 
    float d = dot(uv,uv) * 1.1;
    vec2 tv = vec2(triangle(a) * d, triangle(a+.55) * d);
    uv = mix(uv,tv, ms.y);
#endif

    float t = iTime *.0330;
    vec2 nm = 23.32 * triangle(vec2(t, t +.55));
    vec2 ur = vec2(
        uv.x * nm.x + triangle(uv.y * nm.y),
        uv.y * nm.x + triangle(uv.x * nm.y)
    );
    
    float id = abs(hash(floor(ur)));
    vec3 color = vec3(id, 1.-id, id * .77 + .33);
    
    vec2 ov = triangle(ur);
    vec2 sm = smoothstep(ov, vec2(.030),vec2(.0));

    color *= mix(1.,.2, min(ov.x,ov.y));
    
    float s = 1.1 + triangle(iTime*.0220) * 7.7;
    color = pow3(color, s-sm.x*sm.y);
  
    to = vec4(color, 1.);
}

