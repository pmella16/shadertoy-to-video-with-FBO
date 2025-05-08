
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec3 inColor = texture2D(iChannel0, uv).xyz;
    float t = iTime;
    
    uv.x *= iResolution.x/iResolution.y;
    uv *= 90.0+5.0;
    float r = distance(uv*sin(iTime*.2), inColor.xy*vec2(sin(t*2.0), sin(t)*.1));
    float g = distance(-uv, inColor.xz*vec2(inColor.x, inColor.y));
    float b = distance(uv, inColor.zy*vec2(r, sin(t)));
    float value = abs(sin(r+t) + sin(g+t) + sin(b+t) + sin(uv.x+t) + cos(uv.y+t));
    value *= 94.0;
    r /= value;
    g /= value/(sin(t)*.5+.5);
    b /= value;
    vec3 rgb = vec3(r,g,b)+(inColor/15.);
    fragColor = vec4 (rgb, 1.0);
}

