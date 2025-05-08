// Fork of "By The Art of code tutor Twi.Tor" by SanyaBer. https://shadertoy.com/view/dsXfzX
// 2025-02-14 15:04:40

vec3 hsb2rgb( in vec3 c )
{
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return (c.z * mix( vec3(1.0), rgb, c.y));
}
// simple mouse rotate and zoom for shader
#define pi 3.14159265359 

mat2 r2d(float a) {
    return mat2(cos(a),sin(a),-sin(a),cos(a));
}

vec2 mouseRotZoom(vec2 uv) {
    // allow mouse zoom and rotate    
    vec2 mouse = (iMouse.xy == vec2(0.)) ? vec2(1.0,1.) : iMouse.xy/iResolution.xy;
    uv.xy *= r2d(-(mouse.x)*pi*2.);
    uv *= (1./pow(3.3,mouse.y))*2.25;
    return uv;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    float t = iTime * .2;
    
    //mouse 
    uv = mouseRotZoom(uv);
    
    uv *= mat2(cos(t), -sin(t), sin(t), cos(t));

    vec3 ro = vec3(0, 0, -1);
    vec3 lookat = mix(vec3(0), vec3(-1, 0, -1), sin(t*1.56)*.5+.5);
    float zoom = mix(.2, .7, sin(t)*.5+.5);
    
    vec3 f = normalize(lookat-ro),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = ro + f * zoom,
        i = c + uv.x * r + uv.y * u,
        rd = normalize(i-ro);
    
    float radius = mix(0.3, 1.5, sin(t*.4)*.5+.5);
    float dS, dO;
    vec3 p;
    for(int i = 0; i < 100; i++) {
        p = ro + rd * dO;
        dS = -(length(vec2(length(p.xz)-1., p.y)) - radius);
        if(dS<.001) break;
        dO += dS;
        }
    
    vec3 col = vec3(0);
    
    if(dS<.001) {
        float x = atan(p.x, p.z)+t*.5;           // - pi to pi
        float y = atan(length(p.xz)-1., p.y);
        
        float bands = sin(y*10.+x*30.);
        float ripples = sin((x*10.-y*30.)*3.)*.5+.5;
        float waves = sin(x*2.-y*6.+t*20.);
        
        float b1 = smoothstep(-.2, .2, bands);
        float b2 = smoothstep(-.2, .2, bands-.5); 
        
        float m = b1*(1.-b2);     
        m = max(m, ripples*b2*max(0.,waves));
        float wb2 = max(0., waves*.3*b2);
        m += wb2;
        
        float m2 = mix(m, 1. -m, smoothstep(-.3, .3, sin(x*2.+t)));
        
        // Orig was simply col += m2;
        if(bands>0.) {
            col += m2*hsb2rgb( vec3( (3.14159*wb2)*.85*y+x, 0.9, 0.9 ));
        } else {
#ifdef WITHWHITE
            col += m2;
#else
            col += hsb2rgb( vec3( (3.14159*m2), 0.9, 0.3 ));
#endif
        }
    }
 

    // Output to screen
    fragColor = vec4(col,1.0);
}