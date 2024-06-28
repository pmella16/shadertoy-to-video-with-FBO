////////////////////////////////////////////////////////////////////////
#define pi acos(-1.)
#define deg pi/180.
#define time iTime*pi/40.
#define R iResolution.xy
#define ar R.x/R.y
vec3 cs = vec3(1.,2.,3.);
mat2 r2d(float a) {
    return mat2(cos(a),sin(a),-sin(a),cos(a));
}
float sdBox(vec2 p, vec2 s) {
    vec2 q = abs(p)-s;
    return length(max(q,0.))+min(0.,max(q.x,q.y));
}

vec3 c1(vec2 uv, float t, float ij) {
        vec3 col = vec3(0.);
    float ds = sin(t/2.)*0.5+0.5;
    //ds += 1./ds;
    ds *= 2.;
    uv -= 1./(1./ds*60.);
    uv = uv/dot(uv,uv);
    uv += ds/2.;
    uv = uv/dot(uv,uv);
    uv += vec2(sin(t),cos(t))*2.;
    uv *= r2d(t/2.);
    float s = 3.;
    vec2 gv = floor(uv*s-0.5);
    vec2 ov = uv;
    uv = (fract(uv*s-0.5)-0.5)/s;
    col += smoothstep(0.005,0.,sdBox(uv,vec2(0.1))-0.02)*(sin(cs*1.8+uv.x*sin(t*3.+ij)*1.+uv.y*cos(t*2.+ij)*1.+t*2.+ij*2.+gv.x*1.5+gv.y*1.25)*0.5+0.5);
    col += smoothstep(0.005,0.,abs(sdBox(uv,vec2(0.103))-0.03)-0.002)*(sin(cs*1.8+atan(uv.x,uv.y)+t*120.+gv.y*3.-gv.x*4.+ij*+100.)*0.4+0.9);
    //ov *= r2d(deg*45.*ij*10.);
    //col *= smoothstep(0.01,0.,abs(ov.x)-0.475*3.2);
    return col;
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 tv = uv;
    uv -= 0.5;
    uv.x *= ar;
    vec3 col = vec3(0.);
    float gs = sin(time*0.14)*0.5+0.5;
    float gs2 = sin(time*0.02)*0.1+0.9;
    gs *= 1.-(1./(time+1.));
    gs2 *= 1.-(1./(time*0.1+1.));
    float r = deg*sin(time*0.1)*gs;
    //uv *= 1.1+sin(time);
    uv *= 1.+cos(time*0.01)*0.9;
    for (int j=0;j<6;j++) {
    uv *= r2d(sin(time*0.05)*pi*0.5*gs+deg);
    float jj = float(j)/9000.;
    for (int i=0;i<20;i++) {
        float ii = float(i)/500.*gs2;
        uv *= r2d(r*sin(time*0.01)*gs);
        uv *= 1.+sin(time*0.005)*0.05;
        col += c1(uv,time/2.+ii+jj, ii-jj*4.)/120.;
    }
    }
    //col *= 2.;
    //col -= 0.5;
    
    fragColor = vec4(col,1.0);
}