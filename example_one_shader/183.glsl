#ifdef GL_ES
precision mediump float;
#endif

// 2D rotation function
mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

// Custom gradient - https://iquilezles.org/articles/palettes/
vec3 palette(float t) {
    return .5+.5*cos(6.28318*(t+vec3(.3,.416,.557)));
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float map(vec3 p){
    p.z += iTime * .5; // Forward movement

    // Space repetition
    p.xy = fract(p.xy) - .5;     // spacing: 1
    p.z =  mod(p.z, .25) - .125; // spacing: .25

    float boxFrame = sdBoxFrame(p, vec3(.0125 * 4.5), .0125 *.5);

    return boxFrame;
}

vec2 raymarching(vec3 ro, vec3 rd){
    float t = 0.; // total distance
    int i = 0;

    vec2 m = vec2(cos(iTime*.2), sin(iTime*.2));

    for(int i = 0; i < 80; i++){
        vec3 p = ro + rd * t; // position along ray

        p.xy *= rot2D(t*.25 * m.x);     // rotate ray around z-axis

        p.y += 2.*sin(t*(m.y+1.)*.5)*.35;  // wiggle ray

        float d = map(p); // current distance in scene
        
        t += d; // "march" the ray

        if (d < .001 || t > 100.) break; // early stop
    }

    return vec2(t, i);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = (fragCoord.xy * 2. -
        iResolution.xy)
        / iResolution.y;

    // Initialize
    vec3 ro = vec3(0.,0.,-3.); // ray origin
    vec3 rd = vec3(uv,1.); //ray direction

    vec3 col = vec3(0.);

    vec2 rm = raymarching(ro, rd);
   

    col = palette(rm.x*.04*sin(iTime) + float(rm.y)*.5);

    fragColor = vec4 (col, 1.0);
}