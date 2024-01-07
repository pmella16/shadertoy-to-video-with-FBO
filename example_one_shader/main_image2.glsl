vec3 palette( float t){
    vec3 a = vec3(0.427,0.024,0.757);
    vec3 b = vec3(0.910,0.349,0.349);
    vec3 c = vec3(0.278,0.741,0.941);
    vec3 d = vec3(0.451,0.843,0.059);
    
    return a + b*cos( 6.28318*(c*t+d) );
}

float myTrunc(float x) {
    return sign(x) * floor(abs(x));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    //Flipping the image on both axis
    if (uv.y > 0.) {
        uv.y = 1.0 - uv.y - 1.;
    }
    if (uv.x > 0.) {
        uv.x = 1.0 - uv.x - 1.;
    }
    
    //Creating the wave
    float d = uv.y+0.35 + sin(-uv.x/0.5 - iTime*3.)/3.;
    d = abs(d);
    
    //Removing smoothstep is cool
    d = smoothstep(0.0, 0.1, d/1.5); 
    
    //makes the vertical waves
    d = dot(d, uv.x*5.0);
    
    //idk how mod works. It only seems to work on one side
    d = mod(-d, 1. - iTime);
    
    //trunc is cool
    d = myTrunc(d);
    
    vec3 col = palette(d + iTime/2.);
    
    fragColor = vec4(col, 1.0);
}