// Thanks to IQ: https://www.shadertoy.com/view/ll2GD3
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - .5*iResolution.xy ) / iResolution.x;

    float height = 4.0 + 3.0 * sin(iTime);//+texture(iChannel0, vec2(0.8,0.)).x);
    float depthForCineshader = 1.;
    float transparencyFactor = 1.;
    vec3 col = vec3(0.);
    for (float layer = 1.; layer < 6.; layer++) {
    
        float rotation = iTime+layer;
        vec2 uvTransformed = 
            (uv * height * layer*layer // Layer scale
            + vec2(.7*layer)) // Rotation offset
            * mat2(cos(rotation),-sin(rotation),sin(rotation),cos(rotation));

        vec2 uvFract = fract(uvTransformed);
        uvFract.x = mod(uvTransformed.x,2.0) > 1.0 ? 1.0 - uvFract.x : uvFract.x;

        float d1 = (length(uvFract)), d2 = (length(uvFract-vec2(0.,1.))), d3 = (length(uvFract-vec2(1.,.5)));

        float m = min(min(d1,d2),d3);
        float d = 1.0*(6. - layer)/5.;
        
        vec3 col1 = pal( (iTime+floor(uvTransformed.y))/3., vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25) );
        vec3 col2 = pal( (iTime+floor(uvTransformed.y+.5))/6., vec3(0.8,0.5,0.4),vec3(0.2,0.4,0.2),vec3(2.0,1.0,1.0),vec3(0.0,0.25,0.25) );
        
        depthForCineshader-=.05;

        if (m >.30) {
            float diff = m == d1 ? abs(m-min(d2,d3)) : (m == d2) ? abs(m-min(d1,d3)) : abs(m-min(d1,d2));
            float edgeThickness = .025;
            float thickLine =  m >.33 && (diff > edgeThickness*2. && (uvFract.y < (1.-edgeThickness) && uvFract.y > edgeThickness || uvFract.x < .6)) ? 1.0 : .5;
            col += transparencyFactor * thickLine * d * (1.-m*m) * ( m == d1 || m == d2 ? col2 : col1);
            transparencyFactor /= 4.;
        }
    }

    fragColor = vec4(col,depthForCineshader);
}