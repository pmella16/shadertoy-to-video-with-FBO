float hash1(vec2 p)
{
 	return fract(sin((p.x*91.5-p.y*82.6) /**(0.0001*iTime+1000.0)*/ )*377.4  *(0.001*iTime+1000.0) ); 
}
#define Q(p) p *= 2.*r(round(atan(p.x, p.y) * 4.) / 4.)
#define r(a) mat2(cos(a + asin(vec4(0,1,-1,0))))


float pi = 3.14159;
//d1 metric
float d1(vec2 point)
{
    return abs(point.x) + abs(point.y);
}

vec3 pallete( float t )
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1., 1., 1.);
    vec3 d = vec3(0.236, 0.416, 0.557);
    
    return a + b*cos( 2. * pi *(c*t+d) );
}
#define rot(a) mat2(cos(a + vec4(0, 11, 33, 0)))
float PI = 3.141592653589;

float s(in float x) {return sin(mod(x, PI*2.));}

float hash(in float x) {
    return fract(s(x*1035.2362)*125. + s(x*1612.)*1612.512 + 125.6125)*2.-1.;
}
float noise(in float time) {
    return mix(hash(floor(time)), hash(floor(time)+1.0), 0.5-0.5*cos(fract(time)*PI));
}

vec3 ifs_color, ro, color, id;
float ifs_scale = 1.7, obj=0.;
mat2 rot3(float a) {return mat2(cos(a),-sin(a),sin(a),cos(a));}

vec2 hexagon( in vec2 p, in float r )
{
     vec3 k = vec3(-0.5,0.5,0.5);

    p = abs(p);
    
    p -= 4.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.y, ceil(k.x), k.x), r);
    
     p.xy*=rot3(iTime*0.001);
     vec3 r2 = normalize(vec3(k.xy, 1.0 - dot(k.xy, k.xy) *5.3));

    return p; //length(p)*sign(p.y); //return the transformed p instead of distance
}
float fbm(in float time) {
    float v = 0.0;
    for (float i = 0.0; i < 3.; i++) {
        v += noise(time)*exp(-i);
        time += 100.;
        time *= 2.0;
    }
    return v*0.5;
}

#define PI 3.1415926



vec3 pal(float t)
{
    return 0.6 + 0.4 * cos(5.0 * (t + vec3(0.4, 0.8, 0.1)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float aa = 5.;
    vec2 uv2 = fragCoord/iResolution.xy-.5;
    
    
      vec2 baseUV = (fragCoord * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);

    float t = iTime * 0.7;
    vec3 col = vec3(0.0);

    for (int l = 0; l < 7; l++)
    {
        float layerScale = 1.0 + 1. * float(l);
        vec2 uv = baseUV * layerScale;

        float layerRot = t + float(l) * 0.5;
        uv = rot(layerRot) * uv;
        
        float ang = atan(uv.y, uv.x) / PI;
        float dst = length(uv);

        float mask = smoothstep(0.05, 0.04, fract(dst * 2.0 - t * 1.));

        vec3 layerCol = pal(ang * float(l) + t * 3.) * mask;

        float alpha = 0.9 * exp(-float(l) * 0.4);
        col += layerCol * alpha;
    }
    
    
   float c2 = fbm(iTime*1.11);
      vec3 r2 = normalize(vec3(uv2.xy, 1.0 - dot(uv2.xy, uv2.xy) *5.3));
     uv2/=1.-uv2.y*2.+c2;
    ;
    
    vec2 hex= hexagon(uv2,2.4);
    vec3 n = vec3(0);
       hex.xy*=rot(iTime*0.21);
    for(float x = 0.;x<aa;x++)
    for(float y = 0.;y<aa;y++)
    {
        vec2 uv = (fragCoord+vec2(x,y)/aa)/iResolution.y;
        
      uv/=1.-uv.y*1.*c2;
         uv=hex;
   uv += rot(uv.x) * uv;
        vec2 ang = sqrt(vec2(2.9,.1));
        uv *= mat2(ang,-ang.y,ang.x);
 uv+=hex+c2;
uv*=rot(iTime*0.21);
        float h1 = floor(hash1(floor(uv*8.))+.5);
        float h2 = hash1(floor(uv*vec2(8.+120.*h1,120.-120.*h1))+.9);
        float h3 = pow(hash1(floor(uv*8.)+.1),.2);
        n += pow(vec3(h2*h3),vec3(3,2,1));
    }
    float v = length(fragCoord/iResolution.xy-.5);
    n /= aa*aa;
    n /= 1.+4.*v*v;
    fragColor = vec4(n*vec3(2.2,0.5,2.),1);
}