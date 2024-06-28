#define PI 3.14159265359
#define TWO_PI 6.28318530718


vec3 pal(in float t) {
    vec3 a =  vec3(0.184,0.776,0.737);// Updated color 1
    vec3 b = vec3(0.702,0.702,0.702); // Updated color 2
    vec3 c = vec3(0.788,0.188,0.910); // Updated color 3
    vec3 d = vec3(0.510,0.510,0.510);  // Updated color 4
  
 
    // Return the color by applying a cosine function to create smooth transitions between colors
    return a + b * cos(6.28318 * (c * t + d));
}

float pattern(vec2 uv, float l)
{

    vec2 st = vec2(atan(uv.x, uv.y), vec2(length(uv*.8)));
    
     float k_sine = 0.01 * sin(.1 * iTime * .2);
    float sine = k_sine * sin(50.0 * (pow(st.y, 0.9) - 0.8 * iTime*0.05));
    
    uv = vec2(st.x/TWO_PI + sine + .5 + iTime * .1 + st.y, st.y);
    
    float x =(l * uv.x);
    float m = pow(min(fract(x - sine), fract(1. - x)), 1. - sine );
    float c = smoothstep(0.2,.5, m*.5 + .3 - uv.y );
    
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - .5 * iResolution.xy)/iResolution.y;
     vec2 uv0 = uv;
    float t = iTime;
    vec3 col = vec3(0.0);
    float f;
    for(float i = 0.; i < 6.; i++)
    {
     
     float d = length(uv*pow(.1 * t * 0.01,i/2.)) + exp(length(uv0));
     d = sin(d * .8);
     
      float f0 = pattern(uv, 4.);
      f = pattern(fract(uv * i * d)-.5, 8.);
      
       d = max(cos(d * 8. + t)/8.,sin(d * 2. + t * i * .2))/2.;
    d = abs(d);
    d= pow(0.1/d,.5);
      
    col += vec3(pal(max(f, f0) * d));
    
    }
    
    fragColor = vec4(col, 1.);
    
   // fragColor = vec4(f);
}