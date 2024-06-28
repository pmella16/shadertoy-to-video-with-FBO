// Fork of "DarkStar" by duo. https://shadertoy.com/view/43y3zd
// 2024-06-11 14:12:06

// Fork of "Wired" by kishimisu. https://shadertoy.com/view/4c2XDc
// 2024-06-11 14:09:12

/* "Wired" by @kishimisu (2024) - https://www.shadertoy.com/view/4c2XDc

   I wonder what it's powering...

   This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
   International License       (https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en)
*/


// customizable color from @WhiteTophat  in https://www.shadertoy.com/view/dlBczW
vec4 lerp(vec4 a, vec4 b, float t) {
    return (a * vec4(t)) + (b * vec4(1.0-t));
}
vec4 lerp(vec4 a, vec4 b, vec4 t) {
    return (a * t) + (b * (vec4(1.0) * t));
}

vec4 hue2rgb(float hue) {
    hue = fract(hue); //only use fractional part of hue, making it loop
    float r = abs(hue * 6.0 - 3.0) - 1.0; //red
    float g = 2.0 - abs(hue * 6.0 - 2.0); //green
    float b = 2.0 - abs(hue * 6.0 - 4.0); //blue
    vec4 rgb = vec4(r,g,b, 1.0); //combine components
    rgb = clamp(rgb, 0.0, 1.0); //clamp between 0 and 1
    return rgb;
}
vec4 hsv2rgb(vec3 hsv) {
    vec4 rgb = hue2rgb(hsv.x); //apply hue
    rgb = lerp(vec4(1.0), rgb, 1.0 - hsv.y); //apply saturation
    rgb = rgb * hsv.z; //apply value
    return rgb;
}
 
 vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}


#define r(a) mat2 (cos(a + vec4(0,33, 11,0)));
#define R(p, T) p.yx *= r(myround((atan(p.y, p.x) + T) * 1.91) / 1.91 - T)
void mainImage(out vec4 O, vec2 F) {
    float i, t = 0.0, d, k = iTime / 8.0;


vec2 mouseUV = vec2 (0,0);

    O = vec4(0.0);
    vec2 R = iResolution.xy;
    vec3 p;

    for (i = 0.0; i < 30.0; i++) {
        p = vec3(F + F - R, R.y);
        p = normalize(p) * t;
        p.z -= 3.0;
        p.xz *= r(k + 0.1);
        p.zy *= r(k + k);
        d = length(p)- sin(k + k) * .5 - 0.4;

        p.y += sin(p.x * cos(k + k) + k * 4.0) * sin(k) * 0.3;
        R(p.xy, 0.0);
        R(p.xz, k);
        p.x = mod(p.x + k * 8.0, 2.0) - 1.0;
        t += d = min(d, length(p.yz) - 0.03) * 0.5;

        O += 0.01 * (cos(t - k + vec4(0, 1, 3, 0))) / (length(p) - 0.02) + (0.025 + sin(k) * 0.01) / (0.8 + d * 24.0);
    }

    O = fract(O+ hsv2rgb(p+t*sin(iTime)*(mouseUV.x/sin(mouseUV.y))) +(iTime/10.));

}
