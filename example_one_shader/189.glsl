#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*1.5+.5)
#define PI 3.14159265359

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}


vec3 neonColor(float t) {
    vec3 color = 0.5 + 0.5 * cos(6.28318 * (t * vec3(1.0, 1.0, 0.5) + vec3(0.0, 0.33, 0.67)));
    return pow(color, vec3(0.6)); // Restore original color intensity for a balanced vibrancy
}

#define h22(p) fract(29. * sin(p) * sin(2. * (p).yx))
#define h32(p) vec3(h22(p), dot(h22(p + 1.), h22(p + 2.)))
#define sgn(a) (step(0., a) * 2. - 1.)

vec3 face(vec3 p) {
     vec3 a = abs(p);
     return step(a.yzx, a) * step(a.zxy, a) * sign(p);
}

vec3 edge(vec3 p) {
    vec3 b = 1. - abs(face(p));
    vec3 a = sgn(p) * b.zxy; 
         b = sgn(p) * b.yzx;
    
    return length(p - a) < length(p - b) ? a : b;
}
void drawRings(vec2 uv, inout vec3 col, float timeOffset) {
    // Original pulsating rings
   
    
    // Additional outer rings for a larger effect
    for (int i = 15; i < 25; i++) {
        float t = (iTime + timeOffset) * (0.5 + 0.2 * sin(iTime)); // Modulate speed in sync with music
        t += float(i) * PI / 6.0;
        float d = sdCircle(uv, 0.3 + 0.05 * sin(t * 2.0)); // Larger rings further out
        vec3 ringColor = neonColor(float(i) / 25.0 + (iTime + timeOffset) * 0.15);
        col += ringColor * smoothstep(0.015, 0.0, abs(d)) * 0.5; // Softer outer rings
    }
}


void mainImage(out vec4 O, vec2 C)

{
    O=vec4(0);
    
      vec3 col = vec3(0.0, 0.0, 0.0); // Black background
        vec2 uv = (C - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
          vec2 leftUV = uv + vec2(0.4, 0.0); // Move further to the left
          float c23=hash21(uv);
float timeOffset =1.;

 for (int i = 0; i < 150; i++) {
        float t = (iTime + timeOffset) * (0.6 + 0.2 * sin(iTime)); // Modulate speed in sync with music
        t += float(i) * PI / 71.5;
        float d = sdCircle(uv*0.1, 0.1 + 0.03 * sin(t * 3.0));
        vec3 ringColor = neonColor(float(i) / 15.0 + (iTime + timeOffset) * 0.2);
        col += ringColor * smoothstep(0.01, 0.0, abs(d)) * 0.7; // Sharper, more intense rings
    }


    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(0.,1.2,2.),H(g*.1),.8)*3./e/8e3
    )
    {
        p=g*d;
         vec2 r2 = iResolution.xy;
         vec2  u=C;
         vec4 o=O;
    u = (u - r2 / 2.) / r2.y;
    
    u = vec2(
            log(length(u)),
            atan(u.x, u.y)
        ) * 7.;
    
    u = fract(u / 6.28) - .5;
    u *= 7.;
    u += iTime;
    
    float z = dot(
          cos(u * 5.) * 2.5, 
          sin(u * 2.)
      ) * .1;
    
    vec3 p2 = vec3(u, z),
         id = floor(p) + .5;
    
    float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 5.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    p2.xy*=ma;
    o = vec4(1);
    vec3 m = sign(mod(id, 2.) - 1.);
    
    if(m.x * m.y * m.z < 0.) 
        id += face(p2 - id);
    
    p2 *= id;
    p.z-=iTime*10.;
    p.xy*=ma;
    o = vec4(h32(id.xy) * (.5 - 1. * (length(p2) - .6)), 0);
  vec3 pr2 = edge(p);
        a=30.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
            p.x<p.z?p=p.zyx:p;
            p.x<p.y?p=p.xzy:p;
          
            s*=e=1.8+sin(iTime*0.51)*.1;
            p=abs(p)*e-
                vec3(
                    5.+sin(iTime*.3)*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 )+col*c23*pr2;
         }
         g+=e=length(p.xxyz )/s;
    }
     
    
}