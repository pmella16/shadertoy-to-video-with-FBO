//Use as you will.
//Based on : https://www.shadertoy.com/view/llj3Dz

#define RIPPLES_COUNT 20.
#define RIPPLES_SCALE 5.
#define RIPPLES_SPEED 0.7

#define WaveParams vec3(20.0, 2.0, 0.5)

vec2 hash22(vec2 p){
    return 2. * fract(sin(vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3))))*43758.5453) -1.;
}

float Ripple(vec2 uv,float index, float scale){

    uv=fract(uv)*scale+index*127.33;
    
    //uv.x+=iTime*0.2;
    uv.y+=iMouse.y*0.01;
    
    float t =iTime*RIPPLES_SPEED;  
        
    vec2 tile = floor(uv);
    vec2 fr = fract(uv);
    vec2 noise =hash22(tile);
    
    float CurrentTime = fract(t+noise.x) ;
    
    noise = hash22(tile+floor((t+noise.x)));;
    
    vec2 WaveCentre = vec2(0.5,0.5)+ noise *0.3 ;
     
	float Dist =distance(fract(uv) , WaveCentre)*(5.+WaveParams.z*noise.x);  
  
    float Diff = (Dist - CurrentTime); 
    
    float ScaleDiff = (1.0 - pow(3.*abs(Diff * WaveParams.x), WaveParams.y)); 
    ScaleDiff = max(ScaleDiff,  (1. - pow(abs((Dist - 1.5*CurrentTime) * WaveParams.x), WaveParams.y))); 
    

    return clamp( ( ScaleDiff) / ( (CurrentTime) * Dist * 40.0) , 0.0, 1.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    float ratio = iResolution.y/iResolution.x;
    
    vec2 uv = fragCoord/ iResolution.xy;
    uv.y *= ratio; 
    
    float col = 0.;
    
    for(float i = 0.; i<=RIPPLES_COUNT; i++)
    {
        col += Ripple(uv,i*0.1,RIPPLES_SCALE);   
    }
    
    fragColor = vec4(col);
   
}