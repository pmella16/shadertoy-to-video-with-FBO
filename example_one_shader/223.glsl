float pi = 3.14159;
//d1 metric
float d1(vec2 point)
{
    return abs(point.x) + abs(point.y);
}

vec3 pallete( float t )
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(1.5, 0.3, 1.5);
    vec3 c = vec3(1., 1., 1.);
    vec3 d = vec3(0.136, 0.416, 0.557);
    
    return a + b*cos( 1. * pi *(c*t+d) );
}


vec3 ifs_color, ro, color, id;
float ifs_scale = 1.7, obj=0.;
mat2 rot(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}

vec2 hexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866,0.5,0.577);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return p; //length(p)*sign(p.y); //return the transformed p instead of distance
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //normalize and centralize coordinates
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec2 uv2 = fragCoord / iResolution.xy;
    vec2 centeredUV = uv2 * 2.0 - 1.0;
    centeredUV.x *= iResolution.x / iResolution.y;

    float t = iTime*0.5;

    // Firework burst origin
    vec2 center = vec2(0.0);

    // Direction and distance from center
    vec2 dir = centeredUV - center;
    float dist = length(dir*.5);
    float angle = atan(dir.y, dir.x);

    // === Stronger UV Distortion ===
    float burst = sin(angle * 12.0 + t * 6.0) * 0.15;      // was 0.08
    float ripple = sin(dist * 30.0 - t * 12.0) * 0.3;     // was 0.015
    float warp = burst + ripple + 5.;

    vec2 distortedUV = uv2 + normalize(dir) * warp * smoothstep(1.0, 0.0, dist);

    

    // === Particle Fireworks with Blur ===
    vec3 particleColor = vec3(0.0);
    float particleCount = 0.0;
    for (float i = 0.0; i < particleCount; i++) {
        float a = i * 6.283185 / particleCount;
        vec2 pDir = vec2(cos(a), sin(a));
        float speed = 0.4 + 0.6 * sin(i + t * 0.5);
        vec2 pPos = center + pDir * t * 0.25 * speed;

        // Convert to UV space
        vec2 screenPos = pPos;
        screenPos.x /= iResolution.x / iResolution.y;
        vec2 screenUV = screenPos * 0.5 + 0.5;

        float d = length(uv - screenUV);

        // Smaller, blurrier particles
        float glow = exp(-pow(d * 200.0, 1.5)); // exponential falloff
        vec3 col = vec3(1.0, 0.6 + 0.4 * sin(i + t * 2.0), 0.3 + 0.7 * sin(i + t));

        particleColor += col * glow;
    }

vec3 r2 = normalize(vec3(uv.xy, 1.0 - dot(uv.xy, uv.xy) *12.3));
r2.x+=cos(iTime);
r2.y+=sin(iTime);
    // Final color blend
    vec3 finalColor2 =  particleColor;
    vec3 finalcolor = vec3(0.);
    uv+=distortedUV-0.5;
    //recursion
    for (float i = 0.; i < 4.; i++)
    {
        uv.xy= hexagon( uv.xy,0.15);
    uv.xy+= hexagon(r2.xy,0.15);
        //repeat coords
        uv = fract(uv*pow(pi/2.2,i)) - 0.5;
    
        //distorted lenght according to d1 metric
        float d = d1(uv) * exp(-length(uv0) * (sin(iTime*2.8)/2.+0.5) ) * pow((sin(iTime*1.3)/4. + .75),1.1) ;
    
        //base color
        vec3 col = pallete(d1(uv0) + i*.4 +iTime*.3);
    
        //shrinking effect in relative space
        d = sin(d * 8. + iTime) / 8.;
        d = abs(d);
    
        //neon effect with extra saturation
        d = pow(0.01/(d),1.3);
    
        //add color
        finalcolor += col * d+ finalColor2;
    }
    
    
    fragColor = vec4(finalcolor,1);
}