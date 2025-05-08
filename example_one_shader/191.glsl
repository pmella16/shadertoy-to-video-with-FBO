float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdCappedTorus( vec3 p, vec2 sc, float ra, float rb)
{
  p.x = abs(p.x);
  float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

mat3 rotateX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0,  0.0,  0.0,
        0.0,  c,    -s,
        0.0,  s,    c
    );
}
mat3 rotateY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c,   0.0,  s,
        0.0, 1.0,  0.0,
        -s,  0.0,  c
    );
}
mat3 rotateZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c,   -s,  0.0,
        s,    c,  0.0,
        0.0,  0.0, 1.0
    );
}

vec3 applyRotation(vec3 p, vec3 eulerAngles) {
    mat3 rotX = rotateX(eulerAngles.x);
    mat3 rotY = rotateY(eulerAngles.y);
    mat3 rotZ = rotateZ(eulerAngles.z);
    return rotZ * rotY * rotX * p;
}

float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

float noise(vec3 x) {
    const vec3 step = vec3(110, 241, 171);

    vec3 i = floor(x);
    vec3 f = fract(x);
 
    // For performance, compute the base input to a 1D hash from the integer part of the argument and the 
    // incremental change to the 1D based on the 3D -> 1D wrapping
    float n = dot(i, step);

    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
} 

float map (vec3 p) {
    vec3 q = p;
    //q = applyRotation(q,vec3(0.,iTime/30.,0.));
    //q += normalize(q)*(sin(iTime)-1.)*10.-25.;
    //q = mod(q,10.)-5.;
    //q = applyRotation(q,vec3(-iTime,0.,0.));
    //return sdTorus(q,vec2 (0.25,0.15));
    q.z += iTime*30.;
    q = applyRotation(q,vec3(0.,0.,iTime/10.));
    return noise(q*.003)*1. + noise(q*.02)*2.-.5 + noise(q*.1)*2.-1. +noise(q*0.8)*0.05;
}

float mapn (vec3 p){
    return map(p);
}

vec3 normal(in vec3 pos) {
    vec3 eps = vec3(0.001,0.0,0.0);
    vec3 nor = vec3(
        mapn(pos + eps.xyy) - mapn(pos - eps.xyy), 
        mapn(pos + eps.yxy) - mapn(pos - eps.yxy), 
        mapn(pos + eps.yyx) - mapn(pos - eps.yyx)
    );
    return normalize(nor);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord*2.-iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.0);
    vec3 ro = vec3(0.0,0.0,-10.);
    vec3 rd = normalize(vec3 (uv.x,uv.y,.5));
    float t = 0.;
    vec3 p = ro;
    //float str = 1.;
    for (int i = 0; i < 800; i++){
         p = ro + rd * t;
         float d = map(p);
         if (i==0) d = max(map(p),40.);
         t+=d;
         if(d<t*0.002) break;
         //if(d<0.01 && noise(round(p))>0.9){ro = reflect(-ro,normal(p));}
    }
    //col = vec3 (dot(normal(p),vec3(0.0,1.0,0.0))/2.+0.5) / (t*0.25);
    //col += vec3(1,atan(rd.x,rd.z)/3.14+0.3,atan(rd.y,rd.z)/3.14+0.3) * 1.+t*.004-;
    vec3 lghtsrc = vec3 (.0,1.,.0);
    col = vec3 (length(p-ro)/20.,1.-length(p-ro)/20.,1.*noise(p/5.))*t*0.0003;
    col += 0.8*vec3 (0.,dot(normal(p),lghtsrc)/2.+0.5,dot(normal(p),lghtsrc)/2.+0.5);
    fragColor = vec4 (col,1.0);
}