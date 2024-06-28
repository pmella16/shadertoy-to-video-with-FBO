#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)cos((h)*6.3+vec3(0,23,21))*.5+.5

// https://iquilezles.org/articles/distfunctions2d
float sdHexagon(vec2 p, float r)
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 po,r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));  
   
    float i=0.,g=0.,e,s;
    for(;++i<99.;){
        po=d*g;
   
        po=R(po,vec3(1),iTime*.0);
        po.z+=iTime*0.2;
        po=asin(sin(po*4.));
        float sdf=sdHexagon((po.xy)*mod(C.y,5.),1.*cos(iTime));
        po.xy=vec2(sdf);
       
        s=2.;
        for(int i=0;i++<7;){
po=vec3(3.2,7.8,0.2)-abs(po-vec3(1.4,4.8,2.4));            
          po=po.x<po.y?po.zxy:po.zyx;
              po.z<po.x?po.xy:po.zx;
            s*=e=19.8/min(dot(po,po),11.8);
            po=abs(po)*e;
        }
        g+=e=abs(po.y)/s+.001;
        O.xyz+=(H(log(s)*.8)+.5)*exp(sin(i))/e*3e-5;
    }
    O*=O*O*O;
 }
