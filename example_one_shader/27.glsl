 /*originals https://www.shadertoy.com/view/McsXz8 https://www.shadertoy.com/view/4tyfWy https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/DtGyWhhttps://www.shadertoy.com/view/lfsSD8 https://www.shadertoy.com/view/DlycWR https://www.shadertoy.com/view/XcsSDn  */

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
#define H(h)(cos((h)*6.3+vec3(32,43,41))*.5+.5)

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
uniform sampler2D backbuffer;

float PI = acos(-1.);

vec3 foldX(vec3 p) {
    p.x = abs(p.x);
    return p;
}

mat2 rotate(float a) {
    float s = sin(a),c = cos(a);
    return mat2(c, s, -s, c);
}

float ball(vec3 p, float r){
  return length(p) - r;
}

float cylinder(vec3 p, float r, float h){
  float d1 = length(p.xy) - r;
  float d2 = abs(p.z) - h;
  
  float d = max(d1, d2);
  
  return d;
}

float cube(vec3 p, vec3 s){
  vec3 q = abs(p);
  vec3 m = max(s-q, 0.0);
  return length(max(q-s, 0.0))-min(min(m.x, m.y), m.z);
}

float dist(vec3 p){
  float scale = 1.6;
  float s = 1.0;
  float d = 777.0;
  
  for(int i=0;i<10;i++){
    float tscale = 0.4;
vec2 R = iResolution.xy;
  vec2  m = (iMouse.xy*2.-R)/R.y;
  p.xz*=rotate(m.x);
      p.xy*=rotate(m.y);
       p.zy*=rotate(m.y);
    p = abs(p);
    p -= 0.5/s;
    
    p *= scale;
    s *= scale;
    
    float d1 = cylinder(p, 0.03, 1.0);
    float d2 = cube(p, vec3(0.2));
    float d3 = ball(vec3(p.x, p.y, p.z - 1.), 0.15);
    float d5 = min(min(d1, d2), d3)/s;
  
    d = min(d, d5);
 
  }
  
  return d;
}

vec3 calcNormal(vec3 p) // for function f(p)
{
    float eps = 0.001;
    vec2 h = vec2(eps,0);
    return normalize( vec3(dist(p+h.xyy) - dist(p-h.xyy),
                           dist(p+h.yxy) - dist(p-h.yxy),
                           dist(p+h.yyx) - dist(p-h.yyx) ) );
}

vec3 lighting(vec3 light_color, vec3 lightpos, vec3 pos, vec3 normal, vec3 rd){
  vec3 lightdir = normalize(lightpos - pos);
  float lambrt = max(dot(normal, lightdir), 0.0);
  vec3 half_vector = normalize(lightdir - rd);
  float m = 200.;
  float norm_factor   = ( m + 2. ) / ( 2.* PI );
  vec3 light_specular = light_color * norm_factor * pow( max( 0., dot( normal, half_vector ) ), m );

  return vec3(0.4,0.8,0.9)*lambrt*light_color + light_specular;
}


float rich_beautiful_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
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
		//v+=vec3(dm,dm*.5,0.);
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
	vec3 dir=vec3(uv*zoom,1.);
	float time=iTime*speed+.25;
vec4 O=fragColor;
vec2 C = fragCoord ;
	 O=vec4(0);
    
    vec2 r=iResolution.xy, p2=(C.xy*2.-r)/min(r.x,r.y);
  
  vec3 tar = vec3(0.0, 0.0, 0.0);
  float radius = 2.0;
  float theta = iTime * 0.5;
  
  vec3 cpos = vec3(radius*cos(theta), 0.5, radius*sin(theta)); //camera pos
  
  vec3 cdir = normalize(tar - cpos); //camera dir
  vec3 side = cross(cdir, vec3(0, 1, 0));
  vec3 up = cross(side, cdir);
  float fov = 0.5; // field of view
  
  vec3 screenpos = vec3(p2, 4.0);
  
  vec3 rd = normalize(p2.x*side + p2.y*up + fov*cdir);
  
  float d = 0.0; //distance
  float t = 0.0; //total distance
  vec3 pos = cpos;
  
  for(int i=0;i<30;i++){
    d = dist(pos);
    t += d;
    pos = cpos + rd*t;
    if(d<0.0001 || t>10.0) break;
  }
  
  vec3 col = vec3(0.0);
  
  vec3 normal = calcNormal(pos);
  
  vec3 light_color = vec3(0.5, 1.0, 0.6);
  vec3 lightpos = vec3(1.0, 2.0, 0.0);
  col = lighting(light_color, lightpos, pos, normal, rd);
  
  light_color = vec3(0.5, 0.5, 1.0);
  lightpos = vec3(2.0, 1.0, 0.0);
  col += lighting(light_color, lightpos, pos, normal, rd);
  col = clamp(col, 0.0, 1.0);
  col = pow(col, vec3(1.4));
  
  if(t>10.0) col = vec3(0.0);
vec2 R = iResolution.xy;
  vec2  m = (iMouse.xy*2.-R)/R.y;
    vec3 naturals,q,r2=iResolution,
    d2=normalize(vec3((C*2.-r2.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        naturals=g*d2;
        naturals.z+=iTime*0.05*m.y;
        a=20.;
        naturals=mod(naturals-a,a*2.)-a;
        s=6.;
    
        for(int i=0;i++<8;){
            naturals=2.3-abs(naturals);
            
            naturals.x<naturals.z?naturals=naturals.zyx:naturals;
         naturals.y>naturals.x?naturals=naturals.zxy:naturals;
            naturals.y<naturals.x?naturals=naturals.zyx:naturals;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            naturals=abs(naturals)*e-
                vec3(
                    5.+cos(iTime*m.y+.5*cos(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*m.x)*5.
                 )*col;
         }
       
         g+=e=length(naturals.yx)/s;
    }
     vec2 uv2 = ( C - .5*iResolution.xy ) / iResolution.y;
    uv2 *= 2.0 * ( cos(iTime * 2.0) -2.5);
    
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    

    
	float a1=.5+iMouse.x/iResolution.x*2.;
	float a2=.8+iMouse.y/iResolution.y*2.;
	mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
	mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
	dir.xz*=rot1;
	dir.xy*=rot2;
	vec3 from=vec3(1.,.5,0.5)*O.xyz+col;
	from+=vec3(time*2.,time,-2.);
	from.xz*=rot1;
	from.xy*=rot2;
	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor*= vec4(rich_beautiful_star(uv2,anim) * vec3(0.55,0.5,0.55)*3.2, 1.0);
    fragColor+=vec4 (col,1.);
}
