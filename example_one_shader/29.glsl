#define V vec2
#define K vec4
#define L log
void mainImage(out K F, in V C)
{
	V r=iResolution.xy,z=C/r*2.-1.;z.x*=(r.x/r.y);
	float i,I=3000.,b,l,t=iTime;
	for(i=0.;i<I;i++) {
		z=V(z.x*z.x-z.y*z.y,z.x*z.y+z.y*z.x)+V(-.7454,.1130)-(sin(t)*.0023+(cos(t)*.01+.01));
		if(length(z)>2.) {
			i-=L(L(dot(z, z)))/L(2.);
			break;
		}
	}
	b=-.0015,l=(1./L((b-1.)/b))*L((b-i/I)/b);
	F=K((i==I)?vec3(0.):cos(6.28318*(l+vec3(0.,.33,.66)))*.5+.5,1.);
}