#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
float TAU = 2.*3.14159;
mat3 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float c = cos(angle);
    float s = sin(angle);
    float oc = 1.0 - c;

    return mat3(
        vec3(c + axis.x * axis.x * oc, axis.x * axis.y * oc - axis.z * s, axis.x * axis.z * oc + axis.y * s),
        vec3(axis.y * axis.x * oc + axis.z * s, c + axis.y * axis.y * oc, axis.y * axis.z * oc - axis.x * s),
        vec3(axis.z * axis.x * oc - axis.y * s, axis.z * axis.y * oc + axis.x * s, c + axis.z * axis.z * oc)
    );
}
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
       vec2 uv = (C/iResolution.xy - .5);
        
      vec3 r2 = normalize(vec3(uv, 1.1 - dot(-uv, uv) * 15.002*cos(iTime)));
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(0.1,0.2,3.),H(g*.1),.8)*10./e/8e3
    )
    {
  
        n1=g*d+r2*10.;
       n1.xy/=vec2(fract(log(length(n1.xy))+iTime*0.25));
        n1*=rotationMatrix(vec3(0.1,.0,0.),iTime);
;
        a=30.;
        n1=mod(n1-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            s*=e=1.7+sin(iTime*.01)*0.51;
            n1=abs(n1)*e-
                vec3(
                    7.*3.,
                    120,
                    2.*5.
                 );
         }
         g+=e=length(n1.yzzz)/s;
    }
}