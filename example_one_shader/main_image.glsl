//Inspired and based on my learnings of Kishimisu tutorials about shader art coding


vec3 pal(in float t) {
    vec3 a =  vec3(0.5,0.5,0.5);// Updated color 1
    vec3 b = vec3(0.5,0.5,0.5); // Updated color 2
    vec3 c = vec3(1.0,0.7,0.4); // Updated color 3
    vec3 d = vec3(0.0,0.15,0.20);  // Updated color 4
    
  
    // Return the color by applying a cosine function to create smooth transitions between colors
    return a + b * cos(6.28318 * (c * t + d));
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2. - iResolution.xy)/ iResolution.y;
    
    vec2 uv0 = uv;
    vec3 finalCol = vec3(0.0);
    
    
    for(float i = 0.; i < 2.; i++)
    {
     float t = iTime;

    //float tr = clamp(length(uv0) + sin(i + t * 0.2), 0.6,1.2);
    
      uv = fract(uv * 1.5) - .5;
    float d = length(uv) * exp(length(uv0));


    vec3 col = sin(1.8 * pal(-length(uv0)+ t * .11));

    //distance to the center
    d = max(cos(d * 8. + t)/8.,sin(d * 2. + t))/2.;
    d = abs(d);
    d= pow(0.012/d,.8);
    
    vec3 mon_color = vec3(0.,0.,1.);
    mon_color += col;
    
    finalCol += mon_color * d;
    
    
    }
  
 
    // Output to screen
   // fragColor =  vec4(vec3(d),1.);
   
   fragColor = vec4(finalCol,1.);
}