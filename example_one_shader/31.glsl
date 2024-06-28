const float FOV = 90.;


vec3 palette( float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);

    return a + b*cos( 6.28318*(c*t*d) );
    }


float apollonianSDF( vec3 p ) {
    float width = 1.5f;  // 1.5f
    float s = 3.0f, e;
    for ( int i = 0; i++ < 12; ) {
        p = mod(p - 1.0f, 2.0f ) - 1.0f;
        s *= e = width / dot( p, p );
        p *= e;
    }
    return length( p.yz ) / s;
}


// Calculate the Signed Distance Field for the scene

vec2 map(vec3 point) {
    return vec2(apollonianSDF(point), 1.);
}


vec4 rayMarch(vec3 point, vec3 direction, out int iter) {
    vec2 signedDistance;
    vec4 result;
    
    const int maxMarchingSteps = 5000;  // Maximum number of times ray is marched until loop breaks
    const float maxDistance = 1000.0;  // Maximum distance to object for a miss
    const float minDistance = 0.0001;  // Minimum distance to object for a hit
    
    vec3 rayPosition = point;
    
    for (int i = 0; i < maxMarchingSteps; i++)  // March the ray forwards  
    {        
        // Distance to nearest object
        vec2 signedDistance = map(rayPosition);

        rayPosition += direction * signedDistance.x;  // Move the ray
        
        result = vec4(rayPosition, 0.0);
        if (signedDistance.x > maxDistance) break;  // If the ray misses
        if (signedDistance.x < minDistance) {
            result = vec4(rayPosition, signedDistance.y);
            break;  // If the ray hits something
            }
        iter = i;
    }
    
    
    
    return result;
}


vec3 calculateNormal(vec3 position) {
    const float EPSILON = 0.001;
    
    vec3 v1 = vec3(
        map(position + vec3(EPSILON, 0.0, 0.0)).x,
        map(position + vec3(0.0, EPSILON, 0.0)).x,
        map(position + vec3(0.0, 0.0, EPSILON)).x);
    vec3 v2 = vec3(
        map(position - vec3(EPSILON, 0.0, 0.0)).x,
        map(position - vec3(0.0, EPSILON, 0.0)).x,
        map(position - vec3(0.0, 0.0, EPSILON)).x);
    
    return normalize(v1 - v2);
        
}

// Default colour for a miss
vec3 col = vec3(0., 0., 0.);
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    // Normalized pixel coordinates (from 0 to 1)
    // Shifted so (0, 0) is the centre rather than bottom-left
    vec2 shiftedCoord = fragCoord - (iResolution.xy / 2.0);
    vec2 uv = shiftedCoord / iResolution.y;   
    
    vec3 rayPosition = vec3(uv.x/10., uv.y/10., 0.0);
    vec3 rayDirection = vec3(0.0, 0.0, 1.0);
    rayDirection.xy = uv.xy * atan(radians(FOV));
    rayDirection = normalize(rayDirection);
    
    rayPosition += vec3(1., 1., iTime);
    
    int iterations;
    vec4 hitPosID = rayMarch(rayPosition, rayDirection, iterations);
    vec3 hitPosition = hitPosID.xyz;
    float objectID = hitPosID.w;
    
    // If the ray hit, calculate lighting
    if (objectID != 0.0) {
        col = palette(length(hitPosition));
        col /= vec3(float(iterations)*.5);
        //col *= 2.;
        

    }
    
    // Gamma correction
    float gamma = 2.2;
    col = pow(col, vec3(1.0 / gamma));
    // Output to screen
    fragColor = vec4(col,1.0);
}
