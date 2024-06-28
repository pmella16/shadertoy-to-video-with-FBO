// Set to true to zoom/explore the fractal using arrow keys + I O 
#define EXPLORE false

// Number of fractal copies
#define Copies 10

// Escape time iterations
#define Iterations 200


// HSL to RGB
vec3 HSL_to_RGB(float H, float S, float L) {
    vec3 rgb = clamp( abs(mod(H*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    return L + S * (rgb-0.5)*(1.0-abs(2.0*L-1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord) {

    float er = 625.0;
    
    float x = sin(iTime / 3.0) * 2.8;
    float y = cos(iTime / 3.0) * 2.0;
    float mag = exp(sin(0.1 * iTime)) / 2.0;
    
    
    int m = 0;
    int n = 0;
    
    float px = (fragCoord.x - iResolution.x * 0.5) / iResolution.y;
    float py = (fragCoord.y - iResolution.y * 0.5) / iResolution.y;

    float cx = px * 4.0 / mag + x;
    float cy = py * 4.0 / mag + y;
    
    float zx = 0.0;
    float zy = 0.0;
    
    while (m < Copies) {
    
        while (n < Iterations) {
            
            float t1 = zx * zx - zy * zy + cx;
            zy = 2.0 * zx * zy + cy;
            zx = t1;
            
            if (sqrt(zx * zx + zy * zy) > er) {
                break;
            }
            n++;
        }
        if (n == Iterations) {
        
            px = zx;
            py = zy;
        
            n = 0;
            break;
        }
        
        // https://mathr.co.uk/web/m-exterior-coordinates.html
            
        cx = atan(zy, zx) / 6.2831853071795864769;
        cy = log(sqrt(zx * zx + zy * zy)) / log(er);
                
        cx = (cx - 0.0) * 4.0 / mag + x;
        cy = (cy - 1.5) * 4.0 / mag + y;
        zx = 0.0;
        zy = 0.0;
        
        m++;
    }
   
    float H = (sin(float(n) / 50.0 + iTime / 10.0 + px * 0.5) / 2.0 + 0.5);
    float S = pow(sin(float(n) / 10.0 + iTime / 9.0) / 2.0 + 0.5, 0.1);
    float L = n < Iterations ? pow(sin(float(n) / 5.0 + iTime / 8.0 + 2.0 * py) / 2.0 + 0.5, 3.0) : 0.0;
    
    vec3 col = HSL_to_RGB(H, S, L);

    fragColor = vec4(col, 1.0);
}