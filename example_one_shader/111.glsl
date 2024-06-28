const float s2 = 1.41421356237; // sqrt(2)

float sierpinski(vec2 p){
    p -= floor(p);
    
    float d = 1.;
    float inside = 1.;
    
    
    for (int i=0; i<10; i++){
        // Break the unit square [0,1]^2 into two triangles, the bottom left and top right.
        // For points in the top right triangle, find the distance from the edges:
        float d1 = (p.x + p.y - 1.)/s2;
        float d2 = 1. - p.x;
        float d3 = 1. - p.y;
        float dTri = max(min(d1, min(d2,d3)),0.);
        
        // tried to make the transition smooth... 
        float r = max(1.-dTri*(5.-float(i)/2.), 0.)*(1.-float(i)/200.);
        // once a point is outside the Sierpinski triangle, don't change its color
        d *= inside*r*r*r + (1.-inside);
        
        // Track if p is inside the Sierpinski triangle in the next iteration
        inside *= step(p.x+p.y, 1.);
        
        // go to the next iteration
        p *= 2.;
        p -= floor(p);
    }
    
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    // normalize coordinates.
    vec2 p = fragCoord.xy / iResolution.y;
    
    float scale = pow(2., 1. + fract(iTime));
    
    float d = mix(sierpinski(p/(scale*2.)), sierpinski(p/scale), fract(iTime));
    
    fragColor = vec4(d*d*d*d*d, d, sqrt(d), 1.);    
}