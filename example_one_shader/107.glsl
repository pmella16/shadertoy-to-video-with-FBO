#define BREATHE  // Comment out to speed up

#define EPSILON .00001

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    vec2 scale = vec2(6.,4.);
    int octaves = 5;
    
    float val = 1.;
    float width = 0.05;
    vec3 cellCol = vec3(.0001);
    
    for (int i = 0; i < octaves; i++)
    {
        #ifdef BREATHE
        float animation = sin(iTime*(float(i+1)))/2.+.5;

        vec2 cell = floor((scale+animation)*(uv-animation/scale/2.));
        vec2 frac = fract((scale+animation)*(uv-animation/scale/2.));
        #else
        vec2 cell = floor(scale*uv);
        vec2 frac = fract(scale*uv);
        #endif

        vec2 mc; // Cell of nearest point
        vec2 mr; // Vector to nearest point
        float dist = 8.; // Distance to nearest point

        for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            vec2 c = vec2(i, j);  // Cell
            vec2 p = sin(iTime+6.21*random2(cell+c))*.5+.5;
            vec2 r = (c+p)-frac;  // Vector from frac to point in cell
            float d = dot(r,r); // Squared distance of r

            if( d < dist )
            {
                dist = d;
                mr = r;
                mc = c;
            }
        }

        dist = 8.0; // Cache closest vector and cell, reset dist
        for( int j=-2; j<=2; j++ )
        for( int i=-2; i<=2; i++ )
        {
            vec2 c = mc + vec2(i, j); // Cell offset from min cell
            vec2 p = sin(iTime+6.21*random2(cell+c))*.5+.5;
            vec2  r = (c+p) - frac;
            
            if( dot(mr-r,mr-r)>EPSILON ) // skip the same cell
            dist = min( dist, dot(0.5*(mr+r), normalize(r-mr)) );
        }
        
        
        cellCol = (1.-step(0.,-cellCol)) * (cellCol + vec3(random2(cell+mc),random2((cell+mc)*2.).x)) / (float(i+1)*.8)*1.8;
        cellCol *= step(width, dist);
        scale *= 2.;
        width *= 1.3;
    }

    // Output to screen
    fragColor = vec4(cellCol,1.0);
}