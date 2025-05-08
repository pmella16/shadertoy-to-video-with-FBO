
// Number of iterations used in ray marching loop
#define ITR 150
// Maximum ray marching distance
#define DST 90.0
// Anything less than this is counted as surface collision in the ray marching loop
#define SRF 0.001
// Used in normal calculations
#define EPS vec2(0.0001, -0.0001)
// Number of scene primitives
#define NSO 6

#define CONTRAST(X, A, B) clamp((A) * ((X) - 0.5) + 0.5 + (B), 0.0, 1.0)

vec3 hue(vec3 c, float h) {
    const vec3 k = vec3(0.57735, 0.57735, 0.57735);
    float ca = cos(h);
    return vec3(c * ca + cross(k, c) * sin(h) + k * dot(k, c) * (1.0 - ca));
}

#define PI acos(-1.0)
#define RT(X) mat2(cos(X), -sin(X), sin(X), cos(X))
#define RND(X) fract(sin(dot(X, vec2(132.0, 513.1))) * 1331.23)
float g = 0.0;
float t = 0.0;
float tw = 0.0;
float smax(float a, float b, float s)
{
	float h = clamp(0.5 - 0.5 * (b - a) / s, 0.0, 1.0);
	return mix(b, a, h) + s * h * (1.0 - h);
}

float snoise(vec2 uv)
{

    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    float a = RND(i + vec2(0, 0));
    float b = RND(i + vec2(1, 0));
    float c = RND(i + vec2(0, 1));
    float d = RND(i + vec2(1, 1));
    
    vec2 u = smoothstep(0.0, 1.0, f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x)
                          + (d - b) * u.x * u.y;

}

float turbulence(vec2 uv, float octs)
{
    float t = -0.45;
    for (float i = 1.0; i <= octs; i++)
    {
        float pw = pow(2.0, i);
        t += abs(snoise(uv * pw) / pw);


    }
    return t;

}


float box(vec3 sp, vec3 dm)
{

    sp = abs(sp) - dm;
    return max(max(sp.x, sp.y), sp.z);

}


// Map signed distance functions of the scene
vec2 map(vec3 sp)
{

    float dst[NSO];
    float z = sp.z;
    sp.z = mod(sp.z + t + t * 70.0 * (1.0 - tw), 20.0) - 10.0;
    sp.xy *= RT(z * 0.05);
    for (int i = 0; i < 1; i++)
    {
        sp = abs(sp) - vec3(11, 9, 5.9);
        sp.xz *= RT(16.05);
        sp.xy *= RT(4.66);
    
    }
    
    vec3 spj = sp;
    vec3 spk = sp;
    vec3 spw = sp;
    sp.xy *= RT(sp.z * 0.1);
    sp = abs(sp) - vec3((0.5 + 0.5 * sin(8.11 * 0.5)) * 5.0 + 1.0);
    
    dst[0] = length(sp) - 4.0;
    vec3 spc = sp;
    spc *= clamp(abs(sp.y * 0.5), 1.0, 1.5);
    for (int i = 0; i < 3; i++)
    {
        sp = abs(sp) - vec3(0.5, 0.2, 0.2);
        sp.zy *= RT(5.48);

    }
    
    float bx = box(sp, vec3(0.25, 0.25, 4.4));
    dst[0] = smax(dst[0], bx, 2.0);
     
    dst[1] = box(spc, vec3(0.5, 4.0, 0.5)); 
    dst[2] = length(spw) - 2.0;
    g += pow(0.15 / max(dst[2], 0.001), 2.0);
    
    for (int i = 0; i < 3; i++)
    {
        spw = abs(spw) - vec3(mod(-t, 5.2));
        spw.xy *= RT(3.9);
    }
    
    dst[3] = max(abs(length(spw.xz) - 0.1), 0.7);
    g += pow(0.15 / max(dst[3], 0.001), 3.0);
    
    dst[4] = spk.y + 13.0;
    
    
    float s = clamp(spj.y - 2.0, 1.1, 2.0);
    
    dst[5] = box((abs(spj) - vec3(12, 0, 12)) * s, vec3(3, 17, 3)) / s;
    
    float id = 0.0;
    for (int i = 1; i < NSO; i++) {
        
        if (dst[i] < dst[0]) {
            dst[0] = dst[i];
            id = float(i);
       
        }
         
    }
    
    return vec2(dst[0] * 0.8, id);

}



// March the rays
vec2 mrch(vec3 ro, vec3 rd) {

    float d0 = 0.0;
    float id = 0.0;
    for (int i = 0; i < ITR; i++) {
        vec3 sp = ro + rd * d0;
        vec2 ds = map(sp);
        if (d0 > DST || abs(ds.x) < SRF) break;
        d0 += ds.x;
        id = ds.y;
    
    }
    
    if (d0 > DST) d0 = 0.0;
    return vec2(d0, id);

}


// Normal for lighting calculations
// Taken from Evvvvil
vec3 nml(vec3 sp)
{
    return normalize(EPS.xyy * map(sp + EPS.xyy).x +
                     EPS.yyx * map(sp + EPS.yyx).x +
                     EPS.yxy * map(sp + EPS.yxy).x +
                     EPS.xxx * map(sp + EPS.xxx).x);
}


void mainImage(out vec4 c_out, in vec2 uu)
{
    // Stretching the x and y axes so that it doesn't looked squashed in either horizontal
    // or vertical direction
    vec2 rrr = iResolution.xy;
    vec2 uv = (uu + uu - rrr) / rrr.y;
    t = mod(iTime, PI * 24.0);
    // Ray origin (position of camera)
    vec3 r0 = vec3(3, 0, -5);
    tw = clamp(mod(t, 4.0) - 2.0, 0.0, 1.0);
    vec3 r1 = vec3(2, 23, -2);
    vec3 ro = mix(r0, r1, tw);
    //ro.xz *= RT(PI * 0.5);
    //ro = mix(ro, r0, clamp(t - 7.0, 0.0, 1.0));
    // Point camera is fixated
    vec3 fx = vec3(0, 0, 0);
    // math shit I don't understand but know how to type.
    vec3 w = normalize(fx - ro);
    vec3 u = normalize(cross(w, vec3(0, 1, 0)));
    vec3 v = normalize(cross(u, w));
    // ray direction (direction ray is facing into the scene,
    // before being marched.
    vec3 rd = normalize(mat3(u, v, w) * vec3(uv, 0.5));
    // color vector for color returned after the GPU does all the heavy lifting
    vec3 clr = vec3(0);
    
    // light position
    vec3 lp = vec3(2.5, 0.15, -9.0);
    
    // Colors of scene objects indexed by id
    vec3 obj_clrs[NSO] = vec3[NSO](
        vec3(1, 0, 0.6),
        vec3(1.0, 0.1, 0.1),
        vec3(1.0, 1.0, 0.0),
        vec3(1),
        vec3(0.1),
        vec3(0)
    );
    
    vec3 acc = vec3(1.0);
    
    // background color
    vec3 bgc = vec3(0.01);
    clr = bgc;
    
    for (int i = 0; i < 1; i++) {
    
        vec2 ds = mrch(ro, rd);
        float d = ds.x;
        int id = int(ds.y);

        if (d > 0.0) {

            // point of surface hit
            vec3 sp = ro + rd * d;
            // normal to surface hit point
            vec3 n = nml(sp);
            // light direction
            vec3 ld = normalize(lp - sp);
            
            // 
            vec3 clr_add = vec3(0);

            // diffuse lighting
            float df = max(0.0, dot(n, ld));

            // Ambient occlusion taken from NuSan FX
            float ao = clamp(map(sp + n * 0.5).x / 0.5, 0.0, 1.0);

            // specular highlight
            float spc = pow(max(dot(reflect(-ld, n), -rd), 0.0), 70.0);

            vec3 amb = obj_clrs[id];
            
            clr_add = amb * ao * df + spc;
            
            // distance fog, taken from Evvvvil
            clr_add = mix(clr_add, bgc, 1.0 - exp(-0.000011 * pow(d, 3.0)));
            clr = clr_add * acc;
            
           
        }
    
    }
    clr += g * vec3(1.01, 1, 1) * 0.1;
    float f = clr.r + clr.g + clr.b;
    clr = hue(clr, f + turbulence(uv, 5.0) * 4.0 + t);
    clr = CONTRAST(clr, 1.02, 0.0);
    c_out = vec4(pow(clr, vec3(0.4545)), 1.0);
    
    
}

