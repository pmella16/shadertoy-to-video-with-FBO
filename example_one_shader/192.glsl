#define R(p,a,r) mix(a*dot(p,a),p,cos(r)) + sin(r)*cross(p,a)
#define H(h) (cos((h)*6.3+vec3(0,23,21))*.5+.5)
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
vec3 color(float t) {
  vec3 c1 = vec3(1.0, 0.0, 0.0);
  vec3 c2 = vec3(0.0, 1.0, 0.0);
  vec3 c3 = vec3(0.0, 0.0, 1.0);
  vec3 c4 = vec3(1.0, 1.0, 0.0);
  vec3 c5 = vec3(1.0, 0.0, 1.0);
  vec3 c6 = vec3(0.0, 1.0, 1.0);

  float r = sin(t) * 0.5 + 0.5;
  if (r < 0.2) return mix(c1, c2, r * 5.0);
  if (r < 0.4) return mix(c2, c3, (r - 0.2) * 5.0);
  if (r < 0.6) return mix(c3, c4, (r - 0.4) * 5.0);
  if (r < 0.8) return mix(c4, c5, (r - 0.6) * 5.0);
  return mix(c5, c6, (r - 0.8) * 5.0);
}
float f_n(
    vec2 o_trn,
    float n_its,
    float n_t,
    float n_scl_min
){

    float n_tau = radians(360.);
    float n_min = 1.;
    float n_col = 1.;
    float n_dcntr = length(o_trn);
    for(float n_it = 0.; n_it < n_its; n_it+=1.){
   
        float n_it_nor = n_it / n_its;
        float noff = 0.;
        float n_amp = 0.1;
        vec2 o = vec2(
            sin((n_it_nor)*n_tau),
            cos((n_it_nor)*n_tau)
        )*n_amp-o_trn;
        o.xy*=mat2(cos(iTime),sin(iTime),-sin(iTime), cos(iTime));
       
        float n = length(o);
        float n_max = 12.;
        float n_reps = 3.;
        float n_res = 0.;
        for(float n_rep = 0.; n_rep < n_reps; n_rep+=1.){
            float n_rep_nor = fract((n_rep/n_reps)+n_t*.1);
            float n_freq = sin(n_rep_nor*n_tau)*.5+.5;
            float n = sin(n*n_max*n_freq*(1./n_dcntr))*.5+.5;
            n = pow(n, 1./n_dcntr*.1);
            //n = 1.-n;
            n_res+= (1./n_reps)*n;
        }

       
        n_col*=n_res;
    }
   
    n_col = clamp(n_col, 0., 1.);
   

    return n_col;
}
void mainImage(out vec4 fragColor, vec2 fragCoord)
{
vec2 uv = ( fragCoord - .5*iResolution.xy ) / iResolution.y;
    fragColor = vec4(0);
   
      float n_scl_min = min(iResolution.x, iResolution.y);
    vec2 o_trn = (fragCoord.xy-iResolution.xy*.5)/n_scl_min;
        o_trn*=mat2(cos(iTime),sin(iTime),-sin(iTime), cos(iTime));
    float nt = iTime*.1;
    vec3 o_col = vec3(
        1.-f_n(o_trn, 2., nt+0.03, n_scl_min),
        1.-f_n(o_trn, 3., nt+0.06, n_scl_min),
        1.-f_n(o_trn, 4., nt+0.09, n_scl_min)
    );
    vec3 p, r = iResolution, d = normalize(vec3((fragCoord-.5*r.xy)/r.y,0.5));  
    for(float i = 0., g = 0., e, s; i < 99.; ++i)
    {
        p = g * d;
        p.z -= 0.6;
        p+=o_col;
        s = 4.;
p.xz*=mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime));
        for(int j = 0; j++ < 13;)
        {
        p.xy*=mat2(cos(iTime*0.01),sin(iTime*0.01),-sin(iTime*0.01),cos(iTime*0.01));
            p = abs(p);
            p = p.x < p.y ? p.zxy : p.zyx;
            s *= e = 1.8 / min(dot(p, p), 1.3);
            p = p * e - vec3(15,3,2);
        }

        g += e = length(p.xz) / s;
        fragColor.rgb += color(iTime * 0.01 + i) * mix(r / r, H(log(s)), 0.7) * 0.08 * exp(-i * i * e);
    }
   
    fragColor = pow(fragColor, vec4(3));
    fragColor*= vec4( o_col*10., 1.);
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1
    fragColor*= vec4(happy_star(uv, anim) * vec3(0.55,0.5,0.55)*2.2, 1.0);
}
