#define R(p,a,t) mix(a*dot(p,a),p,cos(t))+sin(t)*cross(p,a)
#define H(h) (cos((h)*6.3+vec3(0,23,21))*.5+.5)

void mainImage(out vec4 O, vec2 C)
{
    vec3 r=iResolution,c=vec3(0);
    
    
     vec2 uv = C / iResolution.xy;
    vec2 centeredUV = uv * 2.0 - 1.0;
    centeredUV.x *= iResolution.x / iResolution.y;

    float t = iTime*0.5;

   
    vec2 center = vec2(0.0);

    // Direction and distance from center
    vec2 dir = centeredUV - center;
    float dist = length(dir*.5);
    float angle = atan(dir.y, dir.x);

    // === Stronger UV Distortion ===
    float burst = sin(angle * 12.0 + t * 6.0) * 0.15;      // was 0.08
    float ripple = sin(dist * 30.0 - t * 12.0) * 0.3;     // was 0.015
    float warp = burst + ripple + 5.;

    vec2 distortedUV = uv + normalize(dir) * warp * smoothstep(1.0, 0.0, dist);
    vec4 p,d=normalize(vec4(C-.5*r.xy,r.y,.5));
 	for(float i=0.,s,e,g=0.,t=iTime;i++<80.;){
        p=g*d;
         p.xy+=distortedUV*0.031*mat2(cos(iTime), sin(iTime), -sin(iTime), cos(iTime));
        p.z-=iTime*1.1;
        p=asin(cos(p))-1.;
      
        s=1.;
        for(int i=0;i++<10;)
            p=p.x<p.y?p.wzxy:p.wzyx,
            s*=e=2.2/min(dot(p,p),1.7),
            p=abs(p)*e-vec4(.45,.25,1.25,1.21);
        e=abs(p.w)/s;
        g+=e+5e-4;
	    c+=mix(vec3(1),H(log(s)*.3+t*.2),.4)*.03/exp(i*i*e);
	}
	c*=c;
    O=vec4(c,1);
}