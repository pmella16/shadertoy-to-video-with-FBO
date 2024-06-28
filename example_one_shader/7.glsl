/* originals https://www.shadertoy.com/view/DtGyWh/ https://www.shadertoy.com/view/MsV3RK https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/4tyfWy*/


#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(10,53,21))*.5+.5)
vec3 hash(float x) { return fract(sin((vec3(x)+vec3(23.32445,132.45454,65.78943))*vec3(23.32445,32.45454,65.78943))*4352.34345); }
float cheap_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}

vec3 noise(float x)
{
    float p = fract(x); x-=p;
    return mix(hash(x),hash(x+1.0),p);
}

vec3 noiseq(float x)
{
    return (noise(x)+noise(x+10.25)+noise(x+20.5)+noise(x+30.75))*0.25;
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
	//get coords and direction
	vec3 dir=rd;
	vec3 from=ro;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.2-dm; // dark matter, don't render near
	
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.01,1.);	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,iTime*0.01);
	float time=iTime*speed+.25;
vec4 O =fragColor;
vec2 C =fragCoord;
	 O=vec4(0);
    
   vec4 O2=O;
    
    float time2=iTime*0.15;
    vec3 k1=noiseq(time2)*vec3(0.1,0.19,0.3)+vec3(1.3,0.8,.63);
    vec3 k2=noiseq(time2+1000.0)*vec3(0.2,0.2,0.05)+vec3(0.9,0.9,.05);
    //float k3=clamp(texture(iChannel0,vec2(0.01,0.)).x,0.8,1.0); float k4=clamp(texture(iChannel0,vec2(0.2,0.)).x,0.5,1.0); k2+=vec3((k3-0.8)*0.05); k1+=vec3((k4-0.5)*0.01);
    float g=pow(abs(sin(time2*0.8+9000.0)),4.0);
    
	vec2 R = iResolution.xy;
    
    vec2 r1=(C / R.y-vec2(0.5*R.x/R.y,0.5));
    float l = length(r1);
    vec2 rotate=vec2(cos(time2),sin(time2));
    r1=vec2(r1.x*rotate.x+r1.y*rotate.y,r1.y*rotate.x-r1.x*rotate.y);
    vec2 c3 = abs(r1.xy/l);
	if (c3.x>0.5) c3=abs(c3*0.5+vec2(-c3.y,c3.x)*0.86602540);
    c3=normalize(vec2(c3.x*2.0,(c3.y-0.8660254037)*7.4641016151377545870));
    
    O2 = vec4(c3*l*70.0*(g+0.12), .5,0);
    for (int i = 0; i < 128; i++) {
    	O2.xzy = (k1 * abs(O2.xyz/dot(O2,O2)-k2));
    }
    
    uv *= 2.0 * ( cos(iTime * 2.0) -2.5);
    
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    

    
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    
    
    
    {
        p=g*d;
        p.z-=iTime*3.0;
        a=30.;
        p=mod(p-a,a*2.)-a;
        s=5.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
            
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            p.y<p.x?p=p.zyx:p;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    120,
                    5.+cos(iTime*.5)*5.
                 )*O2.xzy;
         }
      
         g+=e=length(p.yx)/s;
    }
	vec3 from=vec3(1.,.5,0.5)*O.xyz;
	from+=vec3(time*2.,time,-2.);

	
	mainVR(fragColor, fragCoord, from, dir);
    fragColor+=O;
    fragColor*= vec4(cheap_star(uv,anim) * vec3(0.55,0.5,0.55)*0.5, 1.0); 
}
