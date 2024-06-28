mat2 rot2D(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

vec3 palette(in float t)
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 0.0);
    vec3 d = vec3(0.50, 0.20, 0.25);
    
    return a + b*cos( 6.28318*(c*t+d) );
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float smin( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*h*k*(1.0/6.0);
}

float map(vec3 p)
{
    // vec3 spherePos = vec3(sin(iTime) * 3., 0., 0.); // sphere position
    // float sphere = sdSphere(p - spherePos, 0.); // sphere SDF, translated (translated by negative spherePos because we are essentially moving the ray origin to the left)
    
    vec3 q = p; // position to be used by each instance of the shape
    
    q.y -= iTime * 0.6;
    
    q = fract(q) - .5;
    q.xy *= rot2D(iTime); // uses 2x2 matrix but can stack concat multiple rotations
    q.xz *= rot2D(iTime); // swizzle vec3 to exclude the axis of rotation
    
    float negativeSphere = sdSphere(q, 0.16);  // sphere to be subtracted from the cube
    float box = sdBox(q * 4., vec3(0.5)) / 4.; // just as before, scaling is applied inversely.
                                               // the resulting float is scaled by inverse to
                                               // maintain correct SDF
    
    float ground = p.y + .75; // ground plane
    
    return smin(ground, max(-negativeSphere, box), 0.9); // objects are combined using min(d1, d2), subtracted using max(-d1, d2)
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    vec2 m = (iMouse.xy * 2. - iResolution.xy) / iResolution.y;
    
    // initialisation
    vec3 ro = vec3(0., 0., -3.); // ray origin
    vec3 rd = normalize(vec3(uv, 1.)); // ray direction (normalised)
    vec3 col = vec3(0.);
    
    float t = 0.; // total distance travelled
    
    /*
    // mouse control (vertical)
    ro.yz *= rot2D(-m.y);
    rd.yz *= rot2D(-m.y);
    
    // mouse control (horizontal)
    ro.xz *= rot2D(-m.x);
    rd.xz *= rot2D(-m.x);
    */
    
    // raymarching
    int i;
    for (i = 0; i < 80; i++)
    {
        vec3 p = ro + rd * t;
        
        float d = map(p);
        t += d;
        
        if (d < .001 || t > 100.)
            break;
    }
    
    col = palette(t * 0.05 + float(i) * .003);
    
    fragColor = vec4(col, 1.0);
}