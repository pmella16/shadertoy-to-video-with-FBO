#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

#define QUARTER_PI 0.785398

float LineSDF(vec2 p, vec2 a, vec2 b, float s) {
    vec2 pa = a - p;
    vec2 ba = a - b;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
    float d = length(pa - ba * h) - s;
    return d;
}

float Draw(vec2 uv, vec2 dir) {
    float size = .005;
    float d = LineSDF(uv, dir.xx, dir.xy, size);
    return smoothstep(fwidth(d), 0., d);
}

vec2 Reflect45(vec2 uv) {
    vec2 n = vec2(sin(-QUARTER_PI), cos(QUARTER_PI));
    float d = dot(uv, n);
    uv -= n * min(0., d) * 2.;
    return uv;
}

#define ITERATION sin(iTime * .2) * 3. + 3.

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    
    
    vec2 uv = (C - .5 * iResolution.xy) / iResolution.y;
    uv *= 2.;
    //uv = fract(uv) - .5;
    //uv *= 2.;
    vec3 col = vec3(0);
    vec2 dir = vec2(0, .5);
    uv = Reflect45(abs(uv));    
    
    col += Draw(uv, dir);
    for(float i = 1.; i < ITERATION; i++) {
        uv -= dir;
        uv.x = abs(uv.x);
        uv = Reflect45(uv);
        dir *= .5;
        col = max(col, vec3(Draw(uv, dir)));
    }
    
 
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(0.1,0.5,2.),H(g*.1),.8)*3./e/8e3
    )
    {
    
        p=g*d;
            
        p.z-=iTime*10.;
       p.xz*=uv+cos(iTime)*2.5;
       
        a=30.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p.xy+=uv;
            p=.3-abs(p);
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            s*=e=1.7+sin(iTime*.01)*.1;
            p=abs(p)*e-
                vec3(
                    5.*3.,
                    120,
                    8.*5.
                 );
         }
         g+=e=length(p.yz)/s;
    }
}