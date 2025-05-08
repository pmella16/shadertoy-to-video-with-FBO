vec2 fold = vec2(-0.5, -0.5);
vec2 translate = vec2(1.5);
float scale = 1.15;

vec3 hsv(float h,float s,float v) {
	return mix(vec3(3.1),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}

vec2 rotate(vec2 p, float a){
	return vec2(p.x*cos(a)-p.y*sin(a), p.x*sin(a)+p.y*cos(a));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 ndc = -1.0 + 2.0*fragCoord.xy/iResolution.xy; // coordinates centered on screen center (-1, 1)
	vec2 result = -1.0 + 2.0*fragCoord.xy/iResolution.xy; // to ndc
	result.x *= iResolution.x/iResolution.y; // adjust to ratio
	result *= 0.182;
	float x = result.y;
	result = abs(mod(result, 4.0) - 2.0);
    

    
	for(int i = 39; i > 0; i--){
		result = abs(result - fold) + fold;
		result = result*scale - translate;
		result = rotate(result, 3.14159/(0.10+sin((0.0)*0.0005+float(i)*0.50000001)*0.499997+0.5) + iTime/10.0);
	}
	float i = x*x + atan(result.y, result.x) + iTime*0.02;
	float h = floor(i*4.0)/8.0 + 1.107;
	h += smoothstep(-0.1, 0.8, mod(i*2.0/5.0, 1.0/4.0)*900.0)/0.010 - 0.5;
	fragColor=vec4(hsv(h, 1.0, smoothstep(-3.0, 3.0, length(result)*1.0)), 2);
}