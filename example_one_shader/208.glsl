float st=.025, maxdist=15.;
vec3 ldir=vec3(0.,-1.,-1.),col=vec3(0.);

mat2 rot(float a) {
	float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}

vec3 fractal(vec2 p) {
    vec2 pos=p;



    float d, ml=100.;
    vec2 mc=vec2(100.);
    p=abs(fract(p*.1)-.5);
    vec2 c=p;
    
    
    float v1, v2, v3;
	v1 = v2 = v3 = 0.0;
	
	float s = 0.0;
	
    for(int i=0;i<17;i++) {
        d=dot(p,p);
        p=abs(p+1.)-abs(p-1.)-p;
        
    	p=p*-1.5/clamp(d,0.5,1.)-c;
        mc=min(mc,abs(p));
        if (i>2) ml=min(ml*(1.+float(i)*.1),abs(p.y+cos(iTime*1.01)-.5));
    }
    mc=max(vec2(0.),1.-mc);
    mc=normalize(mc)*.8;
    ml=pow(max(0.,1.-ml),5.);
    return vec3(mc,d*1.4)*ml*(step(0.15*cos(iTime),fract(d*.1+1.5+pos.y*.02)))-ml*.1;
}

float map(vec2 p) {
 

    vec2 pos=p;
    float t=iTime;
    col+=fractal(p);
    vec2 p2=abs(0.5-fract(p*10.+40.)*cos(iTime));
	float h=0.;

    p=floor(p*2.+10.);
    float l=length(p2*p2*p2);
  

    return h;
}

vec3 normal(vec2 p, float td) {
	vec2 eps=vec2(0.,.001);
    return normalize(vec3(map(p+eps.yx)-map(p-eps.yx),2.*eps.y,map(p+eps.xy)-map(p-eps.xy)));
}

vec2 hit(vec3 p) {
    float h=map(p.xy);
        float h2=map(p.xz);
    return vec2(step(p.y,h*h2),h);
}

vec3 bsearch(vec3 from,vec3 dir,float td) {
    vec3 p;
    st*=-.5;
    td+=st;
    float h2=1.;
    for (int i=0;i<20;i++) {
        p=from+td*dir;
        float h=hit(p).x;
        if (abs(h-h2)>.001) {
            st*=-.5;
	        h2=h;
        }
        td+=st;
    }
	return p;
}

vec3 shade(vec3 p,vec3 dir,float h,float td) {

    ldir=normalize(ldir);
	col=vec3(0.);
    vec3 n=normal(p.xz,td);
	col*=2.25;
    float dif=max(0.,dot(ldir,-n));
    vec3 ref=reflect(ldir,dir);
    float spe=pow(max(0.,dot(ref,-n)),8.);
    return col+(dif*.5+.2+spe*vec3(1.,.8,.5))*.02;
}


vec3 march(vec3 from,vec3 dir) {
	vec3 p, col=vec3(0.);
vec3 r2 = normalize(vec3(dir.xy, 5.0 - dot(dir.xy, dir.xy) *10.5));

    float td=.5, k=0.;
    vec2 h;
    for (int i=0;i<100;i++) {
    	p=from+dir*td;
        h=hit(p*r2);
        if (h.x>.15||td>maxdist) break;
        td+=st;
    }
    if (h.x>.5) {
        p=bsearch(from,dir,td);
    	col=shade(p,dir,h.y,td);
    } else {
    }
	col=mix(col,2.*vec3(mod(gl_FragCoord.y,2.)*.1),pow(td/maxdist,3.));
    return col*vec3(0.5,.5,0.5)*1.;
}

mat3 lookat(vec3 dir,vec3 up) {
	dir=normalize(dir);vec3 rt=normalize(cross(dir,normalize(up)));
    return mat3(rt,cross(rt,dir),dir);
}

vec3 path(float t) {
	return vec3(1.,2.,t)*7.5;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv = (fragCoord-iResolution.xy*.5)/iResolution.y;
        vec2 uv2 = (fragCoord-iResolution.xy*.5)/iResolution.y;

    float v1, v2, v3;
	v1 = v2 = v3 = 0.0;
	vec3 r2 = normalize(vec3(uv.xy, 1.0 - dot(uv.xy, uv.xy) *3.5));
	float s = 0.0;
	for (int i = 0; i < 90; i++)
	{
		vec3 p = s * vec3(uv2, 0.0);
		
		p += vec3(.22, .3, s - 1.5 - sin(iTime * .13) * .1);
		for (int i = 0; i < 8; i++)	p = abs(p) / dot(p,p) - 0.659;
		v1 += dot(p,p) * .0015 * (1.8 + sin(length(uv.xy * 13.0) + .5  - iTime * .2));
		v2 += dot(p,p) * .0013 * (1.5 + sin(length(uv.xy * 14.5) + 1.2 - iTime * .3));
		v3 += length(p.xy*10.) * .0003;
		s  += .035;
	}
	
	float len = length(uv);
	v1 *= smoothstep(.7, .0, len);
	v2 *= smoothstep(.5, .0, len);
	v3 *= smoothstep(.9, .0, len);
	
	vec3 col2 = vec3( v3 * (1.5 + sin(iTime * .2) * .4),
					(v1 + v3) * .3,
					 v2) + smoothstep(0.2, .0, len) * .85 + smoothstep(.0, .6, v3) * .3;

	
	float t=iTime*0.10;
    vec3 from=path(t);
    vec3 dir=normalize(vec3(uv,1.0));
    vec3 adv=path(t+.1)-from;
    dir=lookat(adv+vec3(0.,-.5-(1.-(t*0.)),0.),vec3(adv.x*.1,1.,0.))*dir;
    vec3 col=march(from, dir)*2.5;
    fragColor = vec4(col,1.);
}