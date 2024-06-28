vec3 palette( float t ) {
    //vec3 a = vec3(0.5, 0.5, 0.5);
    //vec3 b = vec3(0.5, 0.5, 0.5);
    //vec3 c = vec3(1.0, 1.0, 1.0);
    //vec3 d = vec3(0.5,0.7,0.3);
    
    //vec3 a = vec3(0.5, 0.5, 0.5);
    //vec3 b = vec3(0.5, 0.5, 0.5);
    //vec3 c = vec3(2.0, 1.0, 0.0);
    //vec3 d = vec3(0.5,0.20,0.25);
    
    //vec3 a = vec3(0.5, 0.5, 0.5);
    //vec3 b = vec3(0.5, 0.5, 0.5);
    //vec3 c = vec3(1.0, 1.0, 1.0);
    //vec3 d = vec3(0.8,0.9,0.3);
    
    //vec3 a = vec3(0.5, 0.5, 0.5);
    //vec3 b = vec3(0.5, 0.5, 0.5);
    //vec3 c = vec3(1.0, 1.0, 1.0);
    //vec3 d = vec3(0.263,0.416,0.557);
    
    vec3 a = vec3(0.5, 0.5, 0.098);
    vec3 b = vec3(0.5, 0.5, 0.538);
    vec3 c = vec3(1.0, 1.0, -0.841);
    vec3 d = vec3(0.75,0.25,-1.19);

    return a + b*cos( 6.28318*(c*t+d) );
}


float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    float iteration = 3.0;
    for(float i = 1.0; i <= iteration; ++i){
        
        float timeSpeed = 0.2;
        float timeRange = 2.0;
        float timeVal = (sin(iTime*timeSpeed)+timeRange)*1.0/timeRange;
        
        uv = fract(uv * timeVal) - 0.5;
        
        // Shapes ----------       
        // ShapeShiftValue
        float shapeShift = (sin(iTime*0.1+5.)+1.0)*0.5;      
        
        // (Circle)       
        float circleShape = sdCircle(uv,1.)* exp(-sdCircle(uv0,sin(iTime*0.2)+1.0)*0.5);
        
        // (Box)  
        float boxShape = sdBox(uv, vec2((sin(iTime*0.05)+1.0)*0.1+0.2))* exp(-sdCircle(uv0,sin(iTime*0.1+1.)+1.0)*0.5);
        
        
        float d = mix(circleShape, boxShape, shapeShift);  
        float colorSpeed = 0.5;
        vec3 col = palette(length(uv0) + i*colorSpeed +  iTime*colorSpeed);
        
        float shapeSpace = 12.;
        float shapeSpeed = 0.2;
        d = sin(d*shapeSpace + iTime*shapeSpeed) / shapeSpace;
        d = abs(d);

        d = pow(0.0035/d, 1.2);


        finalColor += col * d;
    }
    
    // Output to screen
    fragColor = vec4(finalColor,1.0);
}