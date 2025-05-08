#define PI 3.1415927

#define INSPIRATION false

vec2 rotate(vec2 point, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    mat2 rotationMatrix = mat2(c, -s, s, c);
    return rotationMatrix * point;
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.283185*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv-=0.5;
    uv*=2.0;
    uv.y*=iResolution.y/iResolution.x;
    vec2 uv0 = uv;
    float a0 = atan(uv.y/uv.x);
    float a = step(0.5, sin(160.*a0));
    float r = 1.0-step(0.4+.05*sin(30.*a0+iTime), length(uv));    
    vec3 col = vec3(0.);
    if (INSPIRATION){
        col = vec3(step(0.3, length(uv0)));
        col *= vec3(1.0-(r*sin(1.*a)));
        //col = mix(vec3(1.0), vec3(0.0), col);

        //col = palette(0.75*length(1.*uv0)/length(col), vec3(0.5), vec3(0.5), vec3(2.5), iTime*vec3(0.67, 0.45, 0.12));
    } else {
        col = vec3(step(0.3, length(uv0)));
        col += 0.5*vec3(1.0-(r*sin(1.*a)));
        col = mix(vec3(1.0), vec3(0.0), col);
        col = palette(a*0.75*length(1.*uv0)/length(col), vec3(0.5), vec3(0.5), vec3(2.5), iTime*vec3(0.67, 0.45, 0.12));

        //vec3 col = vec3(step(0.3, length(uv0)));
        col *= vec3(1.0-(r*sin(1.*a)));
        col = mix(vec3(1.0), vec3(0.0), col);

        col = palette(0.75*length(1.*uv0)/length(col), vec3(0.5), vec3(0.5), vec3(2.5), iTime*vec3(0.67, 0.45, 0.12));
    } 
    
    // Output to screen
    fragColor = vec4(col,1.0);
}