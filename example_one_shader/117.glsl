void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 p = (2.*fragCoord-iResolution.xy)/min(iResolution.x,iResolution.y);
    float t = 0.6;
    p = vec2(cos(t)*p.x-sin(t)*p.y,sin(t)*p.x+cos(t)*p.y);
    vec3 col = vec3(0.);
    for(int i= 1;i<100;i++){

	p.x += 0.7/float(i)*sin(float(i)*0.2+p.y+iTime*0.2);

	p.y += 0.5/float(i)*cos(float(i)*4.*p.x+iTime*-0.6);

   }
   	float r = (cos(p.x+p.y+1.))*0.5+0.5;
	float g = abs(sin(p.x+p.y+1.));
	float b = 0.5+0.5*(sin(p.x+p.y)+cos(p.x+p.y));
	col = vec3(r,b,g);
    //col *=col ;
    fragColor = vec4(col,1.0);
}