/*originals on glslasndbox*/

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;


//vec2 surpos = surfaceSize.xy;

const int MAX_ITER = 20; // Try 30 for extra flames

vec2 rotate(in vec2 v, in float a) {
	
	return vec2(cos(a)*v.x + sin(a)*v.y, -sin(a)*v.x + cos(a)*v.y);
}

float torus(in vec3 p, in vec2 t)
{
	vec2 q = abs(vec2(max(abs(p.x), abs(p.z))-t.x, p.y));
	return max(q.x, q.y)-t.y;
}

// These are all equally interesting, but I could only pick one :(
float trap(in vec3 p)
{
	//return abs(max(abs(p.z)-0.1, abs(p.x)-0.1))-0.01;
	//return length(max(abs(p.xy) - 0.05, 0.0));
	//return length(p)-0.5;
	#define var2 length(max(abs(p) - 0.35, 0.0))
	#define var3 abs(length(p.xz)-0.2)-0.01
	#define var1 sin(abs(min(torus(vec3(p.x, mod(p.y, sin(time*0.4))-0.2, p.z), vec2(0.1, 0.05)), max(abs(p.z)-0.05, abs(p.x)-0.05)))-0.005)
	#define var5 abs(min(torus(p, vec2(0.3, 0.05)), max(abs(p.z)-0.05, abs(p.x)-0.05)))-0.005
	#define var4 min(length(p.xz), min(length(p.yz), length(p.xy))) - 0.05
	return mix(mix(var2+var5, var5, sin(time*0.8)), mix(var1+var2, var3+var4, sin(time*0.7)), sin(0.987*time));

}

float map(in vec3 p)
{
	float cutout = dot(abs(p.yz),vec2(0.5))-0.0035;
	float road = max(abs(p.y-0.025), abs(p.z)-0.035);
	
	vec3 z = abs(3.0-mod(p, 6.0));


	float d = 999.0;
	float s = 1.0;
	for (float i = 0.0; i < 2.0; i++) {
		
		z = abs(1.0-mod(z+i/3.0,2.0));
		
		z = z*2.0 - 0.3;
		s *= 0.42;
		d = min(d, trap(z) * s);
	}
	return min(max(d, -cutout), 23.);
}

vec3 hsv(in float h, in float s, in float v) {
 float tit = sin(0.8512*time);
 float titi = sin(0.28428*time);
	return mix(vec3(.666), clamp(sin(6.66*atan(tit*time/time)*abs(fract(h + vec3(3, 2, 1) / 2.0) * 4.0 - 2.0) - .50), 0.0 , 1.0), /*sin(time+s)-cos(0.6*time)*/2.0) * v;
}

vec3 intersect(in vec3 rayOrigin, in vec3 rayDir)
{
	float total_dist = 0.0;
	vec3 p = rayOrigin;
	float d = 1.618;
	float iter = 0.0;
	float mind = 3.14159;//+sin((time*0.061)*23.2)*2.3; // Move road from side to side slowly
	
     float tit = sin(0.8512*time);
 float titi = sin(0.28428*time);
	for (int i = 0; i < MAX_ITER; i++)
	{		
		if (d < 0.001) continue;
		
		d = map(p);
		// This rotation causes the occasional distortion - like you would see from heat waves
		p += d*rayDir;
		mind = min(mind, d);
		total_dist += d;
		iter++;
	}

	vec3 color = vec3(0.0);
	if (d < 0.001) {
		float x = (iter/float(MAX_ITER));
		float y = (d-0.01)/0.01/(float(MAX_ITER));
		float z = (0.01-d)/0.01/float(MAX_ITER);
		if (max(abs(p.y-0.025), abs(p.z)-0.035)<0.002) { // Road
			float w = smoothstep(mod(p.x*69.0, 4.0), 2.0, 2.01);
			w -= 1.0-smoothstep(mod(p.x*69.0+2.0, 4.0), 2.0, 1.99);
			w = fract(w+0.0001);
			float a = fract(smoothstep(abs(mod(p.z, time*0.666 )), 0.000665, 0.00666));
			color = vec3((1.0-x-y*2.)*mix(vec3(0.3, 0.8, 0), vec3(0.1), 1.0-(1.0-w)*(1.0-a)));
		} else {
			float q = .750-x-y*2.+z;
			color = vec3(0.0, q, 1.0);
		}
	} else
		color = hsv(d, 0.673*tit, 0.4238*titi)*mind*45.0; // Background
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 resolution= iResolution.xy;
   float time = iTime;
    vec2 uv = fragCoord/iResolution.xy;

	vec3 upDirection = vec3(0, -1, 0);
	vec3 cameraDir = vec3(1,0,0);
	vec3 cameraOrigin = vec3(time*0.1, 0, 0);
	
	vec3 u = normalize(cross(upDirection, cameraOrigin));
	vec3 v = normalize(cross(cameraDir, u));
	vec2 screenPos = -6.0*sin(time*0.0725) + 12.0*sin(time*0.0725) * gl_FragCoord.xy / resolution.xy;
	screenPos.x *= resolution.x / resolution.y;
	vec3 rayDir = normalize(u * screenPos.x + v * screenPos.y + cameraDir*(1.0-length(screenPos)*0.5));
	
	fragColor = vec4(intersect(cameraOrigin, rayDir), 1.0);
} 
