/*originals sameware on https://glslsandbox.com/*/
#define R(p,a,t) mix(a*dot(p,a),p,cos(t))+sin(t)*dot(p,a)
#define H(h) (cos((h)*6.3+vec3(0,23,21))*.5+.5)
float happy_beautiful_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
void mainImage(out vec4 O, vec2 C)
{
    vec3 p=iResolution;
	    vec3 r=iResolution;
         // pixel position normalised to [-1, 1]
	vec2 cPos = -1.0 + 2.0 * C.xy / iResolution.xy;
      vec2 uv2 = ( C - .5*iResolution.xy ) / iResolution.y;
    // distance of current pixel from center
	float cLength = length(cPos);

	float t2 = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv2.xy) + 0.507)) * 0.5;
	float si = sin(t2);
	float co = cos(t2);
	mat2 ma = mat2(co, si, -si, co);

	
    
		    vec3 c=vec3(0);
			    vec3 uv=(vec3((gl_FragCoord.xy-.5*r.xy)/r.y,.27));
	
	uv=uv/uv.z;
    float s,e,g=0.,t=-iTime*2.0;
	for(float i=0.;i<90.;i++){
        p=R(g*uv,vec3(0.),0.);
        p.z+=t*.5;
        p=asin(.7*sin(p));
        p.xy*=ma;
        s=2.5+sin(.5*t+3.*sin(t*2.))*.5;
        for(int i=0;i<6;i++) {
            p=abs(p),
            p=p.x<p.y?p.zxy:p.zyx,
            p=p.y>p.z?p.yxz:p.xyz,
            s*=e=2.;
            p=p*e-vec3(5,1.5,3.5);
            p.xy+= (cPos/cLength)*cos(cLength*1.0-iTime*2.0) * 0.03;
        }
        g+=e=abs(length(p.xz)-.3)/s+2e-5;
	    c+=mix(vec3(1),H(p.z*.5+t*.1),.4)*.02/exp(.5*i*i*e);
	}
	c*=c;
   
    uv2 *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
 
    O=vec4(c,1);
       O+= vec4(happy_beautiful_star(uv2, anim) * vec3(0.55,0.5,0.55)*0.3, 1.0);
}