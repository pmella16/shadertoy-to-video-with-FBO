vec3 gradient (float grayscale,vec3 offset, vec3 amp, vec3 freq,vec3 phase)
{
    return offset+amp*sin(freq*grayscale+phase);
}
mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}
//Compute Zn2 +C
vec2 computeNext(vec2 current,vec2 constant)
{
    // zn2
    float zr = (current.x* current.x - current.y * current.y);
    float zi= (1.+3.*sin(iTime/5.)) * current.x* current.y;
    vec2 Zn2 = vec2(zr,zi);
    // Add constant
    //return Zn2+ constant + dot(Zn2,Zn2);
    return Zn2+ constant + dot(zr,zi);
}

//Computes sequence elements until mod exceeds threshold or max iteration is reached
vec3 computeIterations(vec2 z0, vec2 constant, int maxIteration)
{
    vec2 zn = z0;
    int iteration =0;
    while(dot(zn,zn)<40000000.0 && iteration< maxIteration)
    {
        zn = computeNext(zn,constant);
        iteration++;
    }
    return vec3(log(zn),iteration);
}
vec3 render(vec2 fragCoordIn)
{
    vec2 uv = (fragCoordIn-.5*iResolution.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy-vec2(.5);
    uv*=2.;
    uv*=Rot(90.);
	
    float scale =1./float(fragCoordIn.y /2.);
    
    float sinTime = sin(iTime);
    float cosTime = cos(iTime);
    vec2 constant = vec2(.352*(0.4857+.5),.1*(0.1969+.5));//+.0005*vec2(cosTime,sinTime);
    // Compute color
    vec3 endComp = computeIterations(uv,constant,150);
    float col = 1.-length(endComp.xy)*.2;
    //col = endComp;
    //vec3 col = vec3(endComp.z);
    // Output to screen
    vec3 color = gradient(col+.5+cos(iTime)*.5,vec3(0.6284,0.490,0.500),vec3(-0.392,0.500,0.500),vec3(0.5,1.000,1.000),vec3(-0.841,-0.572,0.667));          
    float alpha = log(endComp.z/2.);
    color*=alpha;
    return color;

}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float SMOOTH = 0.05;
    vec3 color = 0.25*render(fragCoord+vec2(SMOOTH,0.));
    color+=0.25*render(fragCoord+vec2(-SMOOTH,0));
    color+=0.25*render(fragCoord+vec2(0.,SMOOTH));
    color+=0.25*render(fragCoord+vec2(0.,-SMOOTH));
    fragColor = vec4(color,1.0);
}