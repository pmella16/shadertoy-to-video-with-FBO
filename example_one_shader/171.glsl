#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(12,23,21))*23.5+.5)
#define resolution iResolution.xy
#define PI 3.14
#define time iTime
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    vec2 position = ( gl_FragCoord.xy / resolution.xy * 2.0 ) - vec2( 1.0 ); // normalise and translate to center
	position.x *= resolution.x / resolution.y; // scale x to make the axes proportional (y range is [-1, 1], x is depens on how wide the window is
	position.x+=0.2*cos(iTime*0.2);
		position.y+=0.2*sin(iTime*0.2);
	float d2 = distance( vec2( 0.0 ), position );
	

	
	float curl = 0.5;
	float m = 8.0, mm = 0.2, on = 0.5; // twiddle these
	float tstep = 0.02;
	float a = atan( position.y, position.x ) / PI / 2.0 + 0.5; // normalised angle
	a+= d2 * curl /* comment line from here to go for the true whirly effect */- time * tstep;
	float aa = step( mm * on, mod( a * m, mm ) );
	aa -= mod( a * m, mm * 4.0 );
	
	float b = atan( position.y, position.x ) / PI / 2.0 + 0.5; // normalised angle
	b-= d2* curl - time * tstep;
	float bb = step( mm * on, mod( b * m, mm ) );
	bb -= mod( b * m, mm * 4.0 );
	
	
	float c = min( aa, bb );
	c/=sin(time+aa*2.24)*d2;
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        p=g*d+c;
    
        a=30.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
            
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            p.y<p.x?p=p.zyx:p;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.0+.5*cos(iTime*.0))*3.,
                    120,
                    8.+cos(iTime*.00)*5.
                 );
         }
     
         g+=e=length(p.yx)/s;
    }
}