



float n21(vec2 p)
{

    p = fract(p * vec2(243.34, 814.73));
    p += dot(p, p + 42.34);
    return fract(p.x * p.y);


}



vec2 n22(vec2 p)
{

    float f = n21(p);
    return vec2(f, n21(p + f));

}


float ldist(vec2 p, vec2 a, vec2 b)
{


    vec2 pa = p - a;
    vec2 ba = b - a;
    
    float t = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * t);
}




vec2 getpos(vec2 id, vec2 offset)
{

    vec2 n = n22(id + offset) * iTime;
    return offset + sin(n) * 0.4;

}



float line(vec2 p, vec2 a, vec2 b)
{


    float d = ldist(p, a, b);
    float m = smoothstep(0.03, 0.01, d);
    float dst = distance(a, b);
    m *= smoothstep(1.2, 0.8, dst) + smoothstep(0.05, 0.03, abs(dst - 0.75));
    return m;

}





float layer(vec2 uv)
{

    float m = 0.0;
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
  
    vec2 p[9];
    
    int i = 0;
    
    for (float y = -1.0; y <= 1.0; ++y)
    {
    
        for (float x = -1.0; x <= 1.0; ++x)
        {
            
            p[i++] = getpos(id, vec2(x, y));
        
        }
    
    }
    
    float t = iTime * 2.0;
    for (int i = 0; i < 9; ++i)
    {
    
        m += line(gv, p[4], p[i]);
        
        vec2 j = (p[i] - gv) * 20.0;
        float sparkle = 1.0 / dot(j, j);
        
        m += sparkle * (sin(t + fract(p[i].x) * 20.0) * -0.5 + 0.5);
    
    }
    
    
    m += line(gv, p[1], p[3]);
    m += line(gv, p[1], p[5]);
    m += line(gv, p[5], p[7]);
    m += line(gv, p[7], p[3]);
    
    
    return m;


}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.x *= (iResolution.x / iResolution.y);
    vec3 col = vec3(0.0);
    
    float m = 0.0;
    float t = iTime * 0.1;
    
    float s = sin(t);
    float c = cos(t);
    
    mat2 rot = mat2(c, -s, s, c);
    uv *= rot;
    
    for (float i = 0.0; i <= 1.0; i += 1.0 / 4.0)
    {
    
        float z = fract(i + t);
        float size = mix(10.0, 0.5, z);
        float fade = smoothstep(0.0, 0.45, z) * smoothstep(1.0, 0.8, z);
        m += layer(uv * size + i * 25.0) * fade;
        
    }
    

    col = vec3(m);
    
    fragColor = vec4(col, 1.0);
}