/*originals https://www.shadertoy.com/view/4tyfWy https://www.shadertoy.com/view/McsXz8 https://glslsandbox.com/e#53634.0*/
#define O(x,a,b) smoothstep(0., 1., cos(x*6.2832)*.5+.5)*(a-b)+b  // oscillate between a & b
#define A(v) mat2(cos((v*3.1416) + vec4(0, -1.5708, 1.5708, 0)))  // rotate
#define s(p1, p2) c += .02/abs(L( u, K(p1, v, h), K(p2, v, h) )+.01)*k;  // segment
#define s2(p1, p2) c += .12/abs(L( u, K(p1, v, h), K(p2, v, h) )+.11)*k;  // segment
// line
float L(vec2 p, vec3 A, vec3 B)
{
    vec2 a = A.xy, 
         b = B.xy - a;
         p -= a;
    float h = clamp(dot(p, b) / dot(b, b), 0., 1.);
    return length(p - b*h) + .01*mix(A.z, B.z, h);
}

// cam
vec3 K(vec3 p, mat2 v, mat2 h)
{
    p.zy *= v; // pitch
    p.zx *= h; // yaw

    return p;
}


uniform float time;
uniform vec2 resolution;
#define resolution iResolution.xy
#define time iTime
vec3 hsv(float h, float s, float v) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 2.0);
	vec3 p = abs(fract(vec3(h) + K.xyz) * 6.0 - K.www);
	return v * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), s);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}




float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
void mainImage( out vec4 C, in vec2 U )
{
    vec2 R = iResolution.xy,
         u = (U+U-R)/R.y*2.,
         m = (iMouse.xy*2.-R)/R.y;
    
    vec2 p2 = (2.0 * gl_FragCoord.xy - resolution.xy) / min(resolution.x, resolution.y);
	vec3 v2 = vec3(p2, 1.0 - length(p2) * 0.2);

	float ta = time * 0.1;
	mat3 m2=mat3(
		0.0,1.0,0.0,
		-sin(ta),0.0,cos(ta),
		cos(ta),0.0,sin(ta));
	m2*=m2*m2;
	m2*=m2;
	v2=m2*v2;

	float a = (atan(v2.y, v2.x) / 3.141592 / 2.0 + 0.5);
	float slice = floor(a * 1000.0);
	float phase = rand(vec2(slice, 0.0));
	float dist = rand(vec2(slice, 1.0)) * 3.0;
	float hue = rand(vec2(slice, 2.0));

	float z = dist / length(v2.xy) * v2.z;
	float Z = mod(z + phase + time * 0.6, 1.0);
	float d2 = sqrt(z * z + dist * dist);

	float c2 = exp(-Z * 8.0 + 0.3) / (d2 * d2 + 1.0);

    float t = iTime/60.,
          o = t*6.,
          j = (u.x > 0.) ? 1.: -1.; // screen side
    
    if (iMouse.z < 1.) // not clicking
        m = vec2(sin(t*6.2832)*2., sin(t*6.2832*2.)); // fig-8 movement
    
    mat2 v = A(m.y), // pitch
         h = A(m.x); // yaw
    
    vec3 c = vec3(0), p, 
         k = vec3(2,1,4)/40. + .05;
    

    
 
     
      
        p = vec3(
            O(1.,   1.,  .1), 
            O(o, 1.1, -1.), 
            O(o, 1.1,    1.));
        s( vec3(-p.z,  p.x,    0), vec3(-p.z, -p.x,    0) )
        s( vec3(-p.z,  p.x,    0), vec3( p.y, -p.y, -p.y) )
        s( vec3(-p.z,  p.x,    0), vec3( p.y, -p.y,  p.y) )
        s( vec3(-p.z, -p.x,    0), vec3( p.y,  p.y, -p.y) )
        s( vec3(-p.z, -p.x,    0), vec3( p.y,  p.y,  p.y) )
        s( vec3( p.z,  p.x,    0), vec3( p.z, -p.x,    0) )
        s( vec3( p.z,  p.x,    0), vec3(-p.y, -p.y,  p.y) )
        s( vec3( p.z,  p.x,    0), vec3(-p.y, -p.y, -p.y) )
        s( vec3( p.z, -p.x,    0), vec3(-p.y,  p.y,  p.y) )
        s( vec3( p.z, -p.x,    0), vec3(-p.y,  p.y, -p.y) )
        s( vec3( p.x,    0, -p.z), vec3(-p.x,    0, -p.z) )
        s( vec3( p.x,    0, -p.z), vec3(-p.y,  p.y,  p.y) )
        s( vec3( p.x,    0, -p.z), vec3(-p.y, -p.y,  p.y) )
        s( vec3(-p.x,    0, -p.z), vec3( p.y, -p.y,  p.y) )
        s( vec3(-p.x,    0, -p.z), vec3( p.y,  p.y,  p.y) )
        s( vec3( p.x,    0,  p.z), vec3(-p.x,    0,  p.z) )
        s( vec3( p.x,    0,  p.z), vec3(-p.y,  p.y, -p.y) )
        s( vec3( p.x,    0,  p.z), vec3(-p.y, -p.y, -p.y) )
        s( vec3(-p.x,    0,  p.z), vec3( p.y,  p.y, -p.y) )
        s( vec3(-p.x,    0,  p.z), vec3( p.y, -p.y, -p.y) )
        s( vec3(   0,  p.z,  p.x), vec3(   0,  p.z, -p.x) )
        s2( vec3(   0,  p.z,  p.x), vec3( p.y, -p.y, -p.y) )
        s2( vec3(   0,  p.z,  p.x), vec3(-p.y, -p.y, -p.y) )
        s2( vec3(   0,  p.z, -p.x), vec3( p.y, -p.y,  p.y) )
        s2( vec3(   0,  p.z, -p.x), vec3(-p.y, -p.y,  p.y) )
        s2( vec3(   0, -p.z,  p.x), vec3(   0, -p.z, -p.x) )
        s2( vec3(   0, -p.z,  p.x), vec3( p.y,  p.y, -p.y) )
        s2( vec3(   0, -p.z,  p.x), vec3(-p.y,  p.y, -p.y) )
        s2( vec3(   0, -p.z, -p.x), vec3(-p.y,  p.y,  p.y) )
        s2( vec3(   0, -p.z, -p.x), vec3( p.y,  p.y,  p.y) )
   
  
        //p = vec3(0, .618, 1);  // stellated dodecahedron
      
  
    
    C = vec4(c + c*c, 0.);
   vec2 uv = ( U - .5*iResolution.xy ) / iResolution.y; 
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
    C*= vec4(happy_star(uv, anim) * vec3(0.55,0.5,0.55)*0.3, 1.0);
    	C+= vec4(hsv(hue, 0.6 * (1.0 - clamp(2.0 * c2 - 1.0, 0.0, 1.0)), clamp(2.0 * c2, 0.0, 1.0)), 1.0);
}