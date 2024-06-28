#define PI 3.1415926535897932384626433
#define Iterations 20

// http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/
float DE(vec3 z, float Scale)
{
	vec3 a1 = vec3(1,1,1);
	vec3 a2 = vec3(-1,-1,1);
	vec3 a3 = vec3(1,-1,-1);
	vec3 a4 = vec3(-1,1,-1);
	vec3 c;
	int n = 0;
	float dist, d;
	while (n < Iterations) {
		 c = a1; dist = length(z-a1);
	        d = length(z-a2); if (d < dist) { c = a2; dist=d; }
		 d = length(z-a3); if (d < dist) { c = a3; dist=d; }
		 d = length(z-a4); if (d < dist) { c = a4; dist=d; }
		z = Scale*z-c*(Scale-1.0);
		n++;
	}

	return length(z) * pow(Scale, float(-n));
}

// Custom gradient - https://iquilezles.org/articles/palettes/
vec3 palette1(float t) {
    return .5+.5*cos(6.28318*(t+vec3(.3,.416,.557)));
}

vec3 palette2(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(2.0, 1.0, 0.0);
    vec3 d = vec3(0.50, 0.20, 0.25);
    return a + b*cos( 6.28318*(c*t+d) );
}

mat2 rotate2d(float angle){
    return mat2(cos(angle), -sin(angle),
                sin(angle), cos(angle));
}

float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
  return mix(a, b, h) - k*h*(1.0-h);
}

// Scene distance
float map(vec3 p) {
    vec3 p2 = vec3(p.xy * rotate2d(PI / 2.0), p.z);
    //float d1 = DE(p, 1.5 - 0.5 * cos(0.2 * iTime));
    //float d2 = DE(p2, 1.5 + 0.5 * cos(0.2 * iTime));
    float d1 = DE(p, 1.5 - 0.5 * cos(0.2 * iTime));
    float d2 = DE(p2, 1.5 - 0.5 * cos(0.2 * iTime));
    return smin(d1, d2, 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;

    // Initialization
    vec3 ro = vec3(0, 0, -2);         // ray origin
    vec3 rd = normalize(vec3(uv, 1)); // ray direction
    vec3 col = vec3(0);               // final pixel color
    
    rd.xy *= rotate2d(-PI / 4.0);

    float t = 0.; // total distance travelled

    // Raymarching
    int i = 0;
    for (; i < 80; i++) {
        vec3 p = ro + rd * t;     // position along the ray

        float d = map(p);         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > 100.) break;      // early stop if too far
    }

    // Coloring
    float u = log(0.1*t) + 0.3 * iTime;
    float q = length(0.25 * uv) + float(i) / 80.0 + 0.2 * iTime;
    col = vec3(palette1(u) * palette2(q));

    fragColor = vec4(col, 1);
}