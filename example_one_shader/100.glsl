mat2 RM2D(float a)
{
    return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float aperiodicSin(float x)
{
    float eOver2 = 1.3591409;
    float pi = 3.141592;
    return sin(eOver2 * x + 1.04) * sin(pi * x);
}

float FBM(vec2 uv)
{
    vec2 n, q, u = vec2(uv-.5);
    float centeredDot = dot(u,u);
    float frequency = 15. - (0.5 - centeredDot) * 9.0;
    float result = 0.;
    mat2 matrix = RM2D(5.);

    for (float i = 0.; i < 19.; i++)
    {
        u = matrix * u;
        n = matrix * n;
        q = u * frequency + iTime * 4. + aperiodicSin(iTime * 1.5 -centeredDot * 1.7) * 0.8 + i + n;
        result += dot(cos(q) / frequency, vec2(2., cos(q.y)));
        n -= sin(q);
        frequency *= 1.2;
    }
    return result;
}

float CalculateDiffuseLight(vec3 normal, vec3 lightDirection)
{
    float brightnessHarshness = 20.72;
    float maxBrightness = 0.3;
    return pow(max(dot(normal, lightDirection), 0.0), brightnessHarshness) * maxBrightness;
}

float CalculateSpecularLight(float maxSpeckleInfluence, vec3 normal, vec3 lightDirection, vec3 currentPosition)
{
    float speckleFrequency = 0.9;
    float shininess = 72.075;
    vec3 lightSource = vec3(0.9, 0.1, 1.0);
    vec3 reflectedDirection = reflect(-lightDirection, normal);  
	vec3 viewDirection = normalize(lightSource - currentPosition);
    float speckleInfluence = pow(abs(cross(reflectedDirection, viewDirection).z), 1.0 / speckleFrequency) * maxSpeckleInfluence;
    return pow(max(dot(viewDirection, reflectedDirection), 0.0), shininess) + speckleInfluence;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Calculate the UVs of the fragment, correcting the aspect ratio in the process.
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.xx + 0.5;
    uv = (uv - 0.5) * 1.3 + 0.5;
    
    // Calculate the base noise value from the FBM. This may initially be outside of the traditional 0-1 range of values.
    float noise = FBM(uv);
    float originalNoise = noise;
    
    // Clamp the noise to a 0-1 range.
    noise = clamp(noise, 0.0, 1.0);
    
    // Store the current position UVs as a vector3 instead of a vector2.
    vec3 currentPosition = vec3(uv, 0.0);
    
    // Calculate the base light values for diffuse lighting.
    vec3 lightSource = vec3(0.76, 0.7, -1.0);
    vec3 lightDirection = normalize(currentPosition - lightSource);
    
    // Calculate fluid noise values that give texture to the dark parts of the texture.
    float fluidViscosity = 681.72;
    float fluidNoiseAngle = originalNoise * 13.05 + iTime * 0.78;
    vec2 fluidOffset = vec2(cos(fluidNoiseAngle) + originalNoise * 14.0, sin(fluidNoiseAngle) + iTime * 5.5) / fluidViscosity;
    float fluidNoise = 0.0;
    noise += fluidNoise * smoothstep(0.3, 0.15, noise);
    
    // Calculate the normal of the current pixel based on the derivatives of the noise with respect to both spatial axes.
    vec3 normal = normalize(vec3(dFdx(noise), dFdy(noise), clamp(originalNoise * 0.01, 0.0, 1.0)));
    
    // Calculate brightness, using both specular and diffuse lighting models.
    float maxSpeckleInfluence = pow(0.1 / distance(uv, vec2(0.5)), 1.6);
    if (maxSpeckleInfluence > 0.37)
        maxSpeckleInfluence = 0.37;
    
    float brightness = CalculateDiffuseLight(normal, lightDirection) + CalculateSpecularLight(maxSpeckleInfluence, normal, lightDirection, currentPosition);
    
    // Combine the brightness and noise values into a single coherent color.
    noise += brightness;
    
    fragColor = vec4(noise * 1.11, 0.02, noise * 0.2, 1.0);
    fragColor += vec4(brightness * 0.5, brightness, brightness, 0.0);
}