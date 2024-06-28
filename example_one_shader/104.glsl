float box3(vec3 p,vec3 b){
    p = abs(p)-b;
    return length(max(vec3(0.),p))+min(0.,max(p.x,max(p.y,p.z)));
}
vec3 erot(vec3 p,vec3 ax,float t){return mix(dot(ax,p)*ax,p,cos(t))+cross(ax,p)*sin(t);}

float txt(vec2 uv){
    float d = min(length(fract(uv.x)-.5),length(fract(uv.y)-.5))-.1;
    return max(.05,smoothstep(sqrt(dFdx(d)*dFdx(d)+dFdy(d)*dFdy(d)),0.,abs(d)-.01));
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord.xy -.5* iResolution.xy)/iResolution.y;
    float tt = 0.0;
    vec3 col = vec3(0.);
    vec3 p,d = normalize(vec3(uv,1.+(-tt+.8)*sqrt(length(uv))));
    for(float i=0.,e=0.,g=0.;i++<50.;){
      p  = d*g;
      float z = p.z;
      p.z -=10.;;
      
    
      p = erot(p,normalize(vec3(2.*cos(iTime),1.,sin(iTime)*-.66)),floor(iTime*.2)+pow(fract(iTime*.2),.25));
      
      float mj=1.;
      for(float j=0.;j++<5.;){
        p =abs(p)-vec3(1.7);
        p*=1.4;
        
        mj*=1.4;
        p = erot(p,normalize(vec3(-.5,5.,1.5*sin(j))),j*j*.785);
        
      }
      float h = box3(p,vec3(1.));
      h = min(h,min(min(length(p.yz),length(p.xz)),length(p.xy))-0.1);
      g+=e=max(.001,abs(h/mj));
      float dd = txt(p.xy)+txt(p.xz)+txt(p.yz);
      col += (erot(vec3(.1,.2,.3),normalize(vec3(.3,.2+sin(i*5.),.3)),i+iTime+p.z)*(.05+dd*sin(z+iTime)))/exp(i*i*e);
        
    }
    fragColor = vec4(sqrt(col),1.0);
}