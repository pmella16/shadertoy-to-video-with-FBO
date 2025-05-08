float sc,dd=9.;
vec3 ifs_color, ro, color;

float T=0.;  //change colors in synch with movement

mat2 rot(float an) {return mat2(cos(an),-sin(an),sin(an),cos(an));}


vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}


float map(vec3 p) {

    //p = mod(p - dd, 2.*dd) - dd;
 
    float shell = length(p-ro)-.2;
    
    vec3 id = myround(p/dd);
    p -= dd*id;

    p = abs(p) - 1.7;
#define S(p) p.xy = p.x<p.y? p.yx : p.xy
    S(p.xz); S(p.yz); S(p.xy);

    sc = 1.;
  	for (float i = 0.0; i < 4.; i++) {
  		float dotp = 1.4 / clamp(dot(p,p), .005, .9);
  		p = abs(p) * dotp - vec3(1.5,0,2);
  		sc *= dotp;
        
        if ( p.x*p.y < 0.) ifs_color.x += cos(T/2.);
        if ( p.y*p.z < 0.) ifs_color.y += cos(T/2.3+1.);
        if ( p.z*p.x < 0.) ifs_color.z += cos(T/2.7+2.);
        
  	}
    
    return max(-shell, length(p.xy) / sc - .02)  ;
}

float march(vec3 ro, vec3 rd, float mx) {
    
    float t=0.,eps = 1e-3, distfac=2., hitThreshold = eps;
    for(float i = 0.; i < 80.; i++) {
        vec3 pos = ro + rd*t;
        float d = map(pos);      
              
        if (d < hitThreshold || t >= mx) { color*=color; break;}
        
        t += d;
        hitThreshold = eps*(1.+t*distfac);
  
        color += .07*ifs_color*cos(ifs_color*ifs_color/64.)*exp(-d*d/20.-t/3.); 
              
    }
    return t;
}

void render(vec3 ro, vec3 rd) {
    float t = march(ro, rd, 20.);
}

float random(vec2 p) {
    //a random modification of the one and only random() func
    return fract( sin( dot( p, vec2(12., 90.)))* 1e4 );
}
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p  = (2.*fragCoord.xy-iResolution.xy)/iResolution.y*2.;    

    vec3 rd =  normalize( vec3(p, 1.9) ) ;
  
    //slow down with mouse
    float t2 = iMouse.z>0.? iMouse.x/iResolution.x*iTime*8. :iTime*10.;
    
// use the repeat interval: dd in the path so we synch up with holes  
    float tt = mod(t2,dd*2.);
  
    float ct = floor(t2/dd/2.);
    
    T = ct*2.;
    
    float rnd = random(vec2(ct)); //need a random number that stays constant for a period of time
    rnd = mod(rnd*6.,6.)-3.;
    
    float rnd2 = random(vec2(rnd));
    rnd2 = mod(rnd*6.,6.)-3.;
    
    float dir = sign(rnd);
    rnd = abs(rnd);
    
    float dir2 = sign(rnd2);
    rnd2 = abs(rnd2);
    
    int idx1 = int(mod(abs(rnd), 6.0));       // valor entre 0 y 5
    int idx2 = int(mod(abs(rnd2), 6.0));      // valor entre 0 y 5

    ro[idx1] += dir*(tt - dd);
    ro[idx2] += dir*min(tt, dd);

    render(ro, rd);
    
    color = 1. - exp(-color*color);
    
    fragColor = vec4( color, 1.);
    
}

