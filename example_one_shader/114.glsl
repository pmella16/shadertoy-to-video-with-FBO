/* https://www.shadertoy.com/view/4tyfWy https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/MdXSzS */
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
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.02,1.);	
}
#define particles 500.
vec3 c1 = vec3(0.,0.3,1.);
vec3 c2 = vec3(1.,0.5,.3);

mat2 rot(float a)
{
    float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}


vec3 noise(float n) {
    vec3 t = vec3(0.0); // Asigna el valor 0.0 a t
    vec3 u = vec3(0.0); // Asigna el valor 0.0 a u
    return mix(t, u, fract(n));
}



vec3 render_points(vec2 uv) {
    uv*=1.2;
    vec3 c=vec3(0.);
	for (float i=0.; i<particles; i++) {
		vec3 point=noise(i+floor(iTime/10.)*.1)-.5;
        float a=4.*smoothstep(0.,7.,mod(iTime,10.));
        
 
        point.xz*=rot(a);
        point.yz*=rot(a*.2);
		point=pow(abs(point),vec3(1.3))*sign(point);
        point*=.2+mod(iTime,10.)*.4;
        float e=pow(mod(dot(point,point)*.05-iTime*.002,.1)/.1,1.5);
        point.xy/=max(0.,1.5+point.z);
        point.x*=1.5;
		float l=max(0.,.1-distance(uv,point.xy))/.1;
        vec3 col=mix(c1,c2,e)*e;
        c+=pow(l,20.)*col*2.;
		c+=pow(l,40.)*col*5.;
        c+=pow(max(0.,1.-length(uv)),15.)*.03*c2*pow(iTime*0.001,10.);
	}
	return c;
}
float happy_lucky_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
vec2 uv2=fragCoord/iResolution.xy;
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,iTime*0.001);
	float time=iTime*speed+.25;
vec2 uv3 = (fragCoord.xy / iResolution.xy) - .5;
	float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv3.xy) + .37)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);

	float v1, v2, v3;
	v1 = v2 = v3 = 0.0;
	
	float s = 0.0;
	for (int i = 0; i < 90; i++)
	{
		vec3 p = s * vec3(uv, 0.0);
		p.xy *= ma;
		p += vec3(.22, .3, s - 1.5 - sin(iTime * .13) * .1);
		for (int i = 0; i < 8; i++)	p = abs(p) / dot(p,p) - 0.659;
		v1 += dot(p,p) * .0015 * (1.8 + sin(length(uv3.xy * 13.0) + .5  - iTime * .2));
		v2 += dot(p,p) * .0013 * (1.5 + sin(length(uv3.xy * 14.5) + 1.2 - iTime * .3));
		v3 += length(p.xy*10.) * .0003;
		s  += .035;
	}
	
	float len = length(uv3);
	v1 *= smoothstep(0.43, .20, len);
	v2 *= smoothstep(.7, .0, len);
	v3 *= smoothstep(.8, .0, len);
	
	vec3 col = vec3( v3 * (1.5 + sin(iTime * .2) * .4),
					(v1 + v3) * .3,
					 v2) + smoothstep(0.2, .0, len) * .85 + smoothstep(.0, .6, v3) * .3;
   
    uv2-=.5; 
  
	uv2.x*=iResolution.x/iResolution.y;
    vec3 c=render_points(uv2);
	
	
	vec3 from=vec3(1.,.5,0.5)*col;

	
	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor+=vec4(c,1.);
    fragColor*=vec4(col,1.);
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    fragColor+= vec4(happy_lucky_star(uv, anim) * vec3(0.75,0.7,0.75)*0.1, 1.0);
}
