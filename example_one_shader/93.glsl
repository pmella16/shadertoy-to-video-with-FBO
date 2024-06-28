#define PI acos(-1.0)
//Licence: Do what you want with this, but give me a shout out if you use it.

//This is a recreation of something I did in SpiralGraphics Genetica a long time ago.



float conicalGradient(vec2 uv) {

    vec2 center = vec2(0,0);
    uv -= 0.5;
    uv *= 2.0;
    uv.x *= iResolution.x / iResolution.y;
    vec2 offset = uv - center;
    return atan(-offset.y, -offset.x) / (2.0 * PI) + 0.5;
}

float radialGradient(vec2 uv) {

    vec2 center = vec2(0,0);
    uv -= 0.5;
    uv *= 2.0;
    uv.x *= iResolution.x / iResolution.y;
    vec2 offset = uv - center;
    return length(offset);
}



float applyFrequency(float value, float frequency, float amplitude) {
    return sin(value * frequency) * amplitude;
}


vec3 conicalColor (vec2 uv)
{
    float conical = conicalGradient(uv);

    vec3 col = vec3(1.0-conical,0,0);
    return col;
}

vec3 radialColor (vec2 uv)
{
    float radial = radialGradient(uv);

    vec3 col = vec3(1.0-radial,0,0);
    return col;
}




//frequncy similar to genetica's frequency function
vec3 frequency(float gradient, float frequency, float amplitude, float phase) {

 
    // Apply the frequency effect
    float freqEffect = applyFrequency((gradient * 2.0 * PI) + phase, frequency, amplitude);
    
    // Mixing the conical gradient with the frequency effect
    // The 0.5 offsets the sine wave to only get positive values
    float combined = 0.5 + 0.5 * freqEffect;

    vec3 col = vec3(1.0 - combined, 0, 0);
    return col;
}

float moire(vec2 uv, float time, float angleOffset, float rotationSpeed)
{

    // Convert cartesian to polar coordinates
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    float ringQuantity = 1.;
    float radialGrowthSpeed =  1.0;

    // Function to create the moiré pattern
    float moire = sin(6.0 * (angle + angleOffset) + rotationSpeed * time) * cos(ringQuantity * radius - radialGrowthSpeed * time);

    return moire;
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    //vec2 tileduv = tile(uv);

    vec3 color = conicalColor(uv);
    vec3 color1 = radialColor(uv);
        
    color = frequency(color.r, 6.0, 1.0, 0.27);
    color1 = frequency(color1.r, 2.0, 1.0, iTime/2.0);
    
    vec2 newUv = vec2(color.r,color1.r);
    float moire = moire(newUv, 1.0 ,0.0, 1.0);
    
    vec3 color2 = vec3(1.0,0.0,0.0);
    // Combine the moire pattern with the color gradient
    float remapped= 0.5 + 0.5 * moire;
    
    color2.r = remapped;

    
    
    // Output to screen
    fragColor = vec4(color2,1.0);
}