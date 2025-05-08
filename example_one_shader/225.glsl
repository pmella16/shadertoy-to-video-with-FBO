float r(vec2 p){return cos(iTime*cos(p.x*p.y));}
void mainImage(out vec4 c,vec2 p){p*=.3;
for(int i;i++<32;p=ceil(p+r(ceil(p/8.))+r(floor(p/8.))*vec2(-1,1)))
c=sin(p.xyxy);}
