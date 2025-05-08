#define STAR_COUNT 128
#define STAR_SIZE 0.005
#define SPEED 2.0
#define TRAIL 0.05
#define CENTER_RADIUS 0.1
#define STAR_COLOR vec3(1.0)

#define MASK_INTENSITY 1.0
#define MASK_SIZE 12.0
#define MASK_BORDER 0.8

#define ABERRATION_OFFSET vec2(2.0,0.0)
#define SCREEN_CURVATURE 0.08
#define SCREEN_VIGNETTE 0.4

#define PULSE_INTENSITY 0.5
#define PULSE_WIDTH 6e1
#define PULSE_RATE 2e1

#define SCANLINE_INTENSITY 0.5
#define SCANLINE_FREQUENCY 16.0
#define SCANLINE_DISTORT 0.01
// 簡易ノイズ関数（疑似的だけど滑らか）
float hash(vec2 p) {
    return fract(sin(dot(p ,vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // 四隅のランダム値
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    // 補間
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += noise(p) * amplitude;
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

float rand21(vec2 p) {
    return fract(sin(dot(p, vec2(12.456, 56.789))) * 798484.123);
}

vec2 rand22(vec2 p) {
    float r1 = rand21(p);
    return vec2(r1, rand21(r1 * p));
}

vec2 getPoint(vec2 id) {
    vec2 r = rand22(id);
    float time = iTime * 2.;

    vec2 speed = rand22(id + rand22(id));

    float x = cos(time * speed.x * (r.x + 1.)) * .4 + .5;
    float y = sin(time * speed.y * (r.y + 1.)) * .4 + .5;

    return vec2(x, y);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = (iTime+29.) * 60.0;
const float ZOOM = 10.;
    vec3 col3 = vec3(0.);

    vec2 uv3 = fragCoord.xy / iResolution.xy;
    vec2 orig_uv = uv3;
    uv3.x *= iResolution.x / iResolution.y;
    uv3 *= ZOOM;
    uv3.y += iTime;
	vec2 cPos = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    
    // distance of current pixel from center
	float cLength = length(cPos);
 uv3+= (cPos/cLength)*cos(cLength*0.00001-iTime*0.001) * 20.03;
    vec2 id = floor(uv3);
    vec2 gv = fract(uv3);

    float presence = 0.;
    for (int x = -1; x < 2; x++) {
        for (int y = -1; y < 2; y++) {
            vec2 offset = vec2(x, y);

            vec2 nid = id + offset;
            vec2 np = getPoint(nid);

            float size = rand21(nid) * .2;

            float x2 = distance(offset + np, gv);
            float y2 = max(size / x2 - size, .0);
            presence += y2;
        }
    }

    vec3 base_color = sin(vec3(2., 3., 5.) * iTime * .5) * .2 + .4;
    col3 = base_color * presence;
    float s3 = 0.0, v = 0.0;
    vec2 uv = (-iResolution.xy + 2.0 * fragCoord ) / iResolution.y;
	float t3 = time*0.000;
    vec2 F =fragCoord;
vec2 u=(F/iResolution.xy*2.-1.)*(1.+dot(F/F-1.,F/F-1.)*SCREEN_CURVATURE)*.5+.5;
    u=(u-.5)*vec2(iResolution.x/iResolution.y,1.);
    u+=vec2(sin(F.y*SCANLINE_FREQUENCY/iResolution.y+iTime*2.)*SCANLINE_DISTORT,0.);
    vec3 c=vec3(0);
    for(int i=0;i<STAR_COUNT;i++){
        float h=float(i),r=fract(sin(h*78.233)*43758.5453),t=fract(iTime*SPEED*.2+fract(sin(h*12.9898)*43758.5453));
        vec2 d=vec2(cos(r*6.283),sin(r*6.283)),p=d*mix(CENTER_RADIUS,2.,t*t),q=d*mix(CENTER_RADIUS,2.,max(0.,t-TRAIL)*max(0.,t-TRAIL)),l=p-q,n=l/(length(l)+1e-4);
        for(int k=0;k<3;k++){
            vec2 o=u+vec2(k==0?ABERRATION_OFFSET.x:k==2?-ABERRATION_OFFSET.x:0.,0.)/iResolution.xy;
            float j=clamp(dot(o-q,n),0.,length(l)),m=length(o-(q+n*j)),s=mix(STAR_SIZE,STAR_SIZE*.3,t);
            c[k]+=smoothstep(s,0.,m)*(.3+.7*j/(length(l)+1e-4))*STAR_COLOR[k];
        }
    }
    vec2 s=F/MASK_SIZE,t=s*vec2(3.,1.),e=vec2(0.,fract(floor(s.x)*.5));
    c*=(1.+(vec3(mod(floor(t.x),3.)==0.,mod(floor(t.x),3.)==1.,mod(floor(t.x),3.)==2.)*3.*(1.-(fract(t+e)*2.-1.)*(fract(t+e)*2.-1.)*MASK_BORDER).x*(1.-(fract(t+e)*2.-1.)*(fract(t+e)*2.-1.)*MASK_BORDER).y-1.)*MASK_INTENSITY)*(1.-SCANLINE_INTENSITY*(.5+.5*sin(F.y*SCANLINE_FREQUENCY/iResolution.y+iTime*2.)))*pow(max(1.-(F/iResolution.xy*2.-1.)*(F/iResolution.xy*2.-1.),0.).x*max(1.-(F/iResolution.xy*2.-1.)*(F/iResolution.xy*2.-1.),0.).y,SCREEN_VIGNETTE)*(1.+PULSE_INTENSITY*cos(F.x/PULSE_WIDTH+iTime*PULSE_RATE));
 vec4   O=vec4(c,1.);
    vec2 p = uv * 4.0;
    
    vec3 finalColor = vec3(0.0);
    
   float t4 = mod(iTime * 0.5, 60.0);

   vec2 warpedTime = vec2(
       t4 + fbm(p + vec2(sin(t4 + p.y * 0.5), 0.)) * 2.0,
       t4 + fbm(p + vec2(0., cos(t4 + p.x * 0.5))) * 2.0
   );
   float f = fbm(p + warpedTime);
    
    // float hue = 0.61 + 0.14 * sin(iTime * 0.3);
    float hue = fract(iTime * 0.05);
    // float hue = fract(0.5 + 0.5 * sin(iTime));
    
    vec3 col4 = hsv2rgb(vec3(hue, 0.8, 1.0));
    
    col4 *= pow(f, 1.8);
	float si = sin(t3*1.5); // ...Squiffy rotation matrix!
	float co = cos(t3);
	uv *= mat2(co, si, -si, co);
	vec3 col = vec3(0.0);
	vec3 init = vec3(0.25, 0.25 + sin(time * 0.000) * .1, time * 0.0000);
	for (int r = 0; r < 100; r++) 
	{
		vec3 p = init + s3 * vec3(uv, 0.143)*col4+col3;
		p.z = mod(p.z, 2.0);
		for (int i=0; i < 10; i++)	p = abs(p * 2.04) / dot(p, p) - 0.75;
		v += length(p * p) * smoothstep(0.5, 0.5, 0.9 - s3) * .002;
		// Get a purple and cyan effect by biasing the RGB in different ways...
		col +=  vec3(v * 0.8, 1.1 - s3 * 1.0, .7 + v * 0.5) * v * 0.013;
		s3 += .01;
	}
	fragColor = vec4(col, 1.0);
}