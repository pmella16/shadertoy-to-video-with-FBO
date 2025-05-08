#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)

float PI=3.141592653589;

float fancyScene(vec2 uv, vec2 center, float squareSize, float edge) {
  float distX = abs(uv.x - center.x);
    float distY = abs(uv.y - center.y);
    float xVal = smoothstep(squareSize-edge, squareSize, distX);
    
    float yVal = smoothstep(squareSize-edge, squareSize, distY);
    
    float isInsideSquare = xVal+ yVal - xVal*yVal;
    return isInsideSquare;
}
float happy_star(vec2 uv, float anim)
{
    uv = abs(uv);
    vec2 pos = min(uv.xy/uv.yx, anim);
    float p = (2.0 - pos.x - pos.y);
    return (2.0+p*(p*p-1.5)) / (uv.x+uv.y);      
}
 
float s[10] = float[10](0.1,0.15,0.23,0.3,0.37,0.41,0.47,0.5,0.55,0.6);
float l[10]= float[10](1.0,2.0,2.0,3.0,2.55,1.3,1.3,2.0,0.4,2.33);
float sm = 0.5;

void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
     vec2 uvOrig = C/iResolution.xy;
       vec2 uv3= 2.0*(C-.5*iResolution.xy)/iResolution.xy;
 vec2 uv = C / iResolution.xy;
   vec2 uv2 = C / iResolution.xy-0.5;
  
    vec3 col=vec3(0);
 
    vec3 barCol=vec3(0.000,0.384,1.000);
    float t = iTime;
    
    float squareSize = 0.98; 
    float edge = 0.3;
    vec2 center = vec2(0,0);
   
   
   // Polar coords cause we want to move borders outside like in a circle
   float d = length(uv); // dist  
    float alpha = atan(uv3.y, uv3.x); //-pi to pi, //angle
    vec2 pc = vec2(d, alpha); // polar coords holding (dist, angle)
    
    //fancy calc or irregular shape
    float sinVal = sin(pc.y*3.+t*3.)*cos(pc.x*18.+t*3.)*0.025 ;
    
    vec2 changedUv = uv3; 
    changedUv+=sinVal;
     float sq = fancyScene(changedUv, center, squareSize, edge);
     
     vec3 tex =texture(iChannel0,uv3).xyz * (abs(sin(iTime*0.3)) +0.5);
     vec3 sqCol= sq*barCol* (1.+pow(sq,15.));
     col=mix(tex, sqCol,sq);
     //col=sqCol;
     col+=vec3(1.) * pow(sq,15.); // fade to white at the end
     
    
  
    vec3 orbit = vec3(0.0,0.0,0.0);
    float w = iResolution.x;
    float h = iResolution.y;
    for(int i=0; i < 400; i++) {
        float fi = float(i);
        float a = (1.0 - pow(cos(atan(uv.yyy - 0.5, uv.xxx - 0.5) / 2.0 + l[i%10] + pow(fi*0.1,3.0) + (iTime*0.1 * (1.0 + l[i%10] * 0.001))).x, 2.0)) < 0.01 ? 1.0:0.0;
        float o1 = clamp((s[i%10] - (fi * 0.001))/ length(vec2(uv.x - 0.5, (uv.y - 0.5) * (h / w))),0.0,1.0) * a;
        float o2 = clamp((s[i%10] - (fi * 0.001) - 0.003) / length(vec2(uv.x - 0.5f, (uv.y - 0.5f) * (h / w))),0.0,1.0) * a;
        orbit = orbit + (o2 - o1);
    } 
    float edge2 = 0.35;
    vec3 c = vec3(0.035,0.223,0.4) * clamp(
    smoothstep(length(vec2(uv.x - 0.5f, (uv.y - 0.5f) * (h / w))) - sm, length(vec2(uv.x - 0.5f, (uv.y - 0.5f) * (h / w))) + sm, edge2),0.0,1.0);
    c = clamp(c - orbit,0.0,1.0);
    vec3 p,q,r=iResolution,
    d2=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        p=g*d2;
        p.z=(iTime*2.);
        a=10.;
        p=mod(p-a,a*2.)-a;
        s=6.;
        for(int i=0;i++<8;){
            p=.3-abs(p);
          
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
            p.y<p.x?p=p.zyx:p;
            
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    120,
                    8.+cos(iTime*.5)*5.
                 )*c+col;
         }
       //  g+=e=length(p.yz)/s;
         g+=e=length(p.yx)/s;
    }
    uv *= 2.0 * ( cos(iTime * 2.0) -2.5); // scale
    float anim = sin(iTime * 12.0) * 0.1 + 1.0;  // anim between 0.9 - 1.1 
   O*= vec4(happy_star(uv2, anim) * vec3(0.35,0.2,0.55), 1.0);
}