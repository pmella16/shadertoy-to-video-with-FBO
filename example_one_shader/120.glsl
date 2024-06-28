float sdSphere( vec3 p, float s ) {
  return length(p)-s;
}
float map( vec3 p) {
    float d = 1e10;
    float t = mod(iTime,10.0);
    for(float i=1.0; i<32.; i++){
        p.z *= 0.1;
        p.x += sin(p.z*12. + iTime + i) * i;
        p.y += cos(p.z*12. + iTime + i) * i;
        d = min(d, sdSphere(p,0.5 + sin(i*12. + iTime + p.z) * 0.4 ));
    }
    
    return d;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
	float vignette = 1.0 / max(0.25 + 0.9*dot(uv,uv),1.);
    vec3 rayOrigin = vec3(0.0);
    vec3 rayDirection = normalize(vec3(uv*1.333,1.0));
    vec3 col = vec3(0.0,0.0,0.0);
    float dist;
    
    float t = 0.01;
    float d;
    vec3 p;
    for ( int i = 0; i < 100; i++ )
    {
        p = rayOrigin + t * rayDirection;
        d = map( p );
        t += d / 2.;
    }
    if(d < 0.01) {
        col = vec3(1.0 * floor(mod(p.z*4. + iTime*12.,2.0))) / (1.0 + max(0.0,p.z - 32.) * 0.2);
    }
   // Output to screen
    col = vec3(1.) - col;
    fragColor = vec4(col,1.0);
}