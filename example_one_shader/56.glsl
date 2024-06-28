/*original https://www.shadertoy.com/view/mtyfDK https://www.shadertoy.com/view/4ffXWX https://www.shadertoy.com/view/DtVBRD /*original https://www.shadertoy.com/view/lslyRn,  original https://www.shadertoy.com/view/lsyXDK https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/DlycWR https://www.shadertoy.com/view/MfsXD2 and other*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(11,13,21))*.5+.5)
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850


void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
	//get coords and direction
	vec3 dir=rd;
	vec3 from=ro;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.2-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	fragColor = vec4(v*.01,1.);	
}
#define PI 3.1415926538
float min_dist(float d1,float d2,float d3,float d4){
    if(d1<d2 && d1<d3 && d1 < d4)
        return d1;
    else if(d2<d3 && d2<d4)
        return d2;
    else if(d3<d4)
        return d3;
    else 
        return d4;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


mat2 rot2D(float angle){
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c,-s,s,c);
}

vec3 palette(float x){

     vec3 a = vec3(0.258, 0.478, 1.008);
     vec3 b = vec3(-0.242, 0.398, 0.398);
     vec3 c = vec3(-0.204, 0.458, 0.530);
     vec3 d = vec3(0.358, 1.728, 1.225);

     return a + b *cos(5.8*(c*x+d));
     
     
}
     
float sdPyramid( in vec3 p, in float h )
{
    float m2 = h*h + 0.25;
    
    // symmetry
    p.xz = abs(p.xz);
    p.xz = (p.z>p.x) ? p.zx : p.xz;
    p.xz -= 0.5;
	
    // project into face plane (2D)
    vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
    float s = max(-q.x,0.0);
    float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
    float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
	float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
    float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
    // recover 3D and scale, and add sign
    return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));;
}


float makearrow(vec3 pos , float rotation){
    
    
    pos.xy *= rot2D(rotation);
    
    float box_dist_1 = sdBox(pos, vec3(0.1)); //cube SDF
    
    vec3 pos2 = pos;
    
    pos2.y -=0.1;//reposition the pyramid SDF
    
    //to scale, multiply pos within signed distance call, then divide result by same number to remove artifacts.
    float Pyramid_1 = sdPyramid(pos2*3., 1.)/3.; //tri SDF
    
    return min(box_dist_1,Pyramid_1);
}
float nice_happy_healthy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}

float map(vec3 pos){

    
    vec3 q = pos; //input point copy
    

    
    q.x += iTime /2.;
    
    //space repitition
    q.y = mod(q.y,1.5) -.75; 
    q.x = mod(q.x,3.) - 1.5; 
    q.z = mod(q.z,1.) -.5;
    
    //make arrows!
    q.x -=.05;
    q.y +=.025;
    float dist_arrow1 = makearrow(q,0.0);
    
    vec3 q2 = q;
    q2.x += .5;
    
    float dist_arrow2 = makearrow(q2,PI);
    
    vec3 q3 = q2;
    q3.x += .5;
    
    float dist_arrow3 = makearrow(q3,PI*3./2.);
    
    vec3 q4= q3;
    q4.x -= 1.5;
    
    float dist_arrow4 = makearrow(q4,PI/2.);
    
    return min_dist(dist_arrow1,dist_arrow2,dist_arrow3,dist_arrow4);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//get coords and direction
	vec2 uv=fragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,iTime*0.005);
	float time=iTime*speed+.25;

vec4 O= fragColor;
vec2 C=fragCoord;

	 vec2 m = (-50.*iTime - .5*iResolution.xy)/iResolution.y;
    vec2 mouse = (iMouse.xy * 2.0 - iResolution.xy)/iResolution.y;
    float FOV =150.0;

    //initialization
    vec3 rayorigin = vec3(0,0,-3.);
 
    vec3 raydirection = normalize(vec3(uv * FOV, 1));
    
    vec3 col = vec3(0);
    
    float dist_travelled = 0.;
    
    //raymarching
    
    int i;
    for(i =0; i <150 ;++i ){
    
        vec3 pos = rayorigin + raydirection * dist_travelled * 0.45; //play with this variable and the one below it's fun
    
        pos.xy *= rot2D(dist_travelled*0.102 ) ; //second variable to edit
           pos.xy+=m*5.;
          pos.zy+=m*5.;
        float dist = map(pos);
        
        dist_travelled += dist; //march the ray
        
        if (dist <.001 ) {
        break;
       
        }
        if( dist_travelled > 500.){
         fragColor = vec4(0.1,.1,.1,1);
         return;
         //break;
            
        }
    }
    
            
    col = vec3(dist_travelled *.002,dist_travelled *.03,dist_travelled *.004);
    
    col = palette(dist_travelled *.1 + float(i)*.0005 + iTime*.003);
    
    
O=vec4(0.);
 vec3 natur,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
	  for(float i=0.,a,s,e,mn=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(mn*.1),sin(.8))*1./e/8e3
    )
    {
       natur=mn*d;
    
        natur.z+=iTime*0.0;
        a=20.;
        natur=mod(natur-a,a*2.)-a;
        s=5.;
        for(int i=0;i++<8;){
            natur=.3-abs(natur);
           
            natur.x<natur.z?natur=natur.zyx:natur;
            natur.z<natur.y?natur=natur.xzy:natur;
            natur.y<natur.x?natur=natur.zyx:natur;
           
            s*=e=1.4+sin(iTime*.234)*.1;
            natur=abs(natur)*e-
                vec3(
                    2.+cos(iTime*.23+.1*cos(iTime*.53))*1.,
                    70,
                    3.+cos(iTime*.25)*5.
                 )*col;
         }
       
         mn+=e=length(natur.yx)/s;
    }
	float a1=.5+iMouse.x/iResolution.x*2.;
	float a2=.8+iMouse.y/iResolution.y*2.;
	mat2 rot1=mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime));
	mat2 rot2=mat2(cos(iTime),sin(iTime),-sin(iTime),cos(iTime));
	dir.xz*=rot1;
	dir.xy*=rot2;
     uv *= 2.0 * ( cos(iTime * 2.0) -2.5);
    
    // anim between 0.9 - 1.1
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;    
	vec3 from=vec3(1.,.5,0.5)+O.xyz+col;
	from+=vec3(time*2.,time,-2.);
	from.xz*=rot1;
	from.xy*=rot2;
	
	mainVR(fragColor, fragCoord, from, dir);	
    fragColor*= vec4(nice_happy_healthy_star(uv,anim) * vec3(0.55,0.5,0.55)*1.5, 1.0);
}
