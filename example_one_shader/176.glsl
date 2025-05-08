
#define time iTime
#define resolution iResolution.xy

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

// Perlin simplex noise
float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
			-0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
	+ i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.wxw) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yx * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}



#define iterations 12
#define formuparam2 0.679
 
#define volsteps 8
#define stepsize 0.190
 
#define zoom 0.900
#define tile   0.850
#define speed2  0.10
 
#define brightness 0.006
#define darkmatter 0.14000
#define distfading 0.60
#define saturation 0.800


#define transverseSpeed zoom*2.0
#define cloud (0.11*sin(time))

 #define time iTime
 #define resolution iResolution.xy
float triangle(float x, float a)
{
 
 
float output2 = 2.0*abs(  2.0*  ( (x/a) - floor( (x/a) + 0.5) ) ) - 1.0;
return output2;
}
 

float field(in vec3 p) {
	
	float strength = 7. + .03 * log(1.e-6 + fract(sin(time) * 4373.11));
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	

	for (int i = 0; i < 6; ++i) {
		float mag = 1.-dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.8 + 0.1*sin(time*0.7 + 2.0), -1.1+0.3*cos(time*0.3));
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
		tw += w;
		prev = mag;
		//if ( fract(time*100.0*sin(time*0.1)) > 0.499 ) break;
	}
	return max(0., 5. * accum / tw - .7);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 position = abs(( fragCoord.xy / resolution.xy ) * 2.0 - 1.0);
    vec2 uv = fragCoord/iResolution.xy-0.5;
    
     	vec2 uv2 = uv*1.0;//2. * gl_FragCoord.xy / resolution.xy - 1.;
	vec2 uvs = uv2;// * resolution.xy / max(resolution.x, resolution.y);
	uv *= 50.0/1.1;

	
	float time2 = time;
               
        float speed = speed2;
        speed = 0.005 * (time2*0.02 + 3.1415926/4.0);
          
	//speed = 0.0;

	
    	float formuparam = formuparam2;

	
  
	
	for ( float j = 0.0; j < 1.0; j += 1.0 ) {
		uv /= (j-dot(uv,uv))*sin(time*0.1+0.5*sin((time+j)*0.05));
		uv *= 1.0-length(uv)*0.3*tan(j+1.0);
		if ( sin(time*0.001)*(j+1.0) < 0.5 ) break;
	}
	
	uv *= 1.0 - dot( gl_FragCoord.xy / resolution.xy , gl_FragCoord.xy / resolution.xy  )*0.3;
	uv /= 1.0 - length(uv);
		
	//mouse rotation
	float a_xz = iTime*0.01;
	float a_yz = -iTime*0.01;
	float a_xy = 0.9 + time*0.1;
	
	
	mat2 rot_xz = mat2(cos(a_xz),sin(a_xz),-sin(a_xz),cos(a_xz));
	
	mat2 rot_yz = mat2(cos(a_yz),sin(a_yz),-sin(a_yz),cos(a_yz));
		
	mat2 rot_xy = mat2(cos(a_xy),sin(a_xy),-sin(a_xy),cos(a_xy));
	

float t = time * 1.1;
        vec2 m = (position) + vec2(t, t);
	float size = 10.0;
	float b = max(m.x, m.y) * size;
	float n = floor(b) / (size * 0.5);
	vec3 c = vec3(snoise(vec2(n, 0.5)),
	              snoise(vec2(n, 0.0)),
	              snoise(vec2(n, 1.0))) * 0.5 + 0.5;


	float a = step(mod(b, 1.0), 0.80);
	c = c * a;
	float v2 =1.0;
	
	vec3 dir=vec3(uv*zoom,1.);
 
	vec3 from=vec3(0.0, 0.0,0.0)*c;
 
                               
        from.x -= 5.0*(0.5);
        from.y -= 5.0*(0.5);
               
               
	vec3 forward = vec3(0.,0.,1.);
               
	
	from.x += transverseSpeed*(1.0)*cos(0.01*time) + 0.001*time;
		from.y += transverseSpeed*(1.0)*sin(0.01*time) +0.001*time;
	
	from.z += 0.003*time;
	
	
	dir.xy*=rot_xy;
	forward.xy *= rot_xy;

	dir.xz*=rot_xz;
	forward.xz *= rot_xz;
		
	
	dir.yz*= rot_yz;
	forward.yz *= rot_yz;
	 

	
	from.xy*=-rot_xy*c.xy;
	from.xz*=rot_xz;
	from.yz*= rot_yz;
	 
	
	//zoom
	float zooom = (time2-3311.)*speed;
	from += forward* zooom;
	float sampleShift = mod( zooom, stepsize );
	 
	float zoffset = -sampleShift;
	sampleShift /= stepsize; // make from 0 to 1


	
	//volumetric rendering
	float s=0.24;
	float s3 = s + stepsize/2.0;
	vec3 v=vec3(0.);
	float t3 = 0.0;
	
	
	vec3 backCol2 = vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p2=from+(s+zoffset)*dir;// + vec3(0.,0.,zoffset);
		vec3 p3=from+(s3+zoffset)*dir;// + vec3(0.,0.,zoffset);
		
		p2 = abs(vec3(tile)-mod(p2,vec3(tile*2.))); // tiling fold
		p3 = abs(vec3(tile)-mod(p3,vec3(tile*2.))); // tiling fold
		
		#ifdef cloud
		t3 = field(p3);
		#endif
		
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) {
			p2=abs(p2)/dot(p2,p2)-formuparam; // the magic formula
			//p=abs(p)/max(dot(p,p),0.005)-formuparam; // another interesting way to reduce noise
			float D = abs(length(p2)-pa); // absolute sum of average change
			a += i > 7 ? min( 12., D) : D;
			pa=length(p2);
		}
		
		
		//float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		//if (r>3) fade*=1.-dm; // dark matter, don't render near
		// brightens stuff up a bit
		float s1 = s+zoffset;
		// need closed form expression for this, now that we shift samples
		float fade = pow(distfading,max(0.,float(r)-sampleShift));
		
		
		//t3 += fade;
		
		v+=fade;
	       		//backCol2 -= fade;

		// fade out samples as they approach the camera
		if( r == 0 )
			fade *= (1.2 - (sampleShift));
		// fade in samples as they approach from the distance
		if( r == volsteps-1 )
			fade *= sampleShift;
		v+=vec3(s1,s1*s1,s1*s1*s1*s1)*a*brightness*fade*0.3; // coloring based on distance
		
		backCol2 += mix(1.4, 0.5, v2) * vec3(1.8 * t3 * t3 * t3, 5.4 * t3 * t3, t3) * fade*0.2;

		
		s+=stepsize;
		s3 += stepsize;
		
		
		
		}
		       
	v=mix(vec3(length(v)),v,saturation); //color adjust
	 
	
	

	vec4 forCol2 = vec4(v*.03,1.);
	
	#ifdef cloud
	backCol2 *= cloud;
	#endif
	
	backCol2.b *= 1.8;

	backCol2.r *= 0.05;
	
	backCol2.b = 0.5*mix(backCol2.g, backCol2.b, 0.8);
	backCol2.g = 0.0;

	backCol2.bg = mix(backCol2.gb, backCol2.bg, 0.5*(cos(time*0.01) + 1.0));
	
	fragColor = clamp(forCol2 + vec4(backCol2, 1.0), 0.0, 0.5 ) * 2.0;
	
	fragColor = vec4(v*0.03, 1);

}