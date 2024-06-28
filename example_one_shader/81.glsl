//modified from https://www.shadertoy.com/view/ld23z3 fizzer

#define NUM_BUTTERFLIES 23

//----------------------------------------

vec3 a, b, c, mm, n;

// curve
vec3 mapD0(float t)
{
    return 0.25 + a*cos(t+mm)*(b+c*cos(t*7.0+n));
}
// curve derivative (velocity)
vec3 mapD1(float t)
{
    return -7.0*a*c*cos(t+mm)*sin(7.0*t+n) - a*sin(t+mm)*(b+c*cos(7.0*t+n));
}
// curve second derivative (acceleration)
vec3 mapD2(float t)
{
    return 14.0*a*c*sin(t+mm)*sin(7.0*t+n) - a*cos(t+mm)*(b+c*cos(7.0*t+n)) - 49.0*a*c*cos(t+mm)*cos(7.0*t+n);
}

//----------------------------------------

float curvature( float t )
{
    vec3 r1 = mapD1(t); // first derivative
    vec3 r2 = mapD2(t); // second derivative
    return length(cross(r1,r2))/pow(length(r1),3.0);
}

//-----------------------------------------

// unsigned squared distance between point and segment
vec2 usqdPointSegment( in vec3 p, in vec3 a, in vec3 b )
{
	vec3  pa = p - a;
	vec3  ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	vec3  q = pa - ba*h;
	return vec2( dot(q,q), h );
}


// unsigned squared distance between ray and segment
vec2 usqdLineSegment( vec3 a, vec3 b, vec3 o, vec3 d )
{
//#if 1
	vec3 oa = a-o;
    vec3 ob = b-o;
	vec3 va = oa-d*dot(oa,d);
    vec3 vb = ob-d*dot(ob,d);
    
    vec3 ba = va-vb;
    float h = clamp( dot(va,ba)/dot(ba,ba), 0.0, 1.0 );
    vec3  q = va - ba*h;
    return vec2( dot(q,q), h );
/*#else
    return usqdPointSegment( vec3(0.0), o+d*dot(a-o,d)-a, o+d*dot(b-o,d)-b );
#endif*/
}


float time;

// Noise functions from IQ.
float hash( float n ) { return fract(sin(n)*43758.5453123); }
float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0;
    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

float fbm2(vec2 p)
{
   float f = 0.0, x;
   for(int i = 1; i <= 9; ++i)
   {
      x = exp2(float(i));
      f += (noise(p * x) - 0.5) / x;
   }
   return f;
}


float sq(float x)
{
	return x*x;
}

vec2 rotate(float a,vec2 v)
{
	return vec2(cos(a)*v.x+sin(a)*v.y, cos(a)*v.y-sin(a)*v.x);
}

mat3 rotateXMat(float a)
{
	return mat3(1.0, 0.0, 0.0, 0.0, cos(a), -sin(a), 0.0, sin(a), cos(a));
}

mat3 rotateYMat(float a)
{
	return mat3(cos(a), 0.0, -sin(a), 0.0, 1.0, 0.0, sin(a), 0.0, cos(a));
}

vec3 wing0Node(int i) //upper wing pattern
{
	if(i<1)
		return vec3(-0.63,0.0,1.0);
	if(i<2)
		return vec3(-0.8,0.25,1.0);
	if(i<3)
		return vec3(-0.6,0.9,1.0);
	if(i<4)
		return vec3(-0.46,0.24,1.3);
	return vec3(-0.05,-0.05,1.0);
}

vec3 wing1Node(int i)
{
	if(i<1)
		return vec3(0.31,0.3,1.0);
	if(i<2)
		return vec3(-0.53,0.4,1.0);
	return vec3(0.53,-0.2,1.0);
}

vec3 wing0NodeTransformed(int i)
{
	return (wing0Node(i)+vec3(-0.57,-0.05,0.0))*vec3(vec2(0.2,0.7)*0.73,0.9);
}

vec3 wing1NodeTransformed(int i)
{
	return (wing1Node(i)+vec3(-0.7,-0.05,0.0))*vec3(vec2(1.2,1.0)*0.37,0.89);
}

vec3 wing0Tex(vec2 p)
{
	p=rotate(-0.79,p+vec2(0.35,0.0)); //upper wing angle
	
	float a=1e3;
	float b=1e3;
	
	int cn=0;
	float cnd=1e3;
	for(int i=0;i<4;i+=1)
	{
		float d=distance(p,wing0NodeTransformed(i).xy);
		if(d<cnd)
		{
			cnd=d;
			cn=i;
		}
	}
	
	float s=0.04+pow(max(0.0,-p.x*0.1),1.3)+pow(max(0.0,-p.y+1.0),1.3)*0.1; //edge
	
	s+=0.12*(1.0-smoothstep(0.0,0.14,distance(p.xy,vec2(-0.2,2.2))));
	
	float c=0.0;
	for(int j=0;j<4;j+=1)
	{
		if(j==cn)
			continue;
		
		vec3 n0=wing0NodeTransformed(cn);
		vec3 n1=wing0NodeTransformed(j);
		vec2 nd=n1.xy-n0.xy;
		float d=dot(p-(n0.xy+nd*0.5),normalize(nd))+s*n0.z;
		c+=sq(max(0.0,d));
	}
	
	float p0=sq(max(0.0,dot(p-vec2(-0.47,0.0),normalize(vec2(1.0,-1.0)))));
	
	c+=sq(max(0.0,(distance(p+vec2(0.6,1.42),vec2(0.0))-2.+s))) + p0 * 0.5+
		sq(max(0.0,dot(p-vec2(-0.6,-0.2),normalize(vec2(-0.3,-0.9)))));
	
	float c2=sq(max(0.0,(distance(p+vec2(0.6,1.55),vec2(0.0))-2.0))) + p0 +
		sq(max(0.0,dot(p-vec2(-0.6,-0.2),normalize(vec2(-0.19,-0.9)))-0.1));
	
	
 	float x=max(1.0-smoothstep(0.26,0.87,distance(p,vec2(-0.5,0.5))),
				1.0-smoothstep(0.02,0.025,length((p)-vec2(0.05,0.01))));
	
	return vec3(1.0-smoothstep(s-0.0975,s-0.015+0.116,sqrt(c)),1.0-smoothstep(0.01,0.106,sqrt(c2)-0.03), x*0.53 - p * 0.05);
}

vec3 wing1Tex(vec2 p)
{
	p=p+vec2(0.0,0.16);
	
	float a=1e3;
	float b=1e3;
	
	int cn=0;
	float cnd=1e3;
	for(int i=0;i<7;i+=1)
	{
		float d=distance(p,wing1NodeTransformed(i).xy);
		if(d<cnd)
		{
			cnd=d;
			cn=i;
		}
	}
	
	float s=0.04+pow(max(0.0,-p.y*0.4),1.3)+pow(max(0.0,-p.x-1.0),1.3)*0.1;
	
	float c=0.0;
	for(int j=0;j<7;j+=1)
	{
		if(j==cn)
			continue;
		
		vec3 n0=wing1NodeTransformed(cn);
		vec3 n1=wing1NodeTransformed(j);
		vec2 nd=n1.xy-n0.xy;
		float d=dot(p-(n0.xy+nd*0.5),normalize(nd))+s*n0.z;
		c+=sq(max(0.0,d));
	}
	
	float p0=sq(max(0.0,dot(p-vec2(-0.5,-0.4),normalize(vec2(1.0,-0.7)))));
	float p1=sq(max(0.0,dot(p-vec2(-0.53,0.3),normalize(-vec2(0.1,-0.9)))));
	
	c+=sq(max(0.0,(distance(p+vec2(0.52,-0.1),vec2(0.0))-0.5))) + p0 + p1;
	
	float c2=sq(max(0.0,(distance(p+vec2(0.5,-0.0),vec2(0.0))-0.53))) + p0 + p1;

	return vec3(1.0-smoothstep(s-0.025,s-0.005+0.0716,sqrt(c)),1.0-smoothstep(0.1,0.106,sqrt(c2)-0.03),c2*0.025);
}

vec4 wing(vec2 p)
{
	p+=fbm2(p*vec2(1.2,0.9))*0.15; //shape noise
	vec3 wc=mix(vec3(1.15,1.125,1.65)*0.63, vec3(0.79,0.97,1.47)*1.51, 
				clamp(pow(fbm2(rotate(-0.537, p)*vec2(100,300.0))*1.85 + 0.3, 3.), 0.0, 1.0));
	
	wc=pow(wc,vec3(1.9));
	
	vec3 c0=wing0Tex(p);
	vec3 c1=wing1Tex(p);

	vec3 col=vec3(0.0);
	
	col.rgb=mix(mix(vec3(0.0),c0.x*wc,c0.y),c1.x*wc,c1.y);
	col.rgb=mix(col.rgb,vec3(1.0),c0.z);
	col.rgb=mix(col.rgb,vec3(1.0),c1.z);
	
	return vec4(col,max(c0.y,c1.y));
}

vec3 traceButterflyWing(vec3 ro,vec3 rd,vec3 bo,vec3 bd,float flap)
{
	vec3 up=vec3(0.1,1.0,0.0);
	vec3 c=cross(bd,up);
	float flapangle=mix(radians(30.0),radians(170.0),flap);
	vec3 w=cos(flapangle)*c+sin(flapangle)*up;
	float t=-dot(ro,w)/dot(rd,w);
	vec3 s=cross(w,bd);
	vec3 rp=ro+rd*t;
	return vec3(dot(rp,s),dot(rp,bd),t);
}

vec4 traceButterfly(vec3 ro,vec3 rd,vec3 bo,vec3 bd,float flap)
{
	flap=pow(flap,0.55);
	bo.y-=flap*0.25;
	ro-=bo;
	vec3 up=vec3(0.0,1.0,0.0);
	vec3 c=cross(bd,up);
	
	vec3 w0=traceButterflyWing(ro,rd,bo,bd,flap);
	
	ro-=dot(ro,c)*2.0*c;
	rd-=dot(rd,c)*2.0*c;
	
	vec3 w1=traceButterflyWing(ro,rd,bo,bd,flap);

	if ( max(abs(w0.x),abs(w0.y)) > 2.0 && max(abs(w1.x),abs(w1.y)) > 2.0 )
		return vec4(0,0,0,1e4);
	
	vec4 c0=wing(w0.xy);
	vec4 c1=wing(w1.xy);
	
	bool u0=c0.a>0.0 && w0.z>0.0;
	bool u1=c1.a>0.0 && w1.z>0.0;
	
	if(!u0 && !u1)
		return vec4(0.0,0.0,0.0,1e4);
	else if(u0 && !u1)
		return vec4(c0.rgb,w0.z);
	else if(!u0 && u1)
		return vec4(c1.rgb,w1.z);
	else
		return mix(vec4(c0.rgb,w1.z),vec4(c1.rgb,w0.z),smoothstep(0.25 - w1.z, 0.25 + w1.z, 0.79));
}

vec3 butterflyPath(float t)
{
	return vec3(1.7*cos(t),cos(t*0.22)*1.1+sin(t*4.0)*0.1,sin(t*1.7))*4.0;
}

vec3 colormapping(vec2 uv)
{
    a = vec3(0.85,1.25,1.85) + 0.1*cos(9.0+0.7*iTime + vec3(0.5,1.0,2.0) );
    b = vec3(0.10,0.60,0.60) + 0.1*cos(5.0+0.5*iTime + vec3(2.5,5.0,3.0) );
    c = vec3(0.90,0.40,0.40) + 0.1*cos(1.0+0.3*iTime + vec3(6.0,2.0,7.2) );
    mm = cos( 0.11*iTime + vec3(0.0,2.0,5.0) );
    n = cos( 0.7*iTime + vec3(0.50,1.0,4.0) );

	vec2 p = (2.*uv-iResolution.xy)/iResolution.y;
 
    vec3 ro0 = vec3( 0.0, 0.0, 4.0 );
    vec3 rd0 = normalize( vec3(p.xy, -2.0) );

    vec3 col = vec3(0.0);
    
    vec3  gp = vec3(0.0);
    
    const int kNum = 9;
    
    float dt = 6.2831/float(kNum);
	float t = 0.0;
    vec3  xb = mapD0(t); t += dt;

    vec3 xc = mapD0(t);
    xc.y = max(-1.0,xc.y); // clip to ground
    vec2 ds = usqdLineSegment( xb, xc, ro0, rd0 );

    col = vec3(ds,0.0);
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 q=uv;
	uv=uv*2.0-vec2(1.0);
	uv.x*=iResolution.x/iResolution.y;
	time=iTime;
	mat3 m=rotateYMat(time*0.02)*rotateXMat(cos(time*0.12)*0.47);
	
	vec3 ro=m*vec3(0.0,0.0,7.0),rd=m*normalize(vec3(uv,-1.2));

    vec3 col = colormapping(fragCoord);
    
	col = col.grr*vec3(1.15, 0.87, 0.35)*0.2; //magic color
    
	float d=1e3;
	
	for(int i=0;i<NUM_BUTTERFLIES;i+=1)
	{
		float t=time+float(i)*10.2;
		vec3 bo=butterflyPath(t);
		vec4 b=traceButterfly(ro,rd,bo,vec3(normalize(butterflyPath(t+1e-2).xz-bo.xz),0.0).xzy,0.5+0.5*cos(t*9.0));
		c=mix(c,b.rgb,step(b.a,d));
		d=min(d,b.a);
	}
	
    vec3 dc = mix(c,c+0.05*d,0.01+0.2*dot(c,vec3(1.0/5.0)));
	fragColor.rgb=mix(c*0.5,dc,d*0.25);
    fragColor.rgb = mix(vec3(0.0), dc*(col*0.35 + 0.17), 3.-fragColor.r*vec3(0.01,0.11,0.21));

	// IQ's vignet.
	fragColor.rgb *= pow( 22.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.5 );
    fragColor.rgb = clamp(fragColor.rgb, 0.0, 1.0);
    //fragColor.rgb = dc;
}
