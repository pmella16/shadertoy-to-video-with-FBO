#define rot(a) mat2(cos(a+vec4(0,11,33,0)))

//formula for creating colors;
#define H(h)  (  cos( h*2. + 7.*vec3(1,2,3) )*.7 + .4 )

//formula for mapping scale factor 
#define M(c)  log(1.+c)

#define R iResolution

// pentagonal fold from: https://www.shadertoy.com/view/wtsGzl
vec3 pentaFold(vec3 p) {
	vec3 nc = vec3(-.5, -.809017, .309017);
	for (int i = 0; i < 3; i++) {
		p.xy = abs(p.xy);
		p -= 2.*min(0., dot(p, nc))*nc;
	}
	return p - vec3(0, 0, 1.275);
}

void mainImage( out vec4 O, vec2 U) {
  
    O = vec4(0); 
    vec3 c=vec3(0);  
    float sc,dotp,totdist=0., t=iTime; 
           
#define T iTime*.1
#define path(t) (vec3( cos(t),sin(t*2.),t)  )

    vec2 p  = (U+U-R.xy)/R.y;    

    // path stuff by diatribes
    // ro,rd, added la stuff
    vec3 ro = path(T);
    
    vec3 la = path(T+1.); // look ahead/where you're going
         
    vec3 laz = normalize(la - ro),
         lax = normalize(cross(laz, vec3(0.,1., 0))),
         lay = cross(lax, laz),
         rd = mat3(lax, lay, laz) * normalize( vec3(p, 1.5) ) ;
    
    vec4 rdx = normalize( vec4( rd,2.) );
    
    for (float i=0.; i<100.; i++) {
        
        vec4 p = vec4( rdx*totdist ) * 60.;
        
        p += vec4(ro,-1.-mod(iTime*3.,10.));

        float dd = 1., cc2=0.,dist;
        p.z = mod(p.z,2.*dd)-dd;  
        

        sc = 1.;  
       
        for (float j=0.; j<7.; j++) {
        
            p = abs( p )*.6;
            
            p.xy *= rot(.1+iTime/5.);
            p.xyz = pentaFold(p.xyz);
            
            dotp = clamp(1./dot(p,p),.01,5.);
            sc *= dotp;
            
            p *= dotp - vec4(pentaFold(p.xyw),.2) ;
            
            
            dist = ( length(p.xw) - .2 )/(1.+sc);
            
            if ( dist < -.1) cc2 += 1.;
            
        }
 
        dist = clamp( abs( length(p.xw) -.01)/(1.+sc),1e-4,.5) ;
        
        float stepsize = dist/5. + 1e-4  ;
        totdist += stepsize;    

        //if (i>10.)
        c += .06*H(log(sc))*exp(-totdist)  - .06*cc2*exp(-totdist*5.) ;
        ;
            

    }
    
    c = clamp(c,-100.,100.);

    c = 1. - exp(-c*c);
    
    c.b *= 1.5;

    O = ( vec4(c,0) );
               
}  

