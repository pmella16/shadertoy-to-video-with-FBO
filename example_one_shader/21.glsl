/*originals https://www.shadertoy.com/view/4cfSz4  https://www.shadertoy.com/view/lslyRn*/
#define iterations 12
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
            p.xy*=mat2(cos(iTime*0.10),sin(iTime*0.10),-sin(iTime*0.10),cos(iTime*0.10));// the magic formula
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
	fragColor = vec4(v*.021,1.);	
}
const float PI = 3.14159265359;

mat2 rot( in float a )
{
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// http://iquilezles.org/articles/intersectors/
// sphere of size ra centered at point ce
vec2 sphIntersect( in vec3 ro, in vec3 rd, in vec3 ce, float ra )
{
    vec3 oc = ro - ce;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - ra*ra;
    float h = b*b - c;
    if( h<0.0 ) return vec2(-1.0); // no intersection
    h = sqrt( h );
    return vec2( -b-h, -b+h );
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord*2.0 - iResolution.xy)/iResolution.y;
	vec3 dir=vec3(uv*zoom,1.);
	float time=iTime*speed+.25;
 uv*=.5;
	 vec2 m = (iMouse.xy*2.0 - iResolution.xy)/iResolution.y;
    
    vec3 ro = vec3(0.0, 0.0, -2.0);
    ro.yz *= rot(PI/2.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    rd.yz *= rot(PI/2.0);

    vec3 col = vec3(0.0);
    
    float sphereSize = 0.5;
    vec3 spherePos = vec3(0.0);
    
    vec2 isc = sphIntersect(ro, rd, spherePos, sphereSize);
    vec3 p = ro + rd*isc.x;
    
    if (isc.y < 0.0)
    {
        float table = -0.5;
        float dtable = (table - ro.y) / rd.y;
        p = ro + rd*dtable;
        
        vec3 proj_origin = spherePos + vec3(0.0, sphereSize-0.01, 0.0);
        rd = normalize(proj_origin - p);
        p = p + rd*sphIntersect(p, rd, spherePos, sphereSize).x;
    }
    
    float d = length(ro - p);
    
    p = normalize(p - spherePos);
    if (iMouse.z > 0.0)
    {
        p.xy *= rot(m.x);
        p.yz *= rot(m.y);
    } else {
        p.yz *= rot(iTime);
    }
    

 
	float a1=.5+iMouse.x/iResolution.x*2.;
	float a2=.8+iMouse.y/iResolution.y*2.;
	mat2 rot1=mat2(cos(iTime*0.10),sin(iTime*0.10),-sin(iTime*0.10),cos(iTime*0.10));
	mat2 rot2=mat2(cos(iTime*0.10),sin(iTime*0.10),-sin(iTime*0.10),cos(iTime*0.10));
	dir.xz*=rot1;
	dir.xy*=rot2;
	vec3 from=vec3(1.,.5,0.5)*col;
	from+=vec3(time*2.,time,-2.);
	from.xz*=rot1;
	from.xy*=rot2;
	
	mainVR(fragColor, fragCoord, from, dir);	
}
