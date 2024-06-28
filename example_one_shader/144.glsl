/*originals https://www.shadertoy.com/view/dtVcDz https://www.shadertoy.com/view/43tGW4*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)

#define hr vec2(1., sqrt(3.))
#define PI 3.141592
#define TAU (2.*PI)
#define time (iTime*0.5)

float hash21 (vec2 x)
{return fract(sin(dot(x,vec2(12.4,18.4)))*1245.4);}

mat2 rot (float a)
{return mat2 (cos(a),sin(a),-sin(a),cos(a));}

void mo (inout vec2 p, vec2 d)
{
    p = abs(p)-d;
    if (p.y>p.x) p = p.yx;
}

float stmin (float a, float b, float k, float n)
{
    float st = k/n;
    float u = b-k;
    return min(min(a,b), 0.5*(u+a+abs(mod(u-a+st,2.*st)-st)));
}

float hd (vec2 uv)
{
    uv = abs(uv);
    return max(uv.x, dot(uv, normalize(hr)));
}

vec4 hgrid (vec2 uv,float detail)
{
    uv *= detail;
    vec2 ga = mod(uv,hr)-hr*0.5;
    vec2 gb = mod(uv-hr*0.5,hr)-hr*0.5;
    vec2 guv = (dot(ga,ga)< dot(gb,gb))? ga: gb;
    
    vec2 gid = uv-guv;
    
    guv.y = 0.5-hd(guv);
    
    return vec4(guv,gid);
}

float hexf (vec2 uv)
{
    float det = 3.;
    float speed = 0.5;
    float d = 0.;
    for (float i=0.; i<3.; i++)
    {
        float ratio = i/5.;
   
    	
        d += step(hgrid(uv, det).y,0.03);
        speed -= 0.1;
        det ++;
    }
    return d;
}

float box (vec3 p, vec3 c)
{
    vec3 q = abs(p)-c;
    return min(0.,max(q.x,max(q.y,q.z))) + length(max(q,0.));
}

float fractal (vec3 p)
{
    float size = 1.;
    float d = box(p,vec3(size));
    for (float i=0.; i<10.; i++)
    {
        float ratio = i/10.;
        p.xy *= rot(time*2.1);
        p.xz *= rot(time*2.1);
         p.yz *= rot(time*2.1);
        mo(p.xy, vec2(2.+ratio));
  
       
        size -= ratio*1.5;
        d= stmin(d,box(p,vec3(size)),1., 4.);
    }
    return d;
}

float g1 = 0.;
float SDF (vec3 p)
{
    float d = fractal(p);
    g1 += 0.1/(0.1+d*d);
    return d;
}
#define H(h)(cos((h)*6.3+vec3(12,23,21))*.5+.5)

#define hr vec2(1., sqrt(3.))
#define PI 3.141592
#define TAU (2.*PI)
#define time (iTime*0.5)

float hash212 (vec2 x)
{return fract(sin(dot(x,vec2(12.4,18.4)))*1245.4);}

mat2 rot2 (float a)
{return mat2 (cos(a),sin(a),-sin(a),cos(a));}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
     vec2 uv = (2.*C-iResolution.xy)/iResolution.y;

    float mask = step(0.3, abs(sin(length(uv)-PI*time))+0.01);
    float fx = clamp(mix(1.-hexf(uv), hexf(uv), mask),0.,1.);
    
    float dither = hash21(uv);
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<100.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        n1=g*d;
        n1.z-=1.*iTime;
         n1.xz*=rot(iTime*0.05);
         n1.yz*=rot(iTime*0.05);
        a=10.;
        n1=mod(n1-a,a*2.)-a;
        s=6.+dither;
             float d2 = SDF(n1);
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
       
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            n1.y<n1.x?n1=n1.zyx:n1;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 )*d2;
         }
         g+=e=length(n1.yz)/s;
       //  g+=e=length(p.yx)/s;
    }
}