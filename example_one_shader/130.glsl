// Just another spiral.  Just another experiment with domain repetition.  Thanks IQ!

float PI = 3.14159256;
float TAU = 2.0*3.14159256;

float sdfCirc(in vec2 p, in float rad){
    return length(p) - 1.7*rad;
}


vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord-iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);
    float tt = fract(iTime);
    
    // Scale the uv coordinates
    float scaleFactor = 3.;
    uv *= scaleFactor;
    
    // Cells in radial direction
    float rCellID = myround(length(uv));
    
    // Cells in angular direction
    float numCircles = 32.;
    float angDelta = (TAU/numCircles);
    float uvAng = atan(uv.y,uv.x);
    float aCellID = myround(uvAng/angDelta);
  
    // Angle to rotate all uv points in angular cell
    float angVal = angDelta*aCellID;
      
    // rotate the UV coordinate 
    vec2 p = mat2(cos(angVal),-sin(angVal),sin(angVal), cos(angVal))*uv;
    
    // Motion vector from one radial cell to the next with a timing offset
    vec2 rc = mix(vec2(rCellID,0.), vec2(rCellID + 1.,0.), fract(tt + aCellID/numCircles));
    
    // Current SDF and check the radial neighbor, take the minimum
    float rCheck1 = sdfCirc(p - rc, .15 * length(uv)/scaleFactor);
    float rCheck2 = sdfCirc(p - rc - vec2(-1.0,0.), .15 * length(uv)/scaleFactor);
    float d = min(rCheck1, rCheck2);
  
    // See the grid, debug option
    // col += rCellID/16. + aCellID/16.;
    
    float w = 10./iResolution.y;
    col += smoothstep(w,-w,d);
    col -= smoothstep(0.,-w,d/6.);
    fragColor = vec4( col, 1.0 );;
}