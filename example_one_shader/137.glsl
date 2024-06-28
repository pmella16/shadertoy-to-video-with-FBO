#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*4.3+vec3(10.,53,31))*2.5+.5)
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*2.1),sin(.8))*1./e/8e3
    )
    {
       n1=g*d;
      
       n1.xy*=floor(abs( n1.xy));
      
        n1.z+=dot(abs( n1.y),abs( n1.y) );
        a=20.;
        n1=mod(n1-a,a*2.0)-a;
        s=5.;
       
        n1.xy*=mat2(cos(iTime*0.55),sin(iTime*0.55), -sin(iTime*0.55),cos(iTime*0.55) );
        
      
        for(float i=0.0;i<8.00;i++){
            n1=.2-abs(n1);
           
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3(
                    2.+cos(iTime*.03+.05*cos(iTime*.03))*3.,
                    70,
                    2.+cos(iTime*.05)*1.
                 );
         }
         g+=e=length(n1.xyz)/s;
          
    }
}