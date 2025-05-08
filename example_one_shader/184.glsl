void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float timeRatio = .3;
    float timeFlow = iTime * timeRatio;
    float acidRatio = 5.;
    
    vec3 position = vec3(timeFlow, timeFlow, timeFlow);
    vec3 color = vec3(acidRatio, acidRatio, acidRatio);
    
    for (int i = 0; i < 25; i++) 
    {
        position += vec3(-sin(uv), sin(uv) - cos(uv));
        
    	color += vec3(
            -sin(color.g + sin(position.y)), 
            -sin(color.b + sin(position.z)), 
            -sin(color.r + sin(position.x)) 
        );
    }
    
    color *= color * .005;
    
    fragColor = vec4(color, 1.);
}