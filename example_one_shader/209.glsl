float glow=0., glow2=0., param=1.;
vec3 ifs_color, ro, color;

mat2 rot(float an) {return mat2(cos(an),-sin(an),sin(an),cos(an));}

// pentagonal fold from: https://www.shadertoy.com/view/wtsGzl
vec3 pentaFold(vec3 p) {
	vec3 nc = vec3(-.5, -.809017, .309017);
	for (int i = 0; i < 5; i++) {
		p.xy = abs(p.xy);
		p -= 2.*min(0., dot(p, nc))*nc;
	}
	return p - vec3(0, 0, 1.275);
}
#define Q(p) p *= r(myround(atan(p.x, p.y) * 4.) / 4.)
#define r(a) mat2(cos(a + asin(vec4(0,1,-1,0))))


vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}



float map(vec3 p) {

    float shell = length(ro-p)-.2;
    
    p.yz *= rot(iTime/3.);
    p.xz *= rot(iTime/2.);
    
    vec4 q = vec4(p, 1.0);    
    float mscale = 1.2;

    color = vec3(0.);
    float color_radius = 0.;
 
    float tt  = iTime/5.;
    for(float i = 0.; i < 12.; i++) {
Q(q.xy);

      ; 
        float ilength = length(q.xyz - vec3(0));
        
        q.xyz = pentaFold(q.xyz);
        q.yzx = pentaFold(q.yzx);
        
        q = mscale*q/clamp( pow(ilength,2.), .04, 1.) 
            - vec4(1.5,.1,.1,0);

       if      ( q.x*q.y > color_radius ) { color.x ++;}
       else if ( q.y*q.z > color_radius ) { color.y ++;}
       else if ( q.z*q.x > color_radius ) { color.z ++;}

    }

    ifs_color = vec3(color/q.w); 
 
    return max( length(q.xyz)/q.w, -shell );
}


vec3 normal(vec3 p) { 
	vec3 e = vec3(0.0,.01,0.0);

	float d1=map(p-e.yxx),d2=map(p+e.yxx);
	float d3=map(p-e.xyx),d4=map(p+e.xyx);
	float d5=map(p-e.xxy),d6=map(p+e.xxy);

	return normalize(vec3(d1-d2,d3-d4,d5-d6));
}



float march(vec3 ro, vec3 rd, float mx) {
    
    float t=0.,eps = 1e-4, distfac=5., hitThreshold = eps;
    for(int i = 0; i < 100; i++) {
        vec3 pos = ro + rd*t;
        float d = map(pos);      
              
        if (d < hitThreshold || t >= mx) break;
        t += d;
        hitThreshold = eps*(1.+t*distfac);
      
        glow2 += exp( -max(-d,0.)/10.);        
    }
    return t;
}

vec3 render(vec3 ro, vec3 rd) {
 

    float t = march(ro, rd, 4.);
    vec3 r2 = normalize(vec3(ro.xy, 1.0 - dot(ro.xy, ro.xy) *2.5));
    vec3 pos = ro+t*rd+r2;
    //vec3 nn = normal(pos);
        
    float  dist = length(pos-ro);
    
    float glowStr2 = exp( -dist*dist/30.);
            
         
    //glow2 += 10.*max(0.,dot(nn,vec3(ro+vec3(0,0,1))));
    glow2 *= glowStr2 ;
    
  
    
    vec3 color =  cos( log(ifs_color) + vec3(1,2,3));
    color*=color;

    color = color.x*vec3(0,0,1)
          + color.y*vec3(0,.5,1)
          + color.z*vec3(.4,.5,0)
    ;

    return   
        0.000001*pow(glow2,6.)*color;
        ;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p  = (2.*fragCoord.xy-iResolution.xy)/iResolution.y*2.;   
     vec3 r2 = normalize(vec3(p.xy, 1.0 - dot(p.xy, p.xy) *2.5));
    ro = vec3(0,0,-2.5);     
    vec3 rd = normalize( vec3(p*r2.xy,2.5 ))+r2 ;

    float T = 2.;
    float tt = 0.;
    

    
    
 
    vec3 col = clamp(render(ro, rd),0.01,100.);
   
    
    fragColor = vec4( col, 1.);
    
}

