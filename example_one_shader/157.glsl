vec3 palette( in float t )
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.1, 0.2);
    return a + b*cos( 6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    float angle = atan(uv.y, uv.x);
    angle = sin(4.0 * (angle - iTime * 0.2));
    angle = angle - 2.0 * length(uv);
    angle += iTime * 0.5;
    vec2 polar = vec2(length(uv), angle);
    uv = vec2(polar.x * cos(angle), polar.x * sin(angle));
    uv = abs(uv);

    vec2 uv0 = uv;
    vec3 col = vec3(0.0);
    
    int steps = 2;
    
    for(int i = 0; i < steps; i++) {
        vec3 col0 = palette(length(uv0) + float(i) * 0.2 + iTime * 0.8);
        
        uv = 2.0 *(fract(uv * 1.5) - 0.5);
        float d = length(uv) * cos(1.5 * (length(uv0) - iTime * 0.6));
        d = sin((d) * 8.0 - iTime * 2.0) / 16.0;
        d = abs(d);
        d = pow(0.015 / d, 1.3);
        d = 0.5 * d / length(uv0);    //glow in center
        d *= pow(2.0, -length(uv0));
 
        col += col0 * d * pow(float(steps - i) / float(steps), 2.0);
    }

    // Output to screen
    fragColor = vec4(col,1.0);
}