#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*2.3+vec3(12,33,41))*.5+.5)

float maxcomp(in vec3 p ) { return max(p.x,max(p.y,p.z));}
float sdBox( vec3 p, vec3 b )
{
    vec3  di = abs(p) - b;
    float mc = maxcomp(di);
    return min(mc,length(max(di,0.0)));
}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,cos(iTime*0.1)));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        n1=g*d;
        float f34= sdBox(vec3(vec2(n1.z,n1.y)*mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime)),n1.z),d);
        n1.z+=iTime*1.1;
        a=20.;
        n1=mod(n1-a,a*2.0)-a;
        s=5.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
            
            n1.x<n1.z?n1=n1.zxz:n1*f34;
            n1.z<n1.y?n1=n1.xzy:n1+f34;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3(
                    5.+cos(iTime*.3+.5*sin(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.+f34
                 );
         }
         g+=e=length(n1.yx)/s;
    }
}