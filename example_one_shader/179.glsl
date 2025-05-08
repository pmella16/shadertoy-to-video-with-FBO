// Fork of "Modular Raymarching Spheres" by vamoss. https://shadertoy.com/view/ltSSzw
// 2023-11-28 10:44:42

const float VERY_LARGE_DISTANCE = 10000.;
const int MAX_STEPS = 500;

#define TWO_PI 6.2831852
#define PHI 1.618033988

//=====================================================
//raymarching

#define pMod(a, b) (mod(a,b)-0.5*b)
#define pWav(x, w) ((1.+sin(w*x))/2.)

float fSphere(in vec3 p, in float r) {
    return length(p)-r;
}

//=====================================================
//custom

float map( in vec3 p )
{
    return fSphere(pMod(p.xyz, 1.5), 0.0001);
}

float intersect( in vec3 ro, in vec3 rd, in vec2 ms )
{
	const float maxd = VERY_LARGE_DISTANCE;
	float h = 1.0;
    float t = 0.0;
    float c = 0.0;
    for( int i=0; i<MAX_STEPS; i++ )
    {
	    h = map( ro+rd*t );
        t += h;
        c += pow(ms.y, h)/log(1.+pow(t*h, ms.x));
    }

    if( t>maxd ) t=-1.0;
	
    return c;
}

vec3 vintersect( in vec3 ro, in vec3 rd, in vec2 ms )
{
	const float maxd = VERY_LARGE_DISTANCE;
	float h = 1.0;
    float t = 0.0;
    vec3 c = vec3(0.0);
    for( int i=0; i<MAX_STEPS; i++ )
    {
	    h = map( ro+rd*t );
        t += h;
        c += vec3(1./(ms.y*log(1.+h*pow(t, ms.x))))/cos(1.+abs(ro+rd*t));
        if (i > int(1000.)) break; 
    }

    if( t>maxd ) t=-1.0;
	
    return c;
}

vec3 getPosition( float time ) {
    return vec3(2.5*sin(1.0*time), 0.0, 1.0*cos(1.0*time) );
}



mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec3 vWav(vec3 x, vec3 w){
    return vec3(pWav(x.x, w.x), pWav(x.y, w.y), pWav(x.z, w.z));
}

vec3 colouring(vec3 vals, vec3 params){
    //return vals*mod(log(vals), params);
    return vals*vWav(vals, params);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    
    vec2 ms = (vec2(0,0))/iResolution.y;//-0.5*iResolution.xy
    if (vec2(0,0) == vec2(0)) ms = vec2(0.25, 0.5);
    float t = iTime/5.;
    
    //camera target
    vec3 ta = vec3( 45.0, 45.0, 45.0 )*vec3(cos(t),cos(t/PHI),cos(t*PHI));
    
    //camera rotation
    float rotVel = iTime/50.0;//*iMouse.x/iResolution.x;
    float rotRadius = 30.0;
    vec3 ro = vec3( rotRadius*sin(rotVel), 0.5*rotRadius*sin(rotVel), rotRadius*cos(rotVel)) + vec3(0.3);
    
	// camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 0.0 );
    
    // ray direction
	vec3 rd = ca * normalize( vec3(p.xy,2.0) );
    
    vec3 col = vec3(1.0);
    vec3 c = vec3(intersect(ro,rd,2.*ms));
    //vec3 mods = 2.*vec3(PHI*(ms.x-ms.y), PHI*ms.x, PHI*ms.y);
    vec3 mods = 2.*vec3(PHI*(ms.x*ms.y), PHI*ms.x, PHI*PHI*ms.y+sin(t));
    if( length(c)>0.0 )
    {
        col = mix(vec3(0.0), col, colouring(c, mods)/float(MAX_STEPS)*2.0);
	}

	col = clamp(col,0.0,1.0);
	fragColor = vec4( col, 1.0);
}