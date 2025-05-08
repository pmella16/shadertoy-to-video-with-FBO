#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

const float PI = 3.141592653589793;
const float INV_TAU = 1.0 / PI;

const float uniRotationSpeed = 2.0;
const float uniRotationSpread = 1.0;
const float uniZoomSpeed = 0.5;
const float uniRingsGrowthFactor = 0.50;
const float uniRingsThickness = 1.0 / .50;
const float uniShadowSpread = 0.2;
const float uniShadowIntensity = 0.5;

vec2 getPolar(in vec2 fragCoord) {
    float aspect = iResolution.y / iResolution.x;
    vec2 uv = fragCoord/iResolution.xy;
    vec2 xy = vec2(1.0, aspect) * 2.0 * (uv - vec2(0.5));
    return vec2(length(xy), atan(xy.y, xy.x));
}

#define RND(X) fract(sin(dot(X, vec2(131.0, 1234.1))) * 2132.1)
#define RT(X) mat2(cos(X), -sin(X), sin(X), cos(X))

float s_noise(vec2 uv)
{
vec2 i = floor(uv);
vec2 f = fract(uv);
float a = RND(i + vec2(0, 0));
float b = RND(i + vec2(1, 0));
float c = RND(i + vec2(0, 1));
float d = RND(i + vec2(1, 1));

vec2 u = smoothstep(0.0, 1.0, f);
return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;


}


void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
      vec2 uv = (C - 0.5 * iResolution.xy) / iResolution.y;
     vec2 polar = getPolar(C);
    float r = polar.x;
    float a = polar.y;
    float light = uniRingsThickness * log(pow(r, uniRingsGrowthFactor))- iTime*1. -(uniZoomSpeed);
    float n = floor(light);
    float phase = n * 7.0;
    a += (phase + uniRotationSpeed + iTime*1.) * uniRotationSpread;
    float radial = fract(a * INV_TAU * 2.0);
    float selection = fract(.5 * light);
    vec3 col = selection < 0.5 ? vec3(1,0.667,0.0) : vec3(0, 0.333, 1.0);
    float v = fract(light);
    float u = radial;
    col *= u;
    col *= v;
    col *= .6;
    col += vec3(0.6);
 
    float shade = smoothstep(0.0, uniShadowSpread, v) * uniShadowIntensity + (1.0 - uniShadowIntensity);
    col *= shade;
    vec3 r3 = normalize(vec3(uv, 1.1 - dot(uv, uv) * 15.002*cos(iTime)));
    vec3 n1,p,q,r2=iResolution,
    d=normalize(vec3((C*2.-r2.xy)/r2.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(0.5,0.5,1.),H(g*.1),.8)*2./e/8e3
    )
    {
        p=g*d;
p.xz+=refract(p.xy,p.xy,0.251*cos(iTime));
        a=30.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p=.3-abs(p-r3);
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            s*=e=2.1+sin(iTime*.01)*.1;
            p=abs(p)*e-
                vec3(
                    5.*3.,
                    120,
                    8.*5.
                 )*col;
         }
         g+=e=length(p.yzzz)/s;
    }
}


