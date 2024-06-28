
#define PI 3.141592653589793

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= (iResolution.x / iResolution.y);
    
    vec3 color = vec3(0.0);
    
    float accumul = 0.0;
    float num = 0.0;
    uv.x = abs(uv.x);
    
    uv = vec2(length(uv), clamp(atan(uv.y, uv.x), -2.0 * PI, PI * 2.0));
    
    float t = iTime * 0.1;
    
    for (float i = 0.0; i < 7.0; ++i)
    {
      
        accumul += 0.25 * sin(t);
        num += 1.0;
        
        float ampl = 1.0 + (accumul / num);
        
        uv.x = (sin(uv.x + i * 0.1) + uv.x) * ampl;
        uv.y = (sin(uv.y + i * 0.1) + uv.y) * ampl;

        vec2 ruv = uv;
        vec2 guv = uv;
        vec2 buv = uv;

        float rtoffseta = 0.1 + 0.1 * sin(accumul * 5.0);
        float rtoffsetb = 0.01 + 0.01 * i;
        ruv.x += t;
        ruv = vec2(cos(ruv.x + i * 5.0) * cos(rtoffseta), ruv.y * sin(rtoffsetb));

        float redfreq = 5.0;
        float redphase = cos(guv.y + accumul);

        color.r += sin((ruv.x - ruv.y * i) * redfreq) + redphase;

        // green
        float gtoffseta = 0.1;
        float gtoffsetb = 0.02;
        guv = vec2(guv.x * cos(gtoffseta), guv.y * sin(gtoffsetb * pow(sin(uv.x), 2.0)));

        float greenfreq = 5.0;
        float greenphase = sin(buv.x) + cos(sin(accumul));

        color.g += sin((cos(guv.x) - sin(guv.y) + t * 0.5) * greenfreq) + greenphase;

        // blue
        float btoffseta = 0.1 + sin(accumul) * 0.01;
        float btoffsetb = 0.02;
        buv = vec2(cos(buv.x) * cos(accumul + btoffseta), buv.y * sin(accumul + btoffsetb));

        float bluefreq = 5.0 ;
        float bluephase = 0.5 * cos(accumul + 5.5) * 5.0;

        color.b += sin((buv.x - buv.y + t + i * 4.0) * bluefreq) + bluephase;
        
        uv = uv * 2.2;
        uv.x = cos(uv.x + iTime * 0.5);
        uv.y = sin(uv.y + iTime * 0.5);
        uv = vec2(length(uv) * 2.0, atan(uv.y, uv.x));

    
    }
    
    
    
    color.r = sin(iTime) / color.r + sin(color.g + iTime);
    color.g = cos(iTime * 0.2) / color.b + sin(color.r + iTime * 0.5);
    color.b = tan(iTime) / color.g + cos(color.b + iTime * 0.25);
    
    
    color.r = 0.5 / pow(color.r, 5.0);
    color.g = 0.5 / pow(color.g, 3.0);
    color.b = 0.5 / pow(color.b, 5.0);
    
    color /= 100.0;
    
    fragColor = vec4(color, 1.0);
    
    
}