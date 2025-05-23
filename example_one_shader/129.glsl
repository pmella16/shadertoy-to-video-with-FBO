// Ribbon Wave v4
// Initial Version of V3: May 03, 2022
// Uses a 3D Simplex Noise implementation by nikat:
// https://www.shadertoy.com/view/XsX3zB

float PI = 3.14159256;
float TAU = 2.*3.14159256;

// 3d simplex noise from https://www.shadertoy.com/view/XsX3zB

vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 uv = ( fragCoord - .5* iResolution.xy ) /iResolution.y;
   
   vec3 col = vec3(0.);   
   float offset = 0.0;
   float d = length(uv); 
   vec3 col2;
   float n,curve;
   
   for(float i=-70.; i<70.; i++){
      if(mod(i,2.)==0.){
        col2 = vec3(1.2);
        n = simplex3d(vec3(i*.05,10.0,10.0));
        offset += 2.5*n;
      }
      else
        col2 = vec3(0.);    
       
    //  curve = uv.y - .2*pow((1.-d),4.)*sin(12.*uv.x-iTime + offset) + i/200.
      curve = uv.y - .2*smoothstep(.25,.75,1.-d)*sin(12.*uv.x-iTime + offset) + i/250.;
    
      col = mix(col, col2, smoothstep(curve, curve+.009, 0.0));
    }
    
    fragColor = vec4(col,1.0);
}