/*https://www.shadertoy.com/view/4tyfWy  https://www.shadertoy.com/view/MfsSD2  https://www.shadertoy.com/view/lslyRn*/
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
			p=abs(p)/dot(p,p)-formuparam;
      p.xy*=mat2(cos(iTime*0.005),sin(iTime*0.005),-sin(iTime*0.005),cos(iTime*0.005));// the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		
		a*=a*a; // add contrast
		if (r>6) fade*=1.1; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*vec3(0.015,0.015,0.015); // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.03,1.);	
}
#define TAU 6.283184

const vec4 lineColor = vec4(0.25, 0.5, 1.0, 1.0);
const vec4[] bgColors = vec4[]
(
    lineColor * 0.5,
    lineColor - vec4(0.2, 0.2, 0.7, 1)
);


// probably can optimize w/ noise, but currently using fourier transform
float random(float t)
{
    return (cos(t) + cos(t * 1.3 + 1.3) + cos(t * 1.4 + 1.4)) / 3.0;   
}

vec2 rotateUV(vec2 uv, float angle) 
{
    angle = angle*TAU;
    mat2 matrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    
    return matrix * uv;
}


float arc(float r, vec2 uv, float orientation, float radius, float section)
{
    uv = rotateUV(uv, orientation);
    float theta = atan(uv.x, uv.y)/TAU;

    float t = 100. * section;
    float value = 
        min(2.0, pow(0.001 / abs(r - radius),2.)) *
        min(2.0, pow(0.005 / abs(theta / t),t / 1.));
    
    return value;
}
float radial(float r, vec2 uv, float orientation, float radius, float section)
{
    uv = rotateUV(uv, orientation);
    float theta = atan(uv.x, uv.y)/TAU;

    //float value = min(2.0, 0.002 / abs(theta)) *;

    float t = 100. * section;
    float value = 
        min(2.0, 0.00025 / abs(theta)) *
        min(2.0, pow(0.005 / abs((r - radius) / t),t / 2.));

    return value;
}

float rich_beautiful_healthy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
    vec2 uv2=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,iTime*0.002);
	float time=iTime*speed+.25;

 float aspect = iResolution.x / iResolution.y;
    

    
    float r = length(uv);
    
    float value = 0.;
    for(float i=0.;i<64.;i+=1.)
    {
        float radius = 0.1125 + random((i * 1000.5 + iTime) * 10.)*0.15;
        float orientation = .5 + .5 * random((i * 453.6 + iTime) * 0.027);
        float section = 0.113 + random((i * 346.3 + iTime) * 2.1)/10.;
 
        value += arc(r, uv2, orientation, radius, section);

        orientation = 1.225 + .55 * random((i * 1823.3 + iTime) * 0.001);
        value += radial(r, uv2, orientation, radius, section);    
    }
    
 
    // Some blueish tone
    vec3 color = vec3(.3,0.3,1.1);

    float verticalFade = cos(uv2.y * 123.28) * 0.05 + 0.5;
    fragColor = mix(bgColors[1], bgColors[1], uv2.x/1.);
    fragColor *= verticalFade/2.;

	
	vec3 from=vec3(1.,.5,0.5)*color * value;
	from+=vec3(time*2.,time,-2.);
	

	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor += vec4(color * value,1.0);
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5);
    
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    

    fragColor*= vec4(rich_beautiful_healthy_star(uv,anim) * vec3(0.45,0.5,0.55)*0.5, 1.0);

}
