// shader strongly based on what I've seen in 
// https://www.shadertoy.com/view/clKfWm by afl_ext,
// and other shaders like Clouds by iq, and Cloud Ten by nimitz

const float start_plane = 10.;
const float end_plane = 20.;

/////////////////
// density params - in general, we want density to increase as we go higher,
/////////////////
// having density 0. at start layer and 1. at end layer seems like a good default

// reaching 1. faster, e.g. 2. -> clouds really fill sky, darker
// reaching 1. slower, e.g 0.5 -> fewer clouds, lighter
float density_grad_invspeed = 1.; // 1.

// exponent of density gradient, has similar effect to the above,
// adjusting this rather might also provide a bit of a nicer "bouncy" shape?
float density_grad_pow = 0.8; //1.

// higher value makes the cloud more scarce too
float dens_tm_low_thr = 0.0; // 0.
// lower value can promote a "sharper" look of the cloud creases
// might only be due to the total (dens_tm_high_thr - dens_tm_low_thr) value,
// as that value being low corresponds to raising the derivative
float dens_tm_high_thr = 0.45; // 1.


// raise in scattering contribution gradually as we go up
// reaching 1. slightly earlier than top seems good
float scattering_grad_invspeed = 0.9; // 1.
// using 2. makes the bright creases a bit more pronounced
float scattering_grad_pow = 1.75; //1.

const mat3 fbm_mat = mat3(
2./3., 2./3., -1./3.,
-1./3., 2./3., 2./3.,
2./3., -1./3., 2./3.);

const mat3 fbm_mat2 = mat3(
0.6, 0., 0.8,
0., 1., 0.,
-0.8, .0, 0.6);





float rand(vec3 pos){
    vec3 v = vec3(1234.1234, 2345.2345, 3456.3456);
    return fract(1234.1234 * sin(dot(pos, v)));
}

float val_noise(vec3 pos){
    vec3 pos_fract = fract(pos);
    vec3 pos_floor = floor(pos);
    
    float e000 = rand(pos_floor + vec3(0.,0.,0.));
    float e100 = rand(pos_floor + vec3(1.,0.,0.));    
    float e010 = rand(pos_floor + vec3(0.,1.,0.));
    float e110 = rand(pos_floor + vec3(1.,1.,0.)); 
    
    float e001 = rand(pos_floor + vec3(0.,0.,1.));
    float e101 = rand(pos_floor + vec3(1.,0.,1.));    
    float e011 = rand(pos_floor + vec3(0.,1.,1.));
    float e111 = rand(pos_floor + vec3(1.,1.,1.));
    
    // interpolate across x axis
    float eX00 = mix(e000, e100, pos_fract.x);
    float eX10 = mix(e010, e110, pos_fract.x);
    float eX01 = mix(e001, e101, pos_fract.x);
    float eX11 = mix(e011, e111, pos_fract.x);
    
    float eXY0 = mix(eX00, eX10, pos_fract.y);
    float eXY1 = mix(eX01, eX11, pos_fract.y);
    
    float eXYZ = mix(eXY0, eXY1, pos_fract.z);
    
    return eXYZ;
}

float val_noise_super(vec3 pos){
    float a = val_noise(pos);
    float b = val_noise(pos + 13.5);
    return (a+b)*0.5;
}

float fbm(vec3 pos){
    pos += vec3(0., -iTime * 0.25, +iTime * 1.2);

    // adjust pos scale by approximately 1/end_plane
    pos *= 0.0488;    
    
    float sum = 0.;
    float amplitude = 0.5;
    
    for (int i = 0; i<6; ++i){
        float noise = val_noise_super(pos);
        
        // adjust noise shape
        noise = (noise-0.5) * 2.; // [-1,1]
        noise = abs(noise);
        
        // add it
        sum += amplitude * noise;
        
        amplitude *= 0.6;
        //pos *= fbm_mat;
        pos *= fbm_mat2;
        pos *= 2.03;
        
    }
    
    return clamp(sum * 2., 0.,1.);
}

vec2 cloud_info(vec3 pos){

    // density
    float fbm_val = fbm(pos) - 1.; // in [-1, 0]
    
    // density
    float density_gradient = (pos.y - start_plane) / (density_grad_invspeed * (end_plane - start_plane));
    density_gradient = clamp(density_gradient, 0., 1.);
    
    // adjust shape of the gradient
    density_gradient = pow(density_gradient, density_grad_pow);
    
    float density = clamp(fbm_val + density_gradient, 0., 1.);
    
    
    // scattering
    float scattering_grad = (pos.y - start_plane) / (scattering_grad_invspeed * (end_plane - start_plane));
    scattering_grad = clamp(scattering_grad, 0., 1.);
    
    // adjust shape of the scatter - make it more pronounced at large heights
    scattering_grad = pow(scattering_grad, scattering_grad_pow);
    
    float scattering = clamp(scattering_grad, 0., 1.);
    
    return vec2(density, scattering);
}    

mat2 rot(float angle){
    float c = cos(angle);
    float s = sin(angle);
    
    return mat2(c,s,-s,c);
}


float lerp_step(float a, float b, float x){
    float v = (x-a) / (b-a);
    return clamp(v, 0.,1.);
}

const float num_steps = 64.;

vec3 raymarch_clouds(vec3 start, vec3 end){
    
    vec4 sum_col = vec4(0.);
    for (float i = 0.; i<num_steps; ++i){
        if (sum_col.a > 0.98) break;
    
        // get pos where we will sample cloud density
        vec3 pos = mix(start, end, i/num_steps);
        
        // get cloud info
        vec2 cloud_info = cloud_info(pos);
        float density = cloud_info.x;
        float scattering = cloud_info.y;
        
        // scale the density
        density = lerp_step(dens_tm_low_thr, dens_tm_high_thr, density);
        
        // scattering
        scattering = lerp_step(0.0, 1., scattering);
        
        // set col element for current sample
        vec4 col;
        col.rgb = vec3(scattering) * 1.0;
        col.a = density * 1.0;
        
        // premultiply alpha
        col.rgb *= col.a;
        
        sum_col += (1. - sum_col.a) * col;
        
    }
    
    return sum_col.rgb * 1.;
}

// debug function, returns the "accumulated" density along a ray
float raymarch_clouds_debug(vec3 start, vec3 end){
    
    float sum = 0.0;
    
    // measure length of single step by comparing start and vector after 1 step
    float step_size = length(mix(start, end, 1./num_steps) - start);
    
    for (float i = 0.; i<num_steps; ++i){
        // get pos where we will sample cloud density
        vec3 pos = mix(start, end, i/num_steps);
        
        // get cloud info
        vec2 cloud_info = cloud_info(pos);
        float density = cloud_info.x;
        
        sum += density * step_size;        
    }
    
    return sum;      
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv_screen_space = fragCoord/iResolution.xy;
    vec2 uv = (uv_screen_space - 0.5) * 2.;
    // ro, rd
    vec3 ro = vec3(0,0,0);
    vec3 rd = vec3(uv.x, uv.y, 1.2);
    rd = normalize(rd);
    
    // mouse
    if (iMouse.z > 0.){
    vec2 m = iMouse.xy/iResolution.xy - 0.5;
    rd.yz *= rot(m.y * 3.14);
    rd.xz *= rot(m.x * 3.14);
    }
    
    vec3 col = vec3(0);
    if (rd.y > 0.){
        float t_start = abs(start_plane - ro.y) / abs(rd.y);
        float t_end = abs(end_plane - ro.y) / abs(rd.y);
        
        vec3 start = ro + rd * t_start;
        vec3 end = ro + rd * t_end;
        
        
        if (uv_screen_space.x < (iMouse.x/iResolution.x) || true){
            col = raymarch_clouds(start, end) * 1.2;
        }
        
        else{
            float accumulated_density = raymarch_clouds_debug(start, end);
            accumulated_density *= 0.5;
            col = vec3(accumulated_density);
        }
        
        float fog = clamp(exp(-t_start * 0.0025), 0., 1.);
        
        col = mix(vec3(0), col, fog);
    }   

    
    // Output to screen
    fragColor = vec4(col,1.0);
}