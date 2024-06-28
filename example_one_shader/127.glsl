/*originals https://www.shadertoy.com/view/DlycWR*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(13,43,41))*.5+.5)

float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}
vec2 polarToCartesian(float radius, float angle)
{
    return vec2(radius*cos(angle), radius*sin(angle));
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(1.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
      vec2 uv = C/iResolution.xy;
      ;
    vec4 color = vec4(0.0);
	float seg = 5.;
	float i = -seg;
	float j = 0.;
	float f = 0.0f;
vec2 p = (2.0*C-iResolution.xy)/iResolution.y;
    vec2 m = (20.0*cos(iTime)-iResolution.xy)/iResolution.y;
      vec2 pSwirled2 = polarToCartesian(0.1*1., 10. + pow(5. , 0.2)) + vec2(-0.01*iTime);

    // Polar coordinates
    float radius = length(p*m.x);
    float angle = atan(p.y*p.x*m.x*pSwirled2.y,p.x*p.y*m.y+pSwirled2.x)-iTime;

    float swirl = 1. + 5.*(1.-m.x);
    vec2 pSwirled = polarToCartesian(0.1*radius, angle + pow(radius, 0.2)*swirl) + vec2(-0.01*iTime);
    
    float vluae = 1.5+cos(iTime);

    float dvx = vluae/iResolution.x;
    float dvy = vluae/iResolution.y;
    
	float tot = 0.0f;
	for(; i <= seg; ++i)
	{
		for(j = -seg; j <= seg; ++j)
		{
			f = (1.2 - sqrt(i*i + j*j)/8.0);
			f += f;
			tot += f;
			color += 0.0;
		}
	}
	color /= tot;
    vec3 natur_norm,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.21+cos(iTime)),sin(.8))*1./e/8e3
    )
    {
        natur_norm=g*d;
        float c23 = noise(natur_norm.xy*pSwirled);
        ;
        natur_norm.z+=iTime*1.0;
        a=21.;
        natur_norm=mod(natur_norm-a,a*2.)-a;
        s=5.+cos(abs(iTime));
        for(int i=0;i++<8;){
            natur_norm=2.23-abs(natur_norm);
            
            natur_norm.x<natur_norm.z?natur_norm=natur_norm.zyx:natur_norm;
            natur_norm.z<natur_norm.y?natur_norm=natur_norm.xzy:natur_norm;
               natur_norm.y==natur_norm.z?natur_norm=natur_norm.xzy:natur_norm;
            s*=e=5.5+sin(iTime*.234)*.1;
            natur_norm=abs(natur_norm)*e-
                vec3(
                    5.+sin(iTime*.3+.5*sin(iTime*.3))*3.,
                    120.,
                    8.+sin(iTime*.2)*5.
                 )+color.xyz+color.xzy*c23;
         }
         g+=e=length(natur_norm.yz+pSwirled)/s;
          g+=e=length(natur_norm.yx/pSwirled)/s;
    }
}