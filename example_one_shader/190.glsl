// The idea of this shader is not new, i created and modified it while learning raymarching.
// The shader is inspired by the two users iq (https://www.shadertoy.com/user/iq) 
// and kishimisu (https://www.shadertoy.com/user/kishimisu).
// -----------------------------------------------------------
// The Internet-Sources are:
// https://iquilezles.org/articles/distfunctions/
// https://www.youtube.com/watch?v=khblXafu7iA
// -----------------------------------------------------------
// ps: you can use the mouse to rotate the camera
// -----------------------------------------------------------

// Here is something to play with:

// Set background rotation
const bool rotateBackground = true;
// Set cube scaling:
float cubeScaling = 7.0;
// Set the iteration count for the raymarching here:
int iterations = 160;
//--------------------------------------------------

float sdSphere(vec3 p, float s) {
    return length(p) - s;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float smin(float a, float b, float k) {
    float h = max(k-abs(a-b), 0.0) / k;
    return min(a, b) - h*h*h*k*(1.0/6.0);
}

mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

float map(vec3 p, vec3 ro) {
    float dx = 0.;
    float dz = (iTime) * 5.4;

    p.x += dx;
    p.z += dz;
   
    vec3 spherePos1 = vec3(ro.x + dx, ro.y + sin(iTime) * 2., ro.z + dz + 5.);
    float sphere1 = sdSphere(p - spherePos1, 1.);
    
    vec3 spherePos2 = vec3(ro.x + dx, ro.y + sin(iTime) * 2., ro.z + dz - 5.);
    float sphere2 = sdSphere(p - spherePos2, 1.);
    
    vec3 q = p; // copy
    
    q.x -= sin(iTime + q.y + q.z) * 0.4;
    q = fract(q) - .5;
    q.xy *= rot2D(iTime);
    q.yz *= rot2D(sin(iTime + q.y + q.z) * 0.4);
    
    float box = sdBox(q * cubeScaling, vec3(.75)) / cubeScaling;
    float spheres = smin(sphere1, sphere2, 2.0);
    return smin(spheres, box, 2.);
}

// hsv2rgb_smooth from user iq, found on https://www.shadertoy.com/view/MsS3Wc
vec3 hsv2rgb_smooth(in vec3 c) {
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing	
	return c.z * mix( vec3(1.0), rgb, c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    vec2 m = vec2(cos(iTime*.2), sin(iTime*.2));
    
    vec3 rayOrigin = vec3(0, 0, -5);
    vec3 rayDirection = normalize(vec3(uv, 1. + 0.5 * (sin(iTime)+1.)*0.25));
    vec3 col = vec3(0);
    
    float t = 0.;
    
    if (rotateBackground) {
        rayOrigin.xz *= rot2D(-m.x);
        rayDirection.xz *= rot2D(-m.x);
    }
    
    for (int i = 0; i < iterations; i++) {
        vec3 p = rayOrigin + rayDirection * t;
        
        p.xy *= rot2D(t*.2 * m.x);
        p.y += sin(t*(m.y+1.)*.5)*.35;
        
        float dist = map(p, rayOrigin + rayDirection);
        t += dist; 
        col += vec3(i) / (float(iterations) * 10.);
        if (dist < .001 || t > 200.) break;
    }
    
    float negator = 1.;
    
    
    vec3 colors = hsv2rgb_smooth(rayDirection);
    fragColor = 
        vec4(t * negator * colors.x * 0.25 - negator, 
             ((col.y - 0.5) + rayDirection.z * 0.5) * colors.y, 
             ((col.z - 0.5) + rayDirection.x * 0.45) * colors.z, 
             0);
}
