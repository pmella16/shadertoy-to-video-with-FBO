float sdPentagon( in vec2 p, in float r )
{
    const vec3 k = vec3(0.809016994,0.587785252,0.726542528);
    p.x = abs(p.x);
    p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
    p -= 2.0*min(dot(vec2( k.x,k.y),p),0.0)*vec2( k.x,k.y);
    p -= vec2(clamp(p.x,-r*k.z,r*k.z),r);    
    return length(p)*sign(p.y);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    float d0 = length(uv);
    
    uv = fract(uv * 2.) - 0.5;
    
    float d = length(vec2(uv.x, uv.y));
    
    float d1 = d0;

    for (float i = 0.; i < 4.; i++) {
        d1 -= 0.8 + (sin(iTime * 0.5) / (2. + i));
        d1 = abs(d1);
        //d0 = smoothstep(0., 0.5, d0);
        d1 = 0.2 / d1;
    }
    
    float pent = (0.6 + (cos(iTime) / 7.)) - smoothstep(0., (0.2 + (cos((iTime + (d1 * 4.)) * 1.6) / (8. + d0))), sdPentagon(uv, (d0 * 0.2)));
    pent = 0.8 / pent;



    
    
    vec3 col = vec3(pent * d1, 
                    0.5 - (d / (0.8 + (sin((iTime * 2.) - (d1 * 2.)) / 5.))), 
                    pent * 0.3);
                   

    if (col.x >= 1. && col.z >= 1.) {
        col = vec3(d0 * 0.5, d, d);
    }
    

    
    col += d1 * 0.2;
    //d0 = 0.5 / d0;
    //col = vec3(d0);
    
    // Output to screen
    fragColor = vec4(col,1.0);
}