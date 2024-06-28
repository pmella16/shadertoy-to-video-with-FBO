//forked from https://www.shadertoy.com/view/llfSzH

void mainImage( out vec4 f, vec2 u )
{
    float t = iTime*.3;
    float s = 1.;
    //u.x+=100.;
    vec3 r = vec3(cos(t*s*1.)*3. + s*.5, s*.5,sin(t*s*1.)) + s*.5,
         R = iResolution ;
    
    u-= R.xy*.5;
    float d = length(u/R.y)*2.;
    float a = sin(t*.1);
    u*= mat2(d,a,-a,d);
    u+=R.xy*.5;
    
    for( float i = .7; i > .1 ; i-=.009 ) {
        r += vec3( (u+u-R.xy)/R.y, 1) *.5
             * ( f.a = length( mod(r,s) - (s*.5) )+sin(mod(r.z*r.x*r.y,s))*.2 - .3 ) ;
        float aa = atan(r.y,r.z);
        float dd = length(r.zy);
        aa += r.x*.01;
        
        r.y = sin(aa)*dd;
        r.z = cos(aa)*dd;
        f.bgr=abs(sin(vec3(i)));
        if( f.a < .001 ) break ;
    }
    f.rgb = sin(t+(f.rgb+vec3(0.0,.33,.66))*6.)*.5+.5;

}