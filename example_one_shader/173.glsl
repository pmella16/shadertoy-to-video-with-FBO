#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

vec2 mycosh(float x) {
    return vec2((exp(x) + exp(-x)) * 0.5, 0.0);
}

vec2 mysinh(float x) {
    return vec2((exp(x) - exp(-x)) * 0.5, 0.0);
}

vec2 cmul(vec2 z1, vec2 z2) { return vec2(z1.x * z2.x - z1.y * z2.y, z1.x * z2.y + z1.y * z2.x ); }
vec2 cdiv(vec2 z1, vec2 z2) { vec2 conj = vec2(z2.x, -z2.y); return cmul(z1, conj) / (length(z2) * length(z2)); }

vec2 ccos(vec2 z) {
    return vec2(cos(z.x) * mycosh(z.y).x, -sin(z.x) * mysinh(z.y).x);
}

vec2 csin(vec2 z) {
    return vec2(sin(z.x) * mycosh(z.y).x, cos(z.x) * mysinh(z.y).x);
}
vec2 newton(vec2 z)			{ return z - (1.35 - 0.35 * sin(0.3*iTime))*cdiv(csin(z), ccos(z)); }
vec2 rot(vec2 z, float a)	{ return vec2(z.x*cos(a) - z.y*sin(a), z.y*cos(a) + z.x*sin(a)); }


vec3 calculateColor(vec2 z)
{
    
    //--- invert complex plane ---//
    
    z = vec2(z.x, z.y) / dot(z, z);

    
    //--- iterate newton formula until small const (0.14) ---//
    
    int i = 0;
    for (i = 0; i < 80; i++)
    {
        vec2 n = newton(z);
        if (length(z - n) < 0.14) break;
        
        z = rot(n, 0.401*sin(0.512*iTime));
    }
    
    
    //--- return color by binary decomposition ---//
    
    return	z.x < 0.0? vec3(0.0) :
	    	z.y < 0.0? vec3(1.0 - 0.5*log(float(i)/80.0), 0.95, 0.9 - 0.39*float(i)/80.0) : vec3(1.0);
}

vec4 colours[8];

float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
vec3 interpColours (in vec3 orig, in vec3 target, in float t)
{

	return vec3(orig.x + (target.x - orig.x)*t, 
	    	orig.y + (target.y - orig.y)*t,
	    	orig.z + (target.z - orig.z)*t);
}
const float pi = 3.14159265359;
float cosEase (in float angle, in float resolution, in float offset)
{
	return (1.-(0.5-((1.+cos(angle*resolution+offset*pi))/2.)));
}

float deformCircle (in float angle, in float deformationAmount, in float phase)
{
	return cosEase(angle,4.,phase)*deformationAmount + 1.-deformationAmount;
}
#define resolution iResolution.xy
#define time iTime
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
     vec2 uv = ( C - .5*iResolution.xy ) / iResolution.y;
    vec2 p =  uv*2.;
	
	float time = time + length(p)*cos(time/4. - 0.04*length(p)*cos(time*time/8. + 0.0002*length(p)*cos(time*time*time/16.)));
	vec3 color = vec3(0.0, 0.3, 0.5);
	
	float f = 0.0;
	float PI = 3.141592;
	for(float i = 0.0; i < 20.0; i++){
		
		float s = sin(time + i * PI / 10.0) * 0.8;
		float c = cos(time + i * PI / 10.0) * 0.8;
 
		f += 0.001 / (abs(p.x + c / (1.+length(p))) * abs(p.y + s / (1.+length(p)))) / (1.+length(p));
	}
	

    float ZOOM = 1.8;
    vec2 z = ZOOM * (C - 0.5*iResolution.xy) / iResolution.y;
    	float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(z.xy) + .07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);

    
    
    
    float a = 2.0;
    float e2 = 0.5/min(iResolution.x, iResolution.y);    
    vec3 col = vec3(0.0);

       colours[0] = vec4 (vec3(255.,155.,69.) / 255.0, 0.5);
	colours[1] = vec4 (vec3(225.,214.,66.) / 255.0, 1.0);
	colours[2] = vec4 (vec3(63.,179.,163.) / 255.0, 1.0);
	colours[3] = vec4 (vec3(56.,127.,184.) / 255.0, 1.0);
	colours[4] = vec4 (vec3(37.,84.,163.) / 255.0, 1.0);
	colours[5] = vec4 (vec3(101.,86.,163.) / 255.0, 1.0);
	colours[6] = vec4 (vec3(178.,87.,159.) / 255.0, 1.0);
	colours[7] = vec4 (vec3(238.,75.,93.) / 255.0, 1.0);
	vec2 position = ( gl_FragCoord.xy / min (resolution.x, resolution.y) ) * 2.0 - 1.0;
	
	position.x -=  (resolution.x / resolution.y)*0.5;
		position.x+=0.1;
	float a3 = atan (position.x, position.y);
	float r = length (position);
        vec3 col3 = vec3(0.);
	float grad = abs(a3) / pi;
	float edgeLim = 0.8+abs(sin(time*0.3))*0.05;
	float innerEdge = edgeLim - 0.1;
	for (int i=0; i<8; i++)
	{
		//edgeLim += sin(time*float(i)/4.);
		float phase = time*float(i)*0.3;
		vec3 rc;
		if(float(i)==7.)
		{
			rc = interpColours(colours[i].xyz,colours[0].xyz,grad);

		}
		else
		{
			rc = interpColours(colours[i].xyz,colours[i+1].xyz,grad);
		}
		
		float edge = deformCircle (a3, 0.2, phase) * edgeLim;
		float inEdge = deformCircle (a3, 0.1, phase) * innerEdge;
		col3 += clamp(float(r < edge) * (smoothstep (r, edge, edge-0.01)),0.,1.) * rc;
		col3 -= clamp(float(r < inEdge && r < edge) * (smoothstep (r, inEdge, inEdge-0.01)),0.,1.) * rc;
		edgeLim = innerEdge;
		innerEdge = edgeLim - 0.1;
	}
	     
    vec3 n1,q,r3=iResolution,
    d=normalize(vec3((C*2.-r3.xy)/r3.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(1),H(g*.1),.8)*1./e/8e3
    )
    
    
    {
        n1=g*d+col3;
         
	 n1.z*=ceil(col.y);
        a=20.;
        n1=mod(n1-a,a*2.)-a;
        s=3.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
           
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            s*=e=1.4+sin(iTime*.1)*.1;
            n1=abs(n1)*e-
                vec3(
                    5.+sin(iTime*.3+.5*sin(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 );
         }
         g+=e=length(n1.yz)/s;
    }
      uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    O*= vec4(happy_star(uv, anim) * vec3(0.35,0.2,1.15)*12., 1.0);
       O+= vec4(vec3(f * color), 1.0);
}