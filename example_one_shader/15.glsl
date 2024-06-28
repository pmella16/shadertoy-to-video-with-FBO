void mainImage( out vec4 f, in vec2 w ){
    vec2 q=iResolution.xy,p=w-.5*q;
    float u=length(p)*2./q.x,t=30.*sin(iTime*.02);
    u+=.05*sin(50.*u)+.02*sin(40.*atan(p.y,p.x))-.5;
    u=(1.+exp(-16.*u*u))*t;
    p=smoothstep(-t,t,mat2(cos(u),-sin(u),sin(u),cos(u))*p);
    f.xyz = vec3(p.x+p.y-p.x*p.y*2.);
}