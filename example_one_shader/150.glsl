/*originals https://www.shadertoy.com/view/stsXDl https://www.shadertoy.com/view/lXcGDs https://www.shadertoy.com/view/MdXSzS*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(23,43,21))*2.5+.5)
#define PI 3.1415926
float sdGrid(in vec2 position, in float margin) {

	// Calculate per-axis distance from 0.5 to position mod 1
	vec2 gridDist = abs(fract(position) - 0.5) - margin;
    //gridDist.x = 0.0; //makes it look like a magnetic field
    // nb somehow related to mobius transformations which is related to smith chart
    // smith chart is z-1/z+1
	
	// Calculate length for round outer corners, ripped from Inigo Quilez
	float outsideDist = length(max(gridDist, 0.0));
	// Calculate inside separately, ripped from Inigo Quilez
	float insideDist = min(max(gridDist.x, gridDist.y), 0.0);
	
	return outsideDist + insideDist;
}

const vec2 c1 = vec2(1.0, 0.0); //1
const vec2 c0 = vec2(0.0); //0
const vec2 ci = vec2(0.0, 1.0);

// operations of complex numbers
vec2 cMult(vec2 z, vec2 w) {    //z*w
    return vec2(z.x * w.x - z.y * w.y, z.y * w.x + z.x * w.y);
}
vec2 cConj(vec2 z) {    //bar{z}
    return vec2(z.x, - z.y);
}
vec2 cInv(vec2 z) { //z^{-1}
    return (1.0 / pow(length(z), 2.0)) * cConj(z);
}
vec2 cDiv(vec2 z, vec2 w) {
    return cMult(z, cInv(w));
}

vec2 moebius(vec2 a, vec2 b, vec2 c, vec2 d, vec2 z) {
    return cMult((cMult(a, z) + b), (cMult(c, z) + d));
}
vec2 mymoebius(vec2 a, vec2 b, vec2 c, vec2 d, vec2 z) {
    return cDiv((cMult(a, z) + b), (cMult(c, z) + d));
}


vec2 smith(vec2 z, float t) {
    vec2 a = c1;
    
    t = 2.0*PI*sin(0.01*t);
    vec2 b = vec2(cos(t), sin(t));
  
    return mymoebius(c0, c1, b, c0, z);

}

float channel(vec2 uv, float t) {
    
    uv = fract(log(1.0 + abs(0.5*smith(uv, t))));
    return sdGrid(uv + t*0.49, 0.2);
}

vec3 image(vec2 uv) {
    float x = channel(uv, iTime);
    float y = channel(uv, -iTime);
    //float z = x+y / x-y;
    float z1 = abs(-y / (x+y));
    float z2 = abs(x*y/(x+y));
    float z3 = abs(x*y/(x-y));
    // reverse time symmetry
    return vec3(z1,z2,z3);
}

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
     // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = C/iResolution.xy;
    uv *= 2.0;
    uv -= 1.0;
    // Output to screen
 float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .57)) * 2.2;
	float si = sin(t);
	float co = cos(t);
	mat2 ma = mat2(co, si, -si, co);
    uv*=ma;
    vec3 n1,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<70.;
        O.xyz+=mix(vec3(1),H(g*.1),.8)*1./e/8e3
    )
    {
        n1=g*d;
 n1.xy*=ma;
 n1.xz*=mat2(cos(iTime),sin(iTime),-sin(iTime), cos(iTime) );
  n1.xy*=mat2(cos(iTime),sin(iTime),-sin(iTime), cos(iTime) );
  n1.z+=iTime;
        a=30.;
        n1=mod(n1-a,a*2.)-a;
        s=3.;
        for(int i=0;i++<8;){
            n1=.3-abs(n1);
            n1.x<n1.z?n1=n1.zyx:n1;
            n1.z<n1.y?n1=n1.xzy:n1;
            n1.y<n1.x?n1=n1.zyx:n1;
             n1.yx+=(log(13.0 * (abs(1.5*(uv, n1.z)))));
           n1.xy+=floor(log(13.0 * (abs(1.5*(uv, n1.x)))));
            s*=e=1.4+sin(iTime*.1)*.1;
            n1=abs(n1)*e-
                vec3(
                    15.*3.,
                    120,
                    3.*5.
                 );
         }
         g+=e=length(n1.zy)/s;
    }
}