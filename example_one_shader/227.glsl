#define t iTime
#define r iResolution
vec3 hsv(float h,float s,float v){
    vec4 t=vec4(1.,2./3.,1./3.,3.);
    vec3 p=abs(fract(vec3(h)+t.xyz)*6.-vec3(t.w));
    return v*mix(vec3(t.x),clamp(p-vec3(t.x),0.,1.),s);
}
void mainImage( out vec4 o, in vec2 FC )
{
    o = vec4(0);
    o.a=1.;
    float i=0.,e=i,R=i,s=i;vec3 q=vec3(0),p=vec3(0),d=vec3(FC.xy/r.xy-vec2(.5,-.3),.8);
    for(q.zy--;i++<99.;){o.rgb+=hsv(.1,.15,min(e*s,.7-e)/35.);s=1.;p=q+=d*e*R*.2;p=vec3(log(R=length(p))-t*.8,exp(.8-p.z/R),atan(p.y,p.x)+t*.4);
        for(e=--p.y;s<3e2;s+=s)e+=dot(sin(p.yzz*s)-.5,.8-sin(p.zxx*s))/s*.3;}
}