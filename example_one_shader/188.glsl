vec3 palette(float t){
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    
    return a + b*cos(6.28318*(c*t+d));
}


vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}


float random (float x) {
	float f = 43758.5453123;
	return fract(sin(x) * f);
}

float random (vec2 x) {
	vec2 r = vec2(12.9898, 78.233);
	return random(dot(x, r));
}

//
// Basic noise functions.
//

float noise(float x) {
	float i = floor(x);
	float fr = fract(x);
	return mix(random(i), random(i + 1.0), fr);
}

float noise(vec2 x){
	vec2 i = floor(x);
	vec2 fr = fract(x);
	fr = fr*fr*(3.0-2.0*fr);
	float res = mix(
		mix(random(i), random(i+vec2(1.0,0.0)), fr.x),
		mix(random(i + vec2(0.0,1.0)), random(i + vec2(1.0,1.0)), fr.x),
		fr.y);
	return res*res;
}
#define Q(p) p *= 2.*r(myround(atan(p.x, p.y) * 4.) / 4.)
#define r(a) mat2(cos(a + asin(vec4(0,1,-1,0))))
//	Simplex 3D Noise by Ian McEwan, Ashima Arts
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float noise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

//
// FBM functions.
//

float fbm (float x, int octaves, float amplitude, float frequency, float lacunarity, float gain) {
	float value = 0.0;
	for (int i = 0; i < octaves; ++i) {
		value += amplitude * noise(x * frequency);
		frequency *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

float fbm (vec2 x, int octaves, float amplitude, float frequency, float lacunarity, float gain) {
	float value = 0.0;
	// Rotate to reduce axial bias
	mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < octaves; ++i) {
		value += amplitude * noise(x * frequency);
		x *= rot;
		frequency *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

float fbm(vec3 x, int octaves, float amplitude, float frequency, vec3 shift, float lacunarity, float gain) {
	float value = 0.0;
    for (int i = 0; i < octaves; ++i) {
        float sn = noise(x * frequency);
        value += amplitude * sn;
        x += shift;
        frequency *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

vec2 rotate(vec2 r, float theta) {
    return vec2(cos(theta) * r.x - sin(theta) * r.y, sin(theta) * r.x + cos(theta * r.y));
}

//
// FBM functions with default values.
//

float fbm(float x, int octaves) {
	return fbm(x, octaves, 0.5, 1.0, 2.0, 0.5);
}

float fbm(vec2 x, int octaves) {
	return fbm(x, octaves, 0.5, 1.0, 2.0, 0.5);
}

float fbm(vec3 uv, int octaves) {
    return fbm(uv, octaves, 0.5, 1.0, vec3(8), 2.0, 0.5);
}


mat2 rotationMatrix(float angle)
{
    float sine = sin(angle), cosine = cos(angle);
    return mat2( cosine, -sine, 
                 sine,    cosine );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Initialization
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) /iResolution.y;
   
    Q(uv);
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
      vec2 fromCenter = (fragCoord - iResolution.xy*0.5)/iResolution.x;
    float l = length(fromCenter);
    
    l *= 1.6;
    
    fromCenter *= rotationMatrix((0.0005/l)*iTime);

    
    //vec2 uv = fragCoord/iResolution.xy;
    //uv.y *= iResolution.y / iResolution.x;
    //uv.y += iResolution.x / iResolution.y * 0.5;
    
    //vec2 fromCenter = uv - vec2(0.5, 0.5);

    // Time varying pixel color
    
    float a = (fbm((l + fbm(fromCenter, 9))*22.0 + iTime*0.4 + fbm(l*10.0 + iTime*0.7, 9)*3.0, 9));
    float b = (fbm((l + fbm(fromCenter, 7))*20.0 + iTime*0.4 + fbm(l*10.0 + iTime*0.75, 9)*3.0, 9));
    float c = (fbm((l + fbm(fromCenter, 6))*20.0 + iTime*0.3999 + fbm(l*10.0 + iTime*0.699, 9)*3.0, 9));
    vec3 col2 = vec3(a, b, c);
    
    col2 *= 0.25 + pow(l, 0.75)*1.6;
    //Color calculation ? 
   for(float j =0.0; j<.055; j+= 0.01){
       for(float i =0.0; i< 2.; i++) {
            uv = fract(uv *1.5) - 0.5;
 uv+=fract(iTime*0.1);
            float d = length(uv) * exp(-length(uv0));

            vec3 col = palette(length(uv0) + i*.4 + iTime);

            d = sin(d*8.+ (iTime*.1))/1.+j;
            d = abs(d);

            d=0.01/d;

            finalColor += col*d*col2*10.;
       }
   }
    
    fragColor = vec4(finalColor, 1.0) ;
    
}