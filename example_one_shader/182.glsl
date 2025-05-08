

#ifdef GL_ES
precision mediump float;
#endif

// glslsandbox uniforms
uniform float time;
uniform vec2 resolution;

// shadertoy emulation
#define  time iTime
#define  resolution iResolution.xy


// Emulate a black texture
#define texture(s, uv) vec4(0.0)

// --------[ Original ShaderToy begins here ]---------- //
/**
    Fractal Remix | Box Fractal
	orignal @gaz https://twigl.app/?ch=-MFu0X8wYxqxuhK4Cgd9&dm=graphics 
 	I translated you're comments...

	time based animation changes
	rotating though x/z vectors

	help/motion
	thebookofshaders.com/examples/

*/
// not tied to uniform names
#define R           iResolution
#define M           iMouse
#define T           iTime
#define S           smoothstep
#define PI          3.1415926
#define PI2         6.2831853
#define d5          .5773
#define MINDIST     .0001
#define MAXDIST     100.

#define r2(a) mat2(cos(a),sin(a),-sin(a),cos(a))

//thebookofshaders timing functions
float easeInOutExpo(float t) {
    if (t == 0.0 || t == 1.0) return t;
    if ((t *= 2.0) < 1.0) {
        return 0.5 * pow(2.0, 10.0 * (t - 1.0));
    } else {
        return 0.5 * (-pow(2.0, -10.0 * (t - 1.0)) + 2.0);
    }
}

float linearstep(float begin, float end, float t) {
    return clamp((t - begin) / (end - begin), 0.0, 1.0);
}

float circle(vec2 pt, vec2 center, float r, float lw) {
  float len = length(pt - center),
        hlw = lw / 2.,
        edge = .11;
  return smoothstep(r-hlw-edge,r-hlw, len)-smoothstep(r+hlw,r+hlw+edge, len);
}

vec3 getMouse(vec3 p) {
	
    float x = M.xy == vec2(0) ? -.6 : -(M.y/R.y * 1. - .5) * PI;
    float y = M.xy == vec2(0) ? -1. :  (M.x/R.x * 1. - .5) * PI;
    
 
    return p;
}
float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.)-.05;
}
float orbit = .01,
      txx   = .01025,
      txa   = .005,
      glw   = .0;
float zoom = 1.5; 
mat2 rotA = mat2(0.), rotB = mat2(0.), spin = mat2(0.);

float Scale;
vec3 map(vec3 p,float mgl){
  	
   
    vec3 res = vec3(100.,-1.,0.);

    float b = sdBox(p,vec3(3.5));
    if(b<res.x) res=vec3(b,2.,orbit);
   
    p=abs(p)-3.5;

    if(p.x<p.z)p.xz=p.zx;
    if(p.y<p.z)p.yz=p.zy;
    if(p.x>p.y)p.xy=p.yx;

  
	float rate=+15.5;
	
	// This number has good sensitivity, so I think it is fine.
	float mr2=0.105;
	// I think the standard here is about 0.3 to 1.8.
	float off=0.37;	// This number is the initial magnification. 
    	float s=.35;
    // Fractal folding is IFS of magnification. After changing the scale, move to make changes.
    // The initial coordinates are used for the movement amount. By the way, 
    //the variable of off is used to adjust the degree of this movement amount.
    vec3  p0 = p;

    // You can play around with the number of iterations.
    for (float i=0.; i<10.; i++){

    // Please do not tamper with this function.
    p=5.5-abs(p-1.);

    // You can play around with all the constants here.
    float g=clamp(mr2*max(1.25/dot(p,p),.8),0.,1.);

    // Please do not tamper with these two lines.
    p=p*rate*g+p0*off;
    s=s*abs(rate)*g+off;
        
    // Rotate the coordinates a little. It's a bit peaky, so try it little by little.
    // You can do various things without rotating it forcibly. I think it's better to use it with an accent。
    
	  p.xy*=r2(iTime*0.11);
    p.yz*=r2(iTime*0.11);
    }

    // This number is log2() the final scale factor. It is a parameter for coloring.
    // There is no problem with log() separately. I'm using it with a glue like log2() because it will be multiplied like twice.
    Scale = log2(s);
	orbit=log2(s*.0091553);
    // Three final output distance functions are prepared. Please use it by replacing it.
    // The last 0.03 is the thickness of the line, so you can change it
    //return length(p.xy)/s-.003;
    
    float d= length(p.xz)/s-.025;
    d= max(sdBox(p,vec3(5.))/s-.01,-d);
    if(d<res.x) res=vec3(d,1.,orbit);
    //glw += .00025/(.025+d*d);//@evvvil 
    glw += .15/(.3+b*b);//@evvvil
    return res;
    //return length(cross(p,normalize(vec3(1))))/s-.003;
}

// distance estimator
vec3 marcher(vec3 ro, vec3 rd, int maxsteps) {
    float d = 0.,
          m = -1.,
          o = 0.;
    int i = 0;
	
    for(int ii = 0; ii<256; ii++) {
        vec3 p = ro + rd * d;
        	
        vec3 t = map(p,1.);
        if(t.x<MINDIST||d>MAXDIST) break;
        d += t.x*.5;
        m  = t.y;
        o  = t.z;
        ++i;
    }
    float de = float(i)/float(maxsteps);
    return vec3(d,m,o);
}

// Tetrahedron technique @iq
// https://www.iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 getNormal(vec3 p, float t){

    float e = (MINDIST + .0001) *t;
    vec2 h = vec2(1.,-1.)*.5773;
    return normalize( h.xyy*map( p + h.xyy*e ,0.).x + 
                      h.yyx*map( p + h.yyx*e ,0.).x + 
                      h.yxy*map( p + h.yxy*e ,0.).x + 
                      h.xxx*map( p + h.xxx*e ,0.).x );
}

//camera setup
vec3 camera(vec3 lp, vec3 ro, vec2 uv) {
    vec3 f=normalize(lp-ro),//camera forward
         r=normalize(cross(vec3(0,1,0),f)),//camera right
         u=normalize(cross(f,r)),//camera up
         c=ro+f*.95,//zoom
         i=c+uv.x*r+uv.y*u,//screen coords
        rd=i-ro;//ray direction
    return rd;
}
//vec3(.45,1.5,1.25)?
vec3 gethue(float a){return  .5 + .45*cos((4.5*a) - vec3(.25,1.5,2.15));}

vec3 getColor(float m, float o){
    vec3 h = gethue(o*.25);
    // use orbit number to band coloring
    if(o>4.     && o<5.1)   h=vec3(1.);
    if(o>6.     && o<6.1)   h=vec3(1.);
    if(o>7.15   && o<7.65)  h=vec3(1.);
    if(o>8.     && o<8.6)   h=vec3(1.);
    if(o>.0     && o<.5)    h=vec3(1.);
    if(o>-.1    && o<-.05)  h=vec3(1.);
    if(o>-2.2   && o<-1.75) h=vec3(1.);
    if(o>-3.8   && o<-2.75) h=vec3(1.);
    if(o>-6.    && o<-5.75) h=vec3(1.);
    if(o>-9.    && o<-8.75) h=vec3(1.);
    if(o>-8.5   && o<-7.75) h=vec3(1.);
    return h;
}

float ao(float j, vec3 p, vec3 n) {
    return clamp(map(p + n*j,0.).x/j, 0.,1.);   
}

void mainImage( out vec4 O, in vec2 F ){
    // Precalculations to speed map and my
    // timing functions - this is new so be
    // kind. using Book of shader examples.
    // 
    float tm = mod(T*2.5, 32.);
    // move x steps in rotation
    float v1 = linearstep(0.0, 1.0, tm);
    float a1 = linearstep(2.0, 3.0, tm);
    
	float v2 = linearstep(4.0, 5.0, tm);
    float a2 = linearstep(6.0, 7.0, tm);
    
    float v3 = linearstep(8.0, 9.0, tm);
    float a3 = linearstep(10.0, 11.0, tm);
    
    float v4 = linearstep(12.0, 13.0, tm);
    float a4 = linearstep(14.0, 15.0, tm);
    
    float v5 = linearstep(16.0, 17.0, tm);
    float a5 = linearstep(18.0, 19.0, tm);
    
	float v6 = linearstep(20.0, 21.0, tm);
    float a6 = linearstep(22.0, 23.0, tm);
    
    float v7 = linearstep(24.0, 25.0, tm);
    float a7 = linearstep(26.0, 27.0, tm);
    
    float v8 = linearstep(28.0, 29.0, tm);
    float a8 = linearstep(30.0, 31.0, tm);
    
    float degs = mix(0., 360./8.,v1+v2+v3+v4+v5+v6+v7+v8);
    float degx = mix(0., 360./8.,a1+a2+a3+a4+a5+a6+a7+a8);
    
    // mix downs
    txa = degs;
    txx = degx;
    
    rotB = r2(degs*PI/180.);
    rotA = r2(degx*PI/180.);
    
    spin = r2(-T*.06);

   
    vec2 uv = (2.*F.xy-R.xy)/max(R.x,R.y);
    vec3 C = vec3(0.);
	vec3 FC = gethue(13.3);
    vec3 lp = vec3(0.,0.,0.),
         ro = vec3(0.,0.,-55.);
         ro = getMouse(ro);

    vec3 rd = camera(lp, ro, uv);
    vec3 t = marcher(ro,rd, 256);
    
    float m = t.y;
    float o = t.z;
    
    if(t.x<MAXDIST) {
        vec3 p = ro + rd * t.x,
        
             n = getNormal(p, t.x);
        vec3 light1 = vec3(0,25.,-50.0),
             light2 = vec3(0,25.,30.0);
        float dif  = clamp(dot(n,normalize(light1-p)),0. , 1.);
              dif += clamp(dot(n,normalize(light2-p)),0. , 1.);
        vec3 h = (m==1.) ? getColor(m,o) : FC;      
        C += dif* (ao (0.5,p,n) + ao(.05,p,n))*h*vec3(2.);
    } else {
        C += FC;
    }
    
    vec2 dv = uv+vec2(T*.041,-T*.023);
    float cir = circle(fract(dv*12.),vec2(0.5),.34,.03);
    cir += circle(fract(dv*12.),vec2(0.5),.45,.06);
    vec3 cirx = mix(FC,gethue(14.3),cir);
    float dt = smoothstep(.2,.65,distance(uv,vec2(0.))*.75);
    cirx = mix(FC,cirx,dt*.25);
   
    C = mix( C, cirx, 1.-exp(-.000125*t.x*t.x*t.x));

  
    C += vec3(glw*1.25)*vec3(5.,5.2,5.);
    O = vec4(pow(C, vec3(5.4545)),1.0);
}

