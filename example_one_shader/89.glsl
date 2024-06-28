/*originals in user profile https://www.shadertoy.com/user/gaz"*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)cos(h*6.3+vec3(0,23,21))*.5+.5


float happy_lucky_beautiful_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
       
 vec2 uv = ( C - .5*iResolution.xy ) / iResolution.y;
 uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = 1.*sin(iTime * 1.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1
    vec3 r=iResolution,p;
    float i,g,e,l,s;
    for(i=0.;
        ++i<99.;
        e<.002?O.xyz+=mix(r/r,H(g),.5)*.8/i:p
        )
    {
    p=g*vec3((C-.5*r.xy)/r.y,1);
    p=R(p,R(normalize(vec3(0,0,1)),vec3(.0),iTime*1.10),.4);
   
  p.z+=-iTime*10.5;

    p=mod(p-1.+5.,4.)-2.;
    for(int k=0;k++<3;)
        p=abs(p),
        p=p.x<p.y?p.zxy:p.zyx;
         p*=p.y<p.y?p.zyx:p.xyz;
    s=2.;
    for(int j=0;j++<7;)
        s*=l=2./clamp(dot(p,p),.1,1.),
        p=abs(p)*l-vec3(1,1,8)+happy_lucky_beautiful_star(p.xy, anim) * vec3(0.55,0.5,0.55)*0.3;
    g+=e=length(p.xz)/s;
   
   
   
    }
   
 
    O+= vec4(happy_lucky_beautiful_star(uv, anim) * vec3(0.55,0.5,0.55)*0.3, 1.0);

}


