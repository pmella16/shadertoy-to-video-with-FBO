/*originals https://www.shadertoy.com/view/DlycWR*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(25,5,15))*0.55+.5)
float rand(float i) {
    return fract(sin(i)*100000.);
}

float rand(float i, float n) {
    return fract(sin(i)*100000.*(1.+rand(n)));
}

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float sm(float t) {
    return t*t*(3.-2.*t);
}

float noise(float i) {
    return mix(rand(floor(i)), rand(floor(i)+1.), sm(fract(i)));
}

float noise(float i, float n) {
    return mix(rand(floor(i), n), rand(floor(i)+1., n), sm(fract(i)));
}
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    float c34 = rand(20.,10.);
    float c35 = noise(10.,14.);
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    vec3 c = H(d.x+0.41*cos(iTime));
    for(float i=0.,a,s,e,g=0.;
        ++i<112.;
        O.xyz+=mix(vec3(1),H(g*.1)*c,sin(.8))*1./e/8e3
    )
    {
        n1=g*d;
        n1.z-=iTime*1.0;
        a=10.;
        n1=mod(n1-a,a*2.)-a;
         if(n1.z < 00.15 && n1.x < 00.515 ){
        n1.yx*=mat2(cos(iTime*0.1),sin(iTime*0.1),-sin(iTime*0.1),cos(iTime*0.1));
           }
           
        s=10.;
        for(float i=0.;i++<8.;){
            n1=.3-abs(n1);
            if(n1.x > 0.2 ){
            n1.z+=1.*cos(iTime);
            }
             if(n1.y > 00.25 ){
            n1.x+=1.*cos(iTime);
           
            }
             if(n1.z > 00.25 ){
            n1.y+=1.*cos(iTime);
            n1.yz*=mat2(cos(iTime*0.1),sin(iTime*0.1),-sin(iTime*0.1),cos(iTime*0.1));
            }
            n1.z*i<n1.x*c34?n1=n1.zyx:n1;
            n1.z*c34<n1.x?n1=n1.xzy:n1;
             
         
            s*=e=1.5+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3( g*c34+(iTime*.003+.5*(iTime*.003))*3.,  10.+(i+g),  c34+(iTime*.0002)*5.
                 );
                
         }
         
          g+=e=length(n1.xy)/s;
         
    }
}