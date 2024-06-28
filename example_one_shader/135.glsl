float sdOrientedVesica( vec2 p, vec2 a, vec2 b, float w ){
    float r = 0.5*length(b-a);
    float d = 0.5*(r*r-w*w)/w;
    vec2 v = (b-a)/r;
    vec2 c = (b+a)*0.5;
    vec2 q = 0.5*abs(mat2(v.y,v.x,-v.x,v.y)*(p-c));
    vec3 h = (r*q.x<d*(q.y-r)) ? vec3(0.0,r,0.0) : vec3(-d,0.0,d+w);
    return length( q-h.xy) - h.z;
}
vec2 polar(vec2 uv){
    return vec2(distance(uv.xy, vec2(0,0)), atan(uv.y,uv.x));
} 
vec2 cartesian(vec2 polar){
    return vec2(polar.x*cos(polar.y), polar.x*sin(polar.y));
}
vec3 palette1( float t ) {

    vec3 a = vec3(0.718, 0.768, 0.548);
    vec3 b = vec3(0.515, 0.550, 0.550);
    vec3 c = vec3(1.120, 1.120, 1.120);
    vec3 d = vec3(0.000, 0.333, 0.667);

    return a + b*cos( 6.28318*(c*t+d) );
}
vec3 palette2( float t ) {
    vec3 a = vec3(0.879, 0.885, 0.931);
    vec3 b = vec3(0.249, 0.579, 0.572);
    vec3 c = vec3(1.190, 0.894, 1.095);
    vec3 d = vec3(3.510, 3.347, 0.404);

    return a + b*cos( 6.28318*(c*t+d) );
}
vec3 palette3( float t ) {

    vec3 a = vec3(0.380, 0.380, 0.380);
    vec3 b = vec3(0.500, 0.500, 0.500);
    vec3 c = vec3(1.000, 1.000, 1.000);
    vec3 d = vec3(0.000, 0.333, 0.667);

    return a + b*cos( 6.28318*(c*t+d) );
}
vec3 palette4( float t ) {

    vec3 a = vec3(0.278, 0.218, 0.998);
    vec3 b = vec3(0.698, -0.642, 0.468);
    vec3 c = vec3(1.058, 2.278, -1.172);
    vec3 d = vec3(-0.082, 0.333, 0.667);

    return a + b*cos( 6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    float t = iTime;
    vec2 m = iMouse.xy;
    vec2 mn = m / iResolution.xy;

    vec2 uvcc = uv; 
    uv /= dot(uv,uv); 
    
    uv = polar(uv);
    uvcc = polar(uvcc);
    
    vec2 uvc = uv;
    
    uv = mix(uv, uvcc, sin(t*0.1)*0.5+0.5);
 
    
    uv.y /= 0.9;
    uv.r *= 3.;
    uv.y = mod(uv.y, 0.5)-0.25;
    uv.x = fract(uv.x); 
    
    vec2 zero = vec2(0.0, 0.0);
    vec2 one = vec2(1.0, 0.0);
    float d = sdOrientedVesica(uv, zero, one, 0.32+0.25*sin(uvc.x/2.5+t/4.+3.));
    d = abs(d);
    d = d + mod(d, 0.07);
    
    vec3 col = palette4(d+t*0.3);
    vec3 col2 = palette3(d+t*0.2);
    col = mix(col, col2, sin(d*(sin(1.*t-2.)*10.+20.)+t*-1.+uvc.x*1.3)*0.5+0.5);
    fragColor = vec4(col,1.0);
}