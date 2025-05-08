// Fork of "Fractal 29_gaz" by gaz. https://shadertoy.com/view/wtGfRy
// 2024-07-04 21:33:17

#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
void mainImage(out vec4 O, vec2 fc)
{
    O=vec4(0);
    vec3 p,r=iResolution,
    d=normalize(vec3((fc-.5*r.xy)/r.y,1));  
    for(float i=0.,g=0.,e,s;
        ++i<99.;
        O.xyz+=5e-5*abs(cos(vec3(3,2,1)+log(s*6.)))/dot(p,p)/e
    )
    {
        p=g*d;
        p.z+=iTime*0.3;
        p=R(p,normalize(vec3(0,0,7)),.8);   
        s=2.8;
        p=abs(mod(p-1.,8.)-1.7)-1.6;
        for(int j=0;j++<10;)
            p=1.-abs(p-1.),
            s*=e=-1.9/dot(p,p),
            p=p*e-.7;
            g+=e=abs(p.z)/s+.002;
            p.b*=pow(sin(iTime),8.0);
     }
}