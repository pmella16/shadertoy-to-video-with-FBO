vec2 Rotate( vec2 p, float theta){
    return vec2(p.x * cos(theta) + p.y * sin(theta), -p.x * sin(theta) + p.y * cos(theta));
}

//a&b frequency in x&y direction
//c&d speed in positive x&y direction
float CheckerWave( vec2 p, float a, float b, float c, float d ){
    return sin(p.x * a - iTime * c) * cos(p.y * b - iTime * d);
}
float FractWave( vec2 p, float a, float b, float c, float d ){
    return fract(p.x * a - iTime * c) * fract(p.y * b - iTime * d);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.0 - iResolution.xy)/iResolution.y;
    uv = uv * 3.0 * (0.8 + 0.4 * sin(iTime * 1.0/sqrt(3.0)));
    uv = Rotate(uv, (length(uv) * sin(iTime)) / 5.0);
    uv = Rotate(uv, -sin(iTime));
    uv = uv + vec2(iTime, 0.0);
    
    float gCW = 0.0;
    float gFW = 0.0;
    float bCW = 0.0;
    float bFW = 0.0;
    float rCW = 0.0;
    float rFW = 0.0;
    
    for (int i = 0; i < 50; i++) {
        float fi = float(i+1);
        vec2 gp = Rotate(uv, fi);
        vec2 bp = Rotate(uv, fi+sqrt(2.0));
        vec2 rp = Rotate(uv, fi+sqrt(3.0));
        gCW += CheckerWave(gp, fi, fi+1.0, 1.0, 1.0)/(fi+3.0);
        bCW += CheckerWave(bp, fi, fi+1.0, 1.0, 1.0)/(fi+3.0);
        rCW += CheckerWave(rp, fi, fi+1.0, 1.0, 1.0)/(fi+3.0);
    }
    
    for (int i = 0; i < 7; i++) {
        float fi = float(i+15);
        vec2 gp = Rotate(uv, fi);
        vec2 bp = Rotate(uv, fi+sqrt(2.0));
        vec2 rp = Rotate(uv, fi+sqrt(3.0));
        gFW += FractWave(gp, fi, fi+1.0, 1.0, 1.0)/(fi-13.0);
        bFW += FractWave(bp, fi, fi+1.0, 1.0, 1.0)/(fi-13.0);
        rFW += FractWave(bp, fi, fi+1.0, 1.0, 1.0)/(fi-13.0);
        
    }
    
    float green = pow(abs(gFW),0.25) * pow(abs(gCW),0.5);
    green = pow(green, 1.2);
    float blue = pow(abs(bCW),0.5);
    blue = pow(green, 0.4) * blue * pow(abs(bFW),0.25);
    float red = pow(abs(rFW),0.25) * pow(abs(rCW),0.5);
    red = pow(green, 0.3) * red * pow(abs(rFW),0.25);
    
    vec3 col = vec3(red, green, blue);
    
    fragColor = vec4(col, 1.0);
}