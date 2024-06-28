/*originals  https://www.shadertoy.com/view/MdXSzS https://www.shadertoy.com/view/DtGyWh https://www.shadertoy.com/view/XX3SzN*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*2.3+vec3(20,23,11))*1.5+.5)

#define PI  3.141592
#define TAU 6.2831853071

float hash(vec2 p)
{
    p = fract(p * vec2(123.345, 734.6897));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}


float sdHex(vec2 p)
{
    p = abs(p);
    
    float d = dot(p, normalize(vec2(1., 1.73)));
    d = max(d, p.x);
    
    return d;
}


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat2 rot2D(float a)
{
    float c = cos(a);
    float s = sin(a);
    return mat2(c, s, -s, c);
}

vec4 hexMap(vec2 uv, float rot)
{
    vec2 r = vec2(1., 1.73);
    vec2 h = r * .5;
    
    vec2 gv1 = mod(uv, r) - h;
    vec2 gv2 = mod(uv - h, r) - h;
    
    vec2 gv;
    if (length(gv1) < length(gv2))
        gv = gv1;
    else
        gv = gv2;
    gv *= rot2D(iTime);
    vec2 id = uv - gv;
    gv *= rot2D(rot);
    
    float x = fract(atan(gv.x, gv.y) / TAU * 6.);
    float y = sdHex(gv) * 2. + sign(rot) * (sin(rot) * .5 + .5) * .3;
    
    x = abs(x * - .5);
    
    return vec4(x, y, id);
}

vec2 drawTile(vec2 uv, float fudge)
{
    vec2 id = floor(uv);
    id.y -= 3.;
    vec2 gv = fract(uv) - .5;
    gv.y *= -1.;
    
    vec2 cUv = gv - .5 * sign(gv.x + gv.y + .001);
    float angle = atan(cUv.y, cUv.x);
    
    vec2 tUv = vec2(mod((angle + PI) / 1.57079, 1.), 0.);
    tUv.x = abs(mod(id.x + id.y, 2.) - tUv.x);
    
    return tUv;
}
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
 vec2 uv = (C * 2. - iResolution.xy) / iResolution.y;
   uv *= rot2D(iTime*1.00505);
   
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        n1=g*d;
    
    vec4 hexMask = hexMap(uv*1.5, 0.);
    
            float c23 = sdHex(n1.xy);
        a=20.*hexMask.x;
        n1=mod(n1-a,a*2.)-a;
        s=6.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
         float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    n1.xy*=ma;
     n1.xy *= rot2D(iTime*0.05 );
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            n1.z<n1.y?n1=n1.zyx:n1;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            n1=abs(n1)*e-
                vec3(
                    5.+cos(iTime*.0+.5*cos(iTime*.0))*3.,
                    120,
                    8.+cos(iTime*.0)*5.
                 )*hexMask.x;;
         }
     
         g+=e=length(n1.yx)/s;
    }
}