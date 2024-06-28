// Fork of "Modular forms Faster" by timmaffett. https://shadertoy.com/view/4cjXzw
// 2024-01-25 04:16:46

// Fork of "Modular forms" by nimitz. https://shadertoy.com/view/sdcyW8
// 2024-01-25 03:50:51

// -tmm All I did here is reduce the loop iterations with little or no visible effect but
//  sped it up from 18fps to 48fps on my machine.
// also if'def out unused functions for faster compile
//
//   Oh and I added mouse rotate/zoom

//Modular forms by nimitz (nmz) 2024

/*
    See vec3 f(vec2 z) for more functions! (line ~200)
*/
float cabs (const vec2 c) { return dot(c,c); }
vec2 cmuli(vec2 z) { return vec2(-z.y, z.x);}
vec2 cadd(vec2 a, float s) { return vec2( a.x+s, a.y ); }
vec2 cmul(vec2 a, vec2 b)  { return vec2( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x ); }
vec2 cdiv(vec2 a, vec2 b)  { float d = dot(b,b); return vec2( dot(a,b), a.y*b.x - a.x*b.y ) / d; }
vec2 cinv(vec2 z)  { float d = dot(z,z); return vec2( z.x, -z.y ) / d; }
vec2 csqr(vec2 a) { return vec2(a.x*a.x-a.y*a.y, 2.0*a.x*a.y ); }
vec2 csqrt(vec2 z) { float m = length(z); return sqrt( 0.5*vec2(m+z.x, m-z.x) ) * vec2( 1.0, sign(z.y) ); }
vec2 conj(vec2 z) { return vec2(z.x,-z.y); }
vec2 cpow(vec2 z, float n) { float r = length( z ); float a = atan( z.y, z.x ); return pow( r, n )*vec2( cos(a*n), sin(a*n) ); }
vec2 cexp(vec2 z) {  return exp( z.x )*vec2( cos(z.y), sin(z.y) ); }
vec2 cexp2(vec2 z) {  return exp2( z.x )*vec2( cos(z.y), sin(z.y) ); }
vec2 clog(vec2 z) {  float d = dot(z,z);return vec2( 0.5*log(d), atan(z.y,z.x)); }
vec2 csin(vec2 z) { float r = exp(z.y); return 0.5*vec2((r+1.0/r)*sin(z.x),(r-1.0/r)*cos(z.x));}
vec2 ccos(vec2 z) { float r = exp(z.y); return 0.5*vec2((r+1.0/r)*cos(z.x),-(r-1.0/r)*sin(z.x));}
float det(vec2 a, vec2 b) { return a.x*b.y-a.y*b.x;}

mat2 rot(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

vec2 mycosh(float x) {
    return vec2((exp(x) + exp(-x)) * 0.5, 0.0);
}

vec2 mysinh(float x) {
    return vec2((exp(x) - exp(-x)) * 0.5, 0.0);
}

// slightly higher precison
vec2 ccos2(vec2 z) {
    return vec2(cos(z.x) * mycosh(z.y).x, -sin(z.x) * mysinh(z.y).x);
}

int imod(int a, int b){return a - (b * int(a/b));}

//cheap viridis approx
vec3 pal(float x)
{
    vec3 col = sin(x + vec3(4.1, -1., .6) - 1.1)*vec3(0.4, 0.37, 0.11) + vec3(0.6, 0.45, 0.33);
    col.r *= col.r;
    return col;
}

#define DISC
#define ALT_PALETTE

#define pi 3.1415926535
vec2 qn(vec2 z, float n){ return cexp(2.*n*pi*cmuli(z)); }
vec2 qinv(vec2 z){ return cdiv(cmuli(-z) + vec2(1,0), z - vec2(0,1)); }
mat2 rot2(in float a){float c = cos(a), s = sin(a);return mat2(c,s,-s,c);}

#ifdef USED
//Eisenstein series
vec2 e4(vec2 z)
{
    vec2 rz = vec2(0.,0.);
    for(float n = 1.; n<50.; n++)
    {
        vec2 q = qn(z, n);
        rz += cdiv(n*n*n*q, vec2(1., 0.) - q);
    }
    return vec2(1.0, 0.) + 240.*rz;
}

vec2 e6(vec2 z)
{
    vec2 rz = vec2(0);
    for(float n = 1.; n<50.; n++)
    {
        float n2 = n*n;
        vec2 q = qn(z, n);
        rz += cdiv(n2*n2*n*q, vec2(1., 0.) - q);
    }
    return vec2(1.0, 0.0) - 504.*rz;
}

vec2 e8(vec2 z)
{
    vec2 rz = vec2(0);
    for(float n = 1.; n<50.; n++)
    {
        float n3 = n*n*n;
        vec2 q = qn(z, n);
        rz += cdiv(n3*n3*n*q, vec2(1., 0.) - q);
    }
    return vec2(1.0, 0.0) + 480.*rz;
}
#endif

// Dedekind eta function (Euler function with final scaling factor)
vec2 eta(vec2 z)
{
    vec2 prod = vec2(1.,0.);
    for(float n = 1.; n<5.0 /*50.*/; n++)
    {
        vec2 q = qn(z, n);
        prod = cmul(prod, vec2(1.,.0)-q);
    }
    vec2 ml = cexp(pi*cmuli(z)/12.);
    return cmul(ml, prod);
}

// eta squared
vec2 eta2(vec2 z)
{
    vec2 prod = vec2(1.,.0);
    for(float n = 1.; n<5.0 /*50.0*/ /*150.*/; n++)
    {
        vec2 q = qn(z, n);
        prod = cmul(prod, csqr(vec2(1.,.0)-q));
    }
    vec2 ml = cexp(pi*cmuli(z)/6.);
    return cmul(ml, prod);
}

// eta cubed
vec2 eta3(vec2 z)
{
    vec2 prod = vec2(1.,.0);
    for(float n = 1.; n<5.; n++)
    {
        vec2 q = qn(z, n);
        prod = cmul(prod, cpow(vec2(1.,.0)-q, 3.));
    }
    vec2 ml = cexp(pi*cmuli(z)/4.);
    return cmul(ml, prod);
}
#ifdef USED
vec2 eta8(vec2 z)
{
    vec2 prod = vec2(1.,.0);
    for(float n = 1.; n<20.; n++)
    {
        vec2 q = qn(z, n);
        prod = cmul(prod, cpow(vec2(1.,.0)-q, 8.));
    }
    vec2 ml = cexp(pi*cmuli(z)/1.5);
    return cmul(ml, prod);
}

// modular discriminant
vec2 delta(vec2 z)
{
    if (z.y < 0.0) return vec2(0);
    vec2 prod = vec2(1.,0.);
    for(float n = 1.; n<50.; n++)
    {
        vec2 q = qn(z, n);
        prod = cmul(prod, cpow(vec2(1.,.0)-q, 24.));
    }
    vec2 ml = cexp(2.*pi*cmuli(z));
    return cmul(ml, prod)*pow(6.2831853,12.);
}

// Jacobi theta function
vec2 theta(vec2 z, vec2 tau)
{
    vec2 rez = vec2(0);
    for(float n = -30.; n<15.; n++)
    {
        rez += cexp(pi*cmuli(n*n*tau + 2.*n*z));
    }
    return rez;
}

// Z = 0,1/5
vec2 theta0(vec2 tau)
{
    vec2 z = vec2(0,.5);
    vec2 rz = vec2(0);
    for(float n = -12.; n<12.; n++)
    {
        rz += cexp(pi*n*n*cmuli(tau) + 2.*pi*n*cmuli(z));
    } 
    return rz;
}
#endif

// j-function / j-invariant
vec3 jfunc(vec2 z)
{
    if (z.y < -.0) return vec3(0);
    // using auxilliary theta functions
    vec2 et = eta(z);
    vec2 a = cdiv(2.*eta2(2.*z), et); // ϑ_10 (θ_2)
    vec2 b = cdiv(eta2(0.5*(z+vec2(1,0))), eta(z + vec2(1,0))); // ϑ_00 (θ_3)
    vec2 c = cdiv(eta2(.5*z), et); // ϑ_01 (θ_3) 
    vec2 num = cpow(cpow(a,8.) + cpow(b,8.) + cpow(c,8.), 3.);
    vec2 den = cmul(cmul(a,b),c);    
    vec2 rz = 32.*cdiv(num, cpow(cmul(cmul(a,b),c),8.));
    float of = 1.;
    #if 1
    // Hack to get higher precision
    if (length(rz) > 1e20)
    {
        of = 7.;
        a *= of;b *= of;c *= of;
        rz = cdiv(num, cpow(cmul(cmul(a,b),c),8.));
    }
    #endif
    
    return vec3(rz,of);
}

#ifdef USED
// Modular lambda function
vec2 lambda(vec2 z)
{
    vec2 nm = 1.414*cmul(eta(z*0.5), eta2(2.*z));
    return cpow(cdiv(nm, eta3(z)), 8.);
}

// Lambert series
vec2 lambert(vec2 z)
{
    vec2 rz = vec2(0);
    for(float n = 1.; n<75.; n++)
    {
        vec2 q = qn(z, n);
        rz += 10.*n*cdiv(q, vec2(1.,0.) - q);
    }
    return rz;
}

// e4 as a series of coefficients
int[100] coeffs = int[100](1, 240, 2160, 6720, 17520, 30240, 60480, 82560, 140400, 181680, 272160, 319680, 490560, 527520, 743040, 846720, 1123440, 1179360, 1635120, 1646400, 2207520, 2311680, 2877120, 2920320, 3931200, 3780240, 4747680, 4905600, 6026880, 5853600, 7620480, 7150080, 8987760, 8951040, 10614240, 10402560, 13262640, 12156960, 14817600, 14770560, 17690400, 16541280, 20805120, 19081920, 23336640, 22891680, 26282880, 24917760, 31456320, 28318320, 34022160, 33022080, 38508960, 35730720, 44150400, 40279680, 48297600, 46099200, 52682400, 49291200, 61810560, 54475680, 64350720, 62497920, 71902320, 66467520, 80559360, 72183360, 86093280, 81768960, 93623040, 85898880, 106282800, 93364320, 109412640, 105846720, 120187200, 109969920, 132935040, 118329600, 141553440, 132451440, 148871520, 137229120, 168752640, 148599360, 171737280, 163900800, 187012800, 169192800, 206025120, 181466880, 213183360, 200202240, 224259840, 207446400, 251657280, 219041760, 254864880, 241997760);
vec2 e4Series(vec2 z)
{
    vec2 rz = vec2(1,0);
    for(int i = 1; i < 100; i++)
    {
        rz += float(coeffs[i]) * cpow(qn(z, 1.), float(i));
    }
    return rz;
}
#endif

vec3 f(vec2 z)
{   
    vec3 v = vec3(0);
    z = abs(z);
    
    v = jfunc(z); v.xy*=1e-16; //coloring scale
    //v.xy = eta8(z);
    //v.xy = e4(z);
    //v.xy = e4Series(z);
    //v.xz = lambert(z);
    //v.xz = lambda(z);
    //v.xz = theta0(z);
    
    return v;
}

vec3 render(vec2 p)
{

#ifdef DISC
        float t = iTime;
        float lz = length(p);
        p *= rot(-t*.15);
        p = qinv(p);
        p *= rot(-t*0.07 + 1.57);
        p.x += iTime*.22;
        
#else
        p.y += 1.;
        p *= 0.74;
#endif
    
    //numerical derivatives for coloring
    vec2 e = vec2(0.0001,0.);
    vec3 col = vec3(0);
    
    vec3 z0 = f(p);
    vec3 bz0 = z0;
    vec3 zrg = f(p + e);
    vec3 zup = f(p + e.yx);
    float z0tt = atan(bz0.y,bz0.x);
    
    float frq = .3;
    float z0t = sin(frq*atan(z0.y,z0.x));
    float zrgt = sin(frq*atan(zrg.y,zrg.x));
    float zupt = sin(frq*atan(zup.y,zup.x));
    
    float z = log(length(z0.xy));
    float z2 = log(dot(z0.xy,z0.xy));
    float zrg2 = log(dot(zrg.xy,zrg.xy));
    float zup2 = log(dot(zup.xy,zup.xy));
    
    
    vec3 nor = normalize(vec3(zrg2 - z2, .0007, zup2 - z2));
    nor.xz *= rot2(iTime*.7);
    
    float dif = clamp(dot(nor, normalize(vec3(0.5,1.,0.5)))+.5,0.,1.);
    vec3 norPhase = normalize(vec3(zrgt - z0t, 0.001, zupt - z0t));
    float difPhase = dot(norPhase, normalize(vec3(0.5,.5,0.5)))*.5+0.5;
    
#ifdef ALT_PALETTE
float off = 0.;
    if (z0.z == 7.) off = -5. - sin(iTime*0.5);
    col = pal(sin(z0t + 1.5708)*2.5 + -z2*(0.05 + sin(iTime*0.5)*0.01) - 4. + off);
    col /= abs(sin(z*1.5 + 0.1))*0.25+.9;
    col /= abs(sin(z0tt*1. + iTime*.4))*0.5 + .45;
    col /= difPhase*.4+.7;
    col /= dif*1. + .9;
#else
    float off = 0.;
    if (z0.z == 7.) off = -5. - sin(iTime*0.5);
    col = pal((abs(z0tt+1.)+.5)*0.2 - z2*(0.05 + sin(iTime*0.5)*0.01) + off - 1.3 - (sin(z0tt*2.+1.5708)*2.)*.0);
    col /= difPhase*.4+.8;
    col /= dif*0.55 + .8;
#endif
    
    return col;
}


// simple mouse rotate and zoom for shader
//#define pi 3.14159265359 

mat2 r2d(float a) {
    return mat2(cos(a),sin(a),-sin(a),cos(a));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = 2.0 * (fragCoord.xy - iResolution.xy*0.5)/iResolution.y;

    vec3 col = render(p);
    fragColor = vec4(col,1.0);
}
