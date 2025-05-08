#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
#define Q(p) p *= r(myround(atan(p.x, p.y) * 4.) / 4.)
#define r(a) mat2(cos(a + asin(vec4(0,1,-1,0))))

vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}


void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 p,r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));  
    for(
        float i=0.,g=0.,e,s;
        ++i<99.;
        O.rgb+=mix(r/r,H(log(s)),.7)*.08*exp(-i*i*e))
    {
        p=g*d;
       
        p.z-=.8;
        p=R(p,normalize(vec3(1,0,-5)),iTime*.3);  s=4.;
         Q(p.xy);
        for(int j=0;j++<8;)
            p=abs(p),
            p=p.x<p.y?p.zxy:p.zyx,
             p=p.z<p.y?p.zxy:p.zyx,
            
            s*=e=1.8/min(dot(p,p),1.3+0.1*cos(iTime)),
            p=p*e-vec3(12,3,3);
            
            float c = mod(iTime,10.);
            
            if(c<2.5){
        g+=e=length(p.xzzx)/s;
  }
         
            if(c<5. && c>2.5){
        g+=e=length(p.zzx)/s;
  }
      
           
            if(c>5.){
        g+=e=length(p.xyzx)/s;
  }
  
  
    }
    O=pow(O,vec4(5));
 }