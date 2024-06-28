


const float near_dist = 10.;
const float far_dist = 50.;

const float sin_range = (30.) * 0.7;


const float num_raymarch_steps = 128.;

const float y_modulo = 4.;



const float top_cloud = 3.;
const float bot_cloud = 50.;

        
const float num_volumetric_rm_steps = 32.;

mat2 rot(float angle){
    float c = cos(angle);
    float s = sin(angle);
    
    return mat2(c,-s,s,c);
}


// Hash for 3d vectors
float rand3d(vec3 p){
    return fract(4768.1232345456 * sin((p.x+p.y*43.0+p.z*137.0)));
}

// 3D value noise
float noise3d(vec3 x){
    vec3 p = floor(x);
    vec3 fr = fract(x);
    vec3 LBZ = p + vec3(0.0, 0.0, 0.0);
    vec3 LTZ = p + vec3(0.0, 1.0, 0.0);
    vec3 RBZ = p + vec3(1.0, 0.0, 0.0);
    vec3 RTZ = p + vec3(1.0, 1.0, 0.0);

    vec3 LBF = p + vec3(0.0, 0.0, 1.0);
    vec3 LTF = p + vec3(0.0, 1.0, 1.0);
    vec3 RBF = p + vec3(1.0, 0.0, 1.0);
    vec3 RTF = p + vec3(1.0, 1.0, 1.0);

    float l0candidate1 = rand3d(LBZ);
    float l0candidate2 = rand3d(RBZ);
    float l0candidate3 = rand3d(LTZ);
    float l0candidate4 = rand3d(RTZ);

    float l0candidate5 = rand3d(LBF);
    float l0candidate6 = rand3d(RBF);
    float l0candidate7 = rand3d(LTF);
    float l0candidate8 = rand3d(RTF);

    float l1candidate1 = mix(l0candidate1, l0candidate2, fr[0]);
    float l1candidate2 = mix(l0candidate3, l0candidate4, fr[0]);
    float l1candidate3 = mix(l0candidate5, l0candidate6, fr[0]);
    float l1candidate4 = mix(l0candidate7, l0candidate8, fr[0]);


    float l2candidate1 = mix(l1candidate1, l1candidate2, fr[1]);
    float l2candidate2 = mix(l1candidate3, l1candidate4, fr[1]);


    float l3candidate1 = mix(l2candidate1, l2candidate2, fr[2]);

    return l3candidate1;
}

// 3D simplex noise, cool trick
float supernoise3d(vec3 p){
	float a =  noise3d(p);
	float b =  noise3d(p + 10.5);
	return (a + b) * 0.5;
}

float sample_density(vec3 p){
    
    float height_scale = smoothstep(-0.5, 0., p.y);
    height_scale = 1.;
    
    //p *= 0.5;
    
    float a = 0.0;
    float w = 0.5;
    for(int i=0;i<4;i++){
        float x = abs(0.5 - supernoise3d(p))*2.0;
        a += x * w;
        p = p * 2.9;
        w *= 0.60;
    }
    
    //return a;
    return clamp(a - 1.0 - clamp(p.y, -1., 0.) , 0.0, 1.);
    return clamp(a * height_scale, 0.01, 1.);
}


float wave_pattern(vec3 pos){
    float wave = 0.;
    
    // big horizontal wave
    float big_wave = sin(pos.z * 0.04 - iTime * 1.);    
    big_wave *= big_wave;    
    big_wave *= big_wave; 
    wave += big_wave * sin_range * (0.6 + sin(pos.z * 0.0133 - iTime * 3.) * 0.3);
    
    // small horizontal waves
    wave += (sin(pos.z * 0.1 - iTime * 1.7) + 1.) * sin_range * 0.10;
    wave += (sin(pos.z * 0.3 - iTime * 9.3) + 1.) * sin_range * 0.02;
        
    // vertical wave
    float vert_pos = pos.y - pos.z - sin(pos.z * 1.1) * 6.;
    float vertical_wave = sin(vert_pos * 0.02  - iTime * 0.5);
    vertical_wave *= vertical_wave;
    vertical_wave *= vertical_wave;
    wave += vertical_wave * sin_range * 0.5;
    
    return wave;
}

float sdf_dist(vec3 pos){

    float plane_d = far_dist - abs(pos.x);
    
    //if (abs(pos.z) > 999142.)
    if (abs(pos.y) > 11122.)
    {
        return 0.;
        return plane_d;
    }   

    // to get a regular pattern of "levels", adjust pos.y
    float pos_y_modulo = mod(pos.y, y_modulo);
    pos.y = pos.y - pos_y_modulo;
    
    // get pos of wave
    float wave = wave_pattern(pos);    
    float wave_pos = far_dist - wave;
    
    
    float dist = wave_pos - abs(pos.x);
    
    return dist;
}

vec3 get_normal(vec3 pos){
    const float eps = 0.1;
    vec3 eps_vec = vec3(eps, 0., 0.);
    
    float fx = sdf_dist(pos + eps_vec.xyz) - sdf_dist(pos - eps_vec.xyz);
    float fy = sdf_dist(pos + eps_vec.yxz) - sdf_dist(pos - eps_vec.yxz);
    float fz = sdf_dist(pos + eps_vec.yzx) - sdf_dist(pos - eps_vec.yzx);
    return normalize(vec3(fx, fy, fz) / eps);
}

float raymarch(vec3 ro, vec3 rd, float start, float end){
    
    float t = start;
    
    // initial pos
    vec3 pos = ro + rd * t;
    
    for (float step_idx = 0.; step_idx<num_raymarch_steps; ++step_idx){
        // get current sdf dist
        float dist = sdf_dist(pos);
        
        // break if close enough, or if we've gone outside far (shouldn't happen?)
        if (dist < 0.001 || t > end ){ break; }
            
        // set pos for next iteration
        t += dist * 0.5;  
        pos = ro + rd * t;
    }
    
    return t;
}
   
      
vec4 calc_transmission(vec3 ro, vec3 rd, float t_start, float t_end){
    
    vec4 sum_col = vec4(0.);
    float step_sz = (t_end - t_start)/ num_volumetric_rm_steps;
    
    // initial pos
    float t = t_start;   
    step_sz = 1.001;
    
    for (float step_idx = 0.; step_idx<128.; ++step_idx){
        if (sum_col.a > 0.99) break;
        
        vec3 pos = ro + rd * t;
        
        // get current cloud dens;
        //float density = sample_density(pos * 0.25 +vec3(0, -01.1*iTime, -1.5*iTime));
        
        float density = sample_density(pos);
        
        vec4 col = vec4(mix(vec3(0), vec3(1), density), density);
        col.a = density * 0.4;
        col.rgb *= col.a;

        sum_col += (1. - sum_col.a) * col;
        sum_col.a *= 0.99;
        
        
        t += step_sz;
    }
    
    return sum_col;
}
        

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord/iResolution.xy - 0.5) * 2.;
    
    vec3 ro = vec3(0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.));
    
    // mouse rot
    vec2 mouse = (iMouse.xy / iResolution.xy) - 0.5;
    mouse *= 2.;
    mouse.x *= 3.1415;
    mouse.y *= 3.1415 * 0.5;
    rd.yz *= rot(-mouse.y);
    rd.xz *= rot(-mouse.x);
    
    
    // figure out where we start/end raymarching
    float rd_x = max(abs(rd.x), 0.001);
    float t_start = near_dist / rd_x;
    float t_end = far_dist / rd_x;
    
    
    // get ray dist
    float t = raymarch(ro, rd, t_start, t_end);
    vec3 intersection_point = ro + rd * t;
    
    vec3 normal = get_normal(intersection_point);
    
    vec3 light_dir = normalize(vec3(1,0,0));
    float diff = abs(dot(light_dir, normal));
    diff = pow(diff, 2.) * 1.;
    vec3 col = vec3(diff);
    
    // color per level:
    float intersection_y_level = mod(intersection_point.y, y_modulo);
    float y_gradient = intersection_y_level / y_modulo;
    col += vec3(y_gradient * 0.3);
      

    
    // add fog    
    vec3 fog_color = vec3(0.000,0.000,0.000);
    float fog_val = -t * 0.0025 + t*(min(rd.y, 0.)) * 0.01;
    fog_val += 0.;
    fog_val = min(fog_val, 0.);
    
    col = mix(fog_color, col, exp(fog_val));
    
    
    // get fog density
    float fog_transmission = 0.;
    //col = vec3(0);
    if (rd.y < 0.){
        float rd_y = max(abs(rd.y), 0.01);
    
        float fog_start = top_cloud / rd_y;
        float fog_end = bot_cloud / rd_y;
        
        vec4 fog_col = calc_transmission(ro, rd, fog_start, fog_end);
        float br = fog_col.x;
        
        br = pow(br, 1.);
        //col = vec3(br);
        //col = fog_col.rgb;
        
    }
    
    
    float scattering = (1.-fog_transmission) * 0.2;
    //col += vec3(1.000,1.000,1.000) * scattering;    
    //col = mix(vec3(0.000,0.000,0.000), col, fog_transmission);
    
    

    // Output to screen
    fragColor = vec4(col,1.0);
}