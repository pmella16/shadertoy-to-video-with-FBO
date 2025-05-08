#define TAU 6.28318530718

mat2 rotmat(float angle) {
    float cosAngle = cos(angle);
    float sinAngle = sin(angle);

    return mat2(
        cosAngle, -sinAngle,
        sinAngle,  cosAngle
    );
}

vec3 hsvToRgb(vec3 hsv) {
    float c = hsv.y * hsv.z;
    float x = c * (1.0 - abs(mod(hsv.x / 60.0, 2.0) - 1.0));
    float m = hsv.z - c;
    
    vec3 rgb;
    if (hsv.x < 60.0) {
        rgb = vec3(c, x, 0.0);
    } else if (hsv.x < 120.0) {
        rgb = vec3(x, c, 0.0);
    } else if (hsv.x < 180.0) {
        rgb = vec3(0.0, c, x);
    } else if (hsv.x < 240.0) {
        rgb = vec3(0.0, x, c);
    } else if (hsv.x < 300.0) {
        rgb = vec3(x, 0.0, c);
    } else {
        rgb = vec3(c, 0.0, x);
    }
    
    return rgb + vec3(m);
}
float channel(vec2 ndc, float t) {
    float angle = t * 0.05;
    float phase = atan(ndc.y, ndc.x);
    float mag = length(ndc);
    for (float i = 0.0; i < 64.0; i += 1.0) {
        ndc = abs(ndc);
        // ndc = ndc.yx;
        ndc -= 6.0;
        ndc *= 1.06;
        ndc = abs(ndc);
        ndc *= rotmat(angle/(1.0+i));
   }
   return length(ndc);
}

vec3 image(vec2 uv) {
    float x = channel(uv, iTime);
    float h = 10.0*iTime + 360.0*x;
    h = mod(h, 360.0);
    vec3 col = hsvToRgb(vec3(h, 1.0, 1.0));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ndc = fragCoord / iResolution.xy * 2.0 - 1.0;
   fragColor = vec4(
       vec3(image(ndc)),
       1.0
   );
}