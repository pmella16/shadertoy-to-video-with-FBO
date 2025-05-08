
#define M_PI 3.1415926535897932384626433832795
#define M_PI2 6.2831853071795864769252867675590



int divs = 10;
int iterations = 5;

vec3 getRamp(float p) {
    return vec3(.5)
        + sin(
            p * M_PI2 + M_PI2 * vec3(.4,.2,.1)
        )
        * .5;
}

vec3 _cNP(vec3 p, float s) {
    float tp = sin(iTime * .5 + s * 1.7) * .5 + .5;
    float ti = mod(iTime * .1 - s * 1., 1.) ;

    vec2 rotationCenter = vec2(.3, .0) / (s * 1.5);
    vec2 np = p.xy - rotationCenter;
    float a = atan(np.y, np.x) + (M_PI + M_PI * tp) + s * .01;
    np = vec2(cos(a), sin(a)) * length(np );
    return vec3(np.xy, a);
}

vec3 _ocNP(vec3 p, float s) {
    float ti = mod(iTime * .1 + s * .5, 2.);
    vec2 tp = vec2(.2, .0) / (s * 1.);
    float tpa = atan(tp.y, tp.x) + p.z ;
    tp = vec2(cos(tpa), sin(tpa)) * length(tp);
    vec2 np = p.xy - tp;
    float a = atan(np.y, np.x) + (M_PI * ti);
    np = vec2(cos(a), sin(a)) * length(np );
    return vec3(np.xy, mod(a + M_PI2, M_PI2));
}



vec3 gC(vec2 p) {
    vec3 col = (p.y < 0.001) ? vec3(1.) : vec3(.0);
    vec3 np = vec3(p.xy, 0.);
    for (float i = 0.; i < float(iterations); i += 1.) {
        np = mod(i, 2.) < 1. ? _cNP(np, i + 1.) : _ocNP(np, i + 1.);
        float npl = length(np);

        //col += vec3(length(np.xy) * 2., np.z / M_PI2 * .4 , .1 ) * np.x * i;
        col += (np.x > 0.) ? getRamp(npl * .2 + .7 + i * .6 ) * .3 : vec3(.1);
        col += (np.y >= -0.0001 && np.y < 0.001) ? vec3(.01) : vec3(.0);
        col += (np.y >= 0.0 && np.y < 0.01 + 0.0001 ) ? vec3(.5 * (3. - i)) * (.1 + i * .1) : vec3(.01);
        col += (np.y >= 0.0 && np.y < 0.0011 && np.x > 0.) ? vec3(.6) : vec3(.0);
    }
    col += (p.y < 0.001) ? vec3(.05) : vec3(.0);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // NORMALIZE!!! tam tam tcham!
    vec2 p = fragCoord.xy / iResolution.x - vec2(.5) * vec2(1., iResolution.y / iResolution.x);
    //p.y = abs(p.y);
    vec3 col = vec3(0.);
    float div = float(divs) * 2.;
    float divS = M_PI2 / div;

    float a = mod(atan(p.y, p.x) + M_PI * .5 * iTime * .2, M_PI2);
    float l = length(p);
    float q = floor(a / divS);
    float s = 1.;
    for (float i = 0.; i < div; i += 1.) {
        if (q == i) {
            a -= i * divS - (s * .5 - .5) * divS ;
            p = vec2(cos(a), sin(a)) * l ;
            p.y *= s;
            col = gC(p);
        }
        s *= -1.;
    }

    fragColor = vec4(col, 1.);
}


