
/*waving from star*/

/*originals https://glslsandbox.com/e#43775.0 https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/ldBXDD*/



#define resolution iResolution.xy
#define time iTime
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
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
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
    	vec3 dir=vec3(uv*zoom,1.);
    
	
		
        
        vec2 position = ( gl_FragCoord.xy * 2.0 -  resolution.xy) / resolution.x;
	vec2 cPos = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    
    // distance of current pixel from center
	float cLength = length(cPos);

vec3 light_color = vec3(2,2,2);
	
	float t = time * 1.0;
	
	 position =(cPos/cLength)*cos(cLength*1.0-iTime*0.5) * 0.03;
	// 256 angle steps
	float angle = atan(position.y, position.x) / (3.14159265359);
	angle -= floor(angle);
	float rad = length(position);

	float color = 0.0;

	
	float angleFract = fract(angle*205.);
	float angleRnd = floor(angle*200.)+1.;
	float angleRnd1 = fract(angleRnd*fract(angleRnd*.07235)*10.1);
	float angleRnd2 = fract(angleRnd*fract(angleRnd*.0082657)*13.724);
	float t2 = t + angleRnd1*10.0;
	float radDist = sqrt(angleRnd2);
	
	float adist = radDist / rad * 0.1;
	float dist = (t2*.1+adist);
	dist = abs(fract(dist) - 1.0);
	color +=  (1.5 / dist) * cos(sin(t)) * adist / radDist / 30.0;  // cos(sin(t)) make endless.
	//volumetric rendering
	float s=0.1,fade=1.;
    vec3 from=vec3(5.,.5,0.5)*color;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.15;
        
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam;
            p.xy*=mat2(cos(iTime*0.015),sin(iTime*0.015),-sin(iTime*0.015),cos(iTime*0.015) );// the magic formula
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
		

	



	
	  vec2 uv2 = ( fragCoord - .5*iResolution.xy ) / iResolution.y;

     fragColor = vec4(v*.03,1.);
    float anim = sin(iTime * 1.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    fragColor*= vec4(happy_star(uv2, anim) * vec3(0.15,0.2,0.75)*0.18, 1.0);

}
