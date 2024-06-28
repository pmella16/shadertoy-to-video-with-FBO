/*orifinals https://glslsandbox.com/e#102180.0 https://www.shadertoy.com/view/lslyRn*/
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

#define pi 3.14159

#define thc(a,b) mytanh(a*cos(b))/mytanh(a)
#define ths(a,b) mytanh(a*sin(b))/mytanh(a)
#define sabs(x) sqrt(x*x+1e-2)


float mytanh(float x) {
    return (exp(2.0 * x) - 1.0) / (exp(2.0 * x) + 1.0);
}

vec2 mytanh(vec2 v) {
    return vec2(mytanh(v.x), mytanh(v.y));
}

vec3 mytanh(vec3 v) {
    return vec3(mytanh(v.x), mytanh(v.y), mytanh(v.z));
}


vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

float h21 (vec2 a) {
    return fract(sin(dot(a.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float mlength(vec2 uv) {
    return max(abs(uv.x), abs(uv.y));
}

float mlength(vec3 uv) {
    return max(max(abs(uv.x), abs(uv.y)), abs(uv.z));
}

// (SdSmoothMin) stolen from here: https://www.shadertoy.com/view/MsfBzB
float smin(float a, float b)
{
    float k = 0.12;
    float h = clamp(0.5 + 0.5 * (b-a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
vec3 dir=rd;
	vec3 from=ro;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
        float a2= iTime*0.015;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam;
           p.xy*=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));// the magic formula
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
	fragColor = vec4(v*.01,1.);	
}

#define MAX_STEPS 400
#define MAX_DIST 20.
#define SURF_DIST .001

//nabbed from blacklemori
vec3 erot(vec3 p, vec3 ax, float rot) {
  return mix(dot(ax, p)*ax, p, cos(rot)) + cross(ax,p)*sin(rot);
}

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

vec3 distort(vec3 p) {
    float time = 3. * length(p) + 1.*iTime;//0. * length(p);
    
    float spd = 0.01;
    float c = cos(time);
    float c2 = cos(time + 2. * pi /3.);
    float c3 = cos(time - 2. * pi / 3.);
    //float s = thc(spd, pi/2. + time);
    vec3 q = erot(vec3(c2,c,c3), normalize(vec3(c,c3,c2)), 0.5 * iTime + 3. * length(p));
    return cross(p, q);
}

float GetDist(vec3 p) {
   
    
    float sd = length(p - vec3(0, 3., -3.5)) - 1.2;
    
    //p = mix(sabs(p) - 0., sabs(p) - 1., 0.5 + 0.5 * thc(4., iTime));
    
    p = distort(p);
    
    p = sabs(p) - 0.25;
    float d = length(p) - 0.3;
    d *= 0.05; //smaller than I'd ike it to be
    d = -smin(-d, sd); 
    
    return d;
}

float RayMarch(vec3 ro, vec3 rd, float z) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = z * GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    
    return dO;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.001, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}

vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 f = normalize(l-p),
        r = normalize(cross(vec3(1,1,0), f)),
        u = cross(f,r),
        c = f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i);
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,1.);
	float time=iTime*speed+.25;
vec2 uv2 = (fragCoord-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;

    vec3 ro = vec3(0, 5, -5.5);
   // ro.yz *= Rot(-m.y*3.14+1.);
    //ro.xz *= Rot(-m.x*6.2831);
    
    vec3 rd = GetRayDir(uv2, ro, vec3(0,0.,0), 1.);
    vec3 col = vec3(0);
   
    float d = RayMarch(ro, rd, 1.);

    float IOR = 1.5;
    if(d<MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        //vec3 r = reflect(rd, n);

        vec3 rdIn = refract(rd, n, 1./IOR);
        vec3 pIn = p - 3. * SURF_DIST * n;
        float dIn = RayMarch(pIn, rdIn, -1.);

        vec3 pExit = pIn + dIn * rdIn;
        vec3 nExit = GetNormal(pExit);

        float dif = dot(n, normalize(vec3(1,2,3)))*.5+.5;
        col = vec3(dif);
        
        float fresnel = pow(1.+dot(rd, n), 1.);
        col = 1. * vec3(fresnel);
        
       // vec3 q = distort(p);
        col *= 2. + 1.8 * thc(10., 60. * length(p) - 1. * iTime);
        col = clamp(col, 0., 1.);
       // col *= 1.-exp(-0.5 - 0.5 * p.y);
       // col *= 0.5 + 0.5 * n;
        vec3 e = vec3(1.);
        col *= pal(length(p) * 3. - 0.05 * iTime, e, e, e, 0.5 * vec3(0,1,2)/3.);
        col = clamp(col, 0., 1.);
        col *= exp(-0.2 * length(p));
        col *= 1.;
    }
	
	vec3 from=vec3(1.,.5,0.5)+col;
	
	
	mainVR(fragColor, fragCoord, from, dir);
    fragColor+=vec4(col,1.);
}
