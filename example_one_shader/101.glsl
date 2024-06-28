
mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// pallete
vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );

}


float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}
float map(vec3 p) {
    p.z += iTime * .4; // Forward movement
    
    // Space repetition
    p.xy = fract(p.xy) - .5;     // spacing
    p.z =  mod(p.z, .25) - .125; // spacing
    
    return sdOctahedron(p, .15); // Octahedron
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    
   
    
    //Initialization
    vec3 ro = vec3(0, 0, -3);         //ray origin
    vec3 rd = normalize(vec3(uv * 5.0, 1)); // ray direction
    vec3 col = vec3(0); 
    
    float t = 0.; // total distance travelled
    
    //raymarching
   for (int i = 0; i < 80; i++) {
   vec3 p = ro + rd * t; // position along the ray
    
    
    float d = map(p); // current distance to the scene
    
    t += d; // "march" the ray
    
    col = vec3(i) / 80.;
    
    if (d < .001 || t > 100.) break; //early stop
    
   
  }
  
  //coloring 
 col = palette(t*1.0 + 0.5);

    fragColor = vec4(col, 1);
}

