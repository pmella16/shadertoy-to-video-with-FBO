void mainImage(out vec4 o, vec2 u)
{
    o.xyz = iResolution;
    u = (u+u-o.xy)/o.y;
    o -= o;
    
    // RGB offsets for color separation
    vec2 rOffset = vec2(0.01, 0.005) * sin(iTime * 0.2);
    vec2 bOffset = vec2(-0.01, -0.005) * sin(iTime * 0.2);
    
    // Red channel
    vec2 uR = u + rOffset;
    for (float i = 0.0; i++ < 7.0; uR /= 0.998)             
        o.r += 0.7/i/length(exp(-9.0*cos(i/(0.3+uR*uR) + iTime*0.9)) 
                          + tan(o.r*5.0-iTime/i)              
                          + tan(uR/i)*i/2.0);
    
    // Green channel (original)
    vec2 uG = u;
    for (float i = 0.0; i++ < 7.0; uG /= 0.998)             
        o.g += 0.7/i/length(exp(-9.0*cos(i/(0.3+uG*uG) + iTime)) 
                          + tan(o.g*5.0-iTime/i)              
                          + tan(uG/i)*i/2.0);
    
    // Blue channel
    vec2 uB = u + bOffset;
    for (float i = 0.0; i++ < 7.0; uB /= 0.998)             
        o.b += 0.7/i/length(exp(-9.0*cos(i/(0.3+uB*uB) + iTime*1.1)) 
                          + tan(o.b*5.0-iTime/i)              
                          + tan(uB/i)*i/2.0);
    
    // Enhance colors with subtle hue shifting
    o.rgb *= vec3(1.2, 1.1, 1.3); // Boost individual channels differently
    o.rgb = mix(o.rgb, vec3(
        sin(iTime*0.2)*0.2 + 0.8,
        cos(iTime*0.15)*0.2 + 0.8,
        sin(iTime*0.1)*0.2 + 0.8
    ), 0.2); // Subtle color modulation over time
}