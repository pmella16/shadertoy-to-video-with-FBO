vec2 warp(vec2 xy, float scale, float amount) {
    vec2 warp = (sin(iTime) * cos(scale * xy.yx) + cos(iTime) * sin(scale * xy.yx)) / scale;
    warp *= 0.5 * amount;
    return xy + warp;
}

float grid(vec2 xy) {
    xy = abs(mod(xy, 1.0) - 0.5);
    float d = min(xy.x, xy.y);
    return smoothstep(1.0, 0.0, 6.0 * d);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    mat2 rot = mat2(cos(1.0),sin(1.0),-sin(1.0),cos(1.0));
    
    xy = warp(rot * xy, 1.1, 0.2);
    xy = warp(rot * xy, 2.0, 0.4);
    xy = warp(rot * xy, 3.8, 0.6);
    xy = warp(rot * xy, 9.7, 0.8);
    xy = warp(rot * xy, 15.0, 0.8);
    xy = warp(rot * xy, 24.3, 0.6);
    xy = warp(rot * xy, 38.9, 0.4);
    xy = warp(rot * xy, 49.3, 0.2);

    // Time varying pixel color
    vec3 col = vec3(1.0, 0.0, 0.0) * grid(16.0 * xy);

    // Output to screen
    fragColor = vec4(col,1.0);
}