#ifdef GL_ES
precision mediump float;
#endif

// copy from https://www.shadertoy.com/view/4sc3z2

#define MOD3 vec3(.1031,.11369,.13787)

vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}
float perlin_noise(vec3 p)
{
    vec3 pi = floor(p);
    vec3 pf = p - pi;
    
    vec3 w = pf * pf * (3.0 - 2.0 * pf);
    
    return 	mix(
        		mix(
                	mix(dot(pf - vec3(0, 0, 0), hash33(pi + vec3(0, 0, 0))), 
                        dot(pf - vec3(1, 0, 0), hash33(pi + vec3(1, 0, 0))),
                       	w.x),
                	mix(dot(pf - vec3(0, 0, 1), hash33(pi + vec3(0, 0, 1))), 
                        dot(pf - vec3(1, 0, 1), hash33(pi + vec3(1, 0, 1))),
                       	w.x),
                	w.z),
        		mix(
                    mix(dot(pf - vec3(0, 1, 0), hash33(pi + vec3(0, 1, 0))), 
                        dot(pf - vec3(1, 1, 0), hash33(pi + vec3(1, 1, 0))),
                       	w.x),
                   	mix(dot(pf - vec3(0, 1, 1), hash33(pi + vec3(0, 1, 1))), 
                        dot(pf - vec3(1, 1, 1), hash33(pi + vec3(1, 1, 1))),
                       	w.x),
                	w.z),
    			w.y);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/lt2GDc
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

float chess(vec2 v){
    vec2 i = floor(v);
    return mod(i.x+i.y, 2.);
}

mat2 rotate(float angle){
    angle = -radians(angle);
    return mat2(cos(angle), -sin(angle)
               ,sin(angle), cos(angle));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 st = fragCoord.xy/iResolution.xy;
    st.x *= iResolution.x/iResolution.y;
    
    st+=1.;
    st*=10.;
    
    float k = 1.;
    for(float i = 1.; i<=8.;i++){
        vec2 offset = vec2(0.);
        offset.x = 0.6*sin(0.32456*iTime*i)*chess(i*st*rotate(i*23.34576+iTime)/10.);
        offset.y = 0.6*sin(0.5245677*iTime*i)*chess(i*st*rotate(i*17.23467+iTime)/10.);
        st+= offset;
    }
    vec3 color = pal(0.5*perlin_noise(vec3(st, 0.5*iTime))+0.5, vec3(0.5),vec3(0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25));
    
    fragColor = vec4(color,1.0);
}