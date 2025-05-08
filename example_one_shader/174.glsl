#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(20,23,11))*.05+.5)
#define PI 3.14159265
#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

float cube(vec3 p,vec3 s){
  return length(max(abs(p)-s,0.));
}

vec2 fmod(vec2 p,float r){
  float a=atan(p.x,p.y)+PI/r;


  float n=(2.*PI)/r;
  a=floor(a/n)*n;
  return rot(a)*p;
}


float m1(vec3 p){


for(int i=0;i<5;i++){

  p=abs(p)-0.5;
   p.xz*=rot(iTime*0.05);
  p.xy*=rot(iTime*0.05);
  if(p.x<p.y)p.xy=p.yx;
  if(p.x<p.z)p.xz=p.zx;
  if(p.y<p.z)p.yz=p.zy;

  p.xy=fmod(p.xy,24.0);
  
 p.x-=abs(p.x)-0.5;
 p.y=abs(p.y)-0.15;

 float t=floor(iTime*0.25)+pow(fract(iTime*0.25),.5);


 p.z-abs(p.z)-0.45;




}


  float m=cube(p,vec3(.5,3.,2.));


  return m;
}

float map(vec3 p){

 p.z+=iTime*0.5;

   float t=floor(iTime*2.0)+pow(fract(iTime*2.0),.75);

 
float k=10.5;
p=mod(p,k)-k*0.5;

  float m=m1(p);

   p.xz*=rot(iTime*0.05);
  p.xy*=rot(iTime*0.05);
  return m;
}

vec3 gn(vec3 p){
   
  vec2 t=vec2(0.001,0.0);
  return normalize(
      vec3(
        map(p+t.xyy)-map(p-t.xyy),
        map(p+t.yxy)-map(p-t.yxy),
        map(p+t.yyx)-map(p-t.yyx)
        )
    );
}
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage(out vec4 O, vec2 C)
{
  O=vec4(0);
    vec3 p,r=iResolution,
    d=normalize(vec3((C-.5*r.xy)/r.y,1));
    vec2 st=(gl_FragCoord.xy*2.0-iResolution.xy)/min(iResolution.x,iResolution.y);

      vec3 ro=vec3(0,0,10.0);
      vec3 rd=vec3(st,-1.0);

      vec3 col=vec3(0,0,0);
      float d3,t=0.0,acc=0.0;

      for(int i=0;i<64;i++){
        d3=map(ro+rd*t);
        if(d3<0.001||t>1000.0)break;
        t+=d3;
        acc+=exp(-3.0*d3);
      }

    vec3 refo=ro+rd*t;
     vec3 n=gn(refo);
    rd=reflect(refo,n);
    ro=refo;
    t=0.1;
    float acc2=0.;
 vec2 uv = ( C - .5*iResolution.xy ) / iResolution.y;
    for(int i=0;i<32;i++){
      d3=map(ro+rd*t);
      if(d3<0.001||t>1000.0){
        t+=d3;
        acc2=exp(-3.0*d3);
      }

    }


    col=vec3(1.,0.5,1.)*acc*0.1;
    col+=vec3(0.,.5,1.)*acc2*0.075;
    float g=0.1,e,s;
    for(float i=0.;i<99.;++i)
    {
        p=g*d;
        
        p.z-=.2;
       p.xz*=rot(iTime);
        s=3.;
        for(int j=0;j<8;++j)
        {
    
            p=abs(p+col),p=p.x<p.y?p.zxy:p.zyx;
            s*=e=2./min(dot(p,p),1.2);
            p=p*e-vec3(3,3,3);
        }
        g+=e=length(p.xyz)/s+0.00007;
        // color matrix test
        mat3 m = mat3(
            .1,.0,.2,
            .0,.4,.4,
            .1,.7,.9
            );
        O.rgb+=m*(H(log(s)-.1)+.5)*.016*exp(-.4*i*i*e);  
    }
    O=pow(O,vec4(10.));
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    O+= vec4(happy_star(uv, anim) * vec3(0.35,0.42,0.75)*0.1, 1.0);
 }