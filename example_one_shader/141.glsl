vec3 palette( float t){
    vec3 a = vec3(0.938, 1.048, 0.348);
    vec3 b = vec3(0.748, 0.428, 0.368);
    vec3 c = vec3(-0.822, 0.768, 0.878);
    vec3 d = vec3(-1.062, 0.478, -1.282);
    

    return a + b * cos(6.28318*(c*t+d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord *2.0 - iResolution.xy) / iResolution.y;
    
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 3.0 ; i++){
        
    
        uv *= 2.0;
        uv = fract(uv);
        uv -= 0.5;
    
        float d = length(uv) * exp(-length(uv0));
    
        vec3 col = palette(length(uv0) + iTime);
    
        d -= sin(d*20. + iTime) /1.5;
        d = abs(d);
    
        d= pow(0.05 / d, 1.2);
    
        finalColor += col * d;
    
    }

    fragColor = vec4(finalColor,1.0);
}