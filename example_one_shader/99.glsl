void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Aspect-corrected uvs within [-1, -1] to [1, 1]
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / min(iResolution.y, iResolution.x);
    
    // Rotate uvs
    uv = mat2(cos(iTime), -sin(iTime), sin(iTime), cos(iTime)) * uv;
    
    // Cast a ray in the direction of the current pixel
    vec3 rayDirection = normalize(vec3(uv, 1.0));
    
    // How "stretched" our rays are
    float distance = 1.0;
    
    // Base color
    vec3 color = vec3(0.0);
    
    for (int i = 0; i < 100; i++) 
    {
        // Move "distance" units in the current direction
        vec2 rayPosition = rayDirection.xy * distance;
        
        // This is really hard to visualize. Graph sin & cos with different frequencies (ie sin(x * 2), sin(x * 4), etc) to better understand this
        float sceneDist = sin(rayPosition.x * 3.14 + iTime) + cos(rayPosition.y * 3.14);
        
        // Blend between foreground (magenta) & background (dark grey) based on dampened distance from screen centre to current pixel
        float t = smoothstep(0.0, 0.1,  abs(sceneDist) * 0.05);
        color += mix(vec3(0.1, 0.1, 0.1), vec3(1.0, 0.0, 1.0), t);
        
        // Rate at which we spread our rays
        distance += 0.5;
        
        // The closer to 0, the more we repeat
        if (abs(sceneDist) < 0.15) 
        {
            break;
        }
    }
    
    // Fades colour
    color *= 0.5 + 0.5 * sin(iTime);

    fragColor = vec4(color, 1.0);
}