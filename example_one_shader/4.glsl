void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect_ratio = iResolution.y/iResolution.x;
	vec2 uv = fragCoord.xy / iResolution.x;
    
    //center effect so it's not in bottom left
    uv -= vec2(0.5, 0.5 * aspect_ratio);
    
    
    
    //rotation based on time
    float rot = radians(0. -iTime); // radians(45.0*sin(iTime));
    
    
    
    //rotate the points with matrix
    mat2 rotation_matrix = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
   	uv = rotation_matrix * uv;
    
    
    
    //"zoom" on effect
    vec2 scaled_uv = 33.0 * uv;
    
    
    // get 0.0 - 1.0
    vec2 tile = fract(scaled_uv);
    
    
    
    float tile_dist = min(min(tile.x, 1.0-tile.x), min(tile.y, 1.0-tile.y));
    
    
    float square_dist = length(floor(scaled_uv));
    
    
    
    float edge = sin(iTime-square_dist*20.);
    
    
    
    edge = mod(edge * edge, edge / edge);



    
    float value = mix(tile_dist, 1.0-tile_dist, step(1.0, edge));
    
    
    
    
    edge = pow(abs(1.0-edge), 1.2) * 0.5;
    
    // adds rim to squares
    value = smoothstep( edge-0.1, edge, 0.9*value);
    
    
    value += square_dist*.1;
    value *= 0.6;
    fragColor = vec4(pow(value, 8.1), pow(value, 4.2), pow(value, 1.2), 1.5);
}