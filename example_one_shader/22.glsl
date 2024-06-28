
// Shpaes distance func
float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float sdOctahedron( vec3 p, float s)
{
  p = abs(p);
  float m = p.x+p.y+p.z-s;
  vec3 q;
       if( 3.0*p.x < m ) q = p.xyz;
  else if( 3.0*p.y < m ) q = p.yzx;
  else if( 3.0*p.z < m ) q = p.zxy;
  else return m*0.57735027;
    
  float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
  return length(vec3(q.x,q.y-s+k,q.z-k)); 
}

float sdPyramid( vec3 p, float h )
{
  float m2 = h*h + 0.25;
    
  p.xz = abs(p.xz);
  p.xz = (p.z>p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

  vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
  float s = max(-q.x,0.0);
  float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
  float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
  float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
  float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
  return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}

float sdEllipsoid( vec3 p, vec3 r )
{
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

//Utils

float smin(float a, float b, float k)
{
    float h = max(k- abs(a-b), 0.0)/k;
    return min(a,b) - h*h*h*k*(1.0/6.0);
}

vec3 rot3D(vec3 p, vec3 axis, float angle)
{
    return mix(dot(axis,p) * axis, p, cos(angle)) + cross(axis,p) * sin(angle);
}

mat2 rot2D(float angle)
{
     float s = sin(angle);
     float c = cos(angle);
     
     return mat2(c, -s, s, c);
}


// Custom gradient - https://iquilezles.org/articles/palettes/
vec3 palette(float t) {
    float time = iTime*0.05;
    time += 230.; // Time offset
    vec3 vector = vec3(
        clamp( smoothstep(0.2, 0.8, 0.8 + 0.5 * sin(0.6 * time)), 0.3, .7),
        clamp( smoothstep(0.2, 0.8, 0.5 + 0.5 * cos(0.8 * time + 2.0)), 0.5, .6),
        clamp( smoothstep(0.2, 0.8, 0.5 + 0.5 * sin(1.5 * time + 4.0)), 0.2, .4)
    );

    return .5+.5*cos(6.28318*(t+vector));
}

float movementCurve( float x) {
    return -2.0 / (1.0 + exp(-10.0 * (0.5 * x - 0.5))) + 1.0;
}

float PI = 3.1416;
float fovMult(float x, float a, float d) 
{
    return a + d + sin(PI * x - sqrt(PI)) * a;
}

//Render
float map(vec3 p)
{
    vec3 q = p;
    
    q.z +=  iTime*0.8;//smootherstep(0.,1.,sin(iTime));
    
    
    q.xy = fract(vec2(q.x, q.y)) - .5;
    q.z = mod(q.z, .3) - .125;
    
    
    float oct = sdEllipsoid(q, vec3(fovMult(iTime*0.1, 0.6, 0.01)*.3));
    
    return oct;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    
    
    
    //Movement
    vec2  m = (iMouse.xy * 2. - iResolution.xy) / iResolution.y;
    if (iMouse.z < 0.) 
        m = vec2(cos(iTime*.05), sin(iTime*.25));
    
        
    
    vec3 ro = vec3(0,0,-5);           //Ray origin
    vec3 rd = normalize(vec3(uv/(5.*fovMult( iTime*0.01, 0.57, 0.03)),1));  // Ray direction
    vec3 col = vec3(0);
    
    float t = 0.;                     //Distance travelled
    
    int i = 0;
    for( ;i < 130; i++)
    {
        vec3 p = ro + rd*t;
        //Sound
        // the sound texture is 512x2
        int tx = int((t/10000.)*512.0);

        // first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
   
        
        p.y += 0.5* sin(t*(m.y+1.)*.5)*.7;
        p.xy *= rot2D(t*.2*m.x);
        p.y += sin(cos(tan(cos(t*6.*fovMult(-iTime*0.02, 0.5, 0.3))))/10.) ;
        
        p.y += 0.5*cos(t*(m.y+1.)*.5)*.7;
        
        float d = map(p);
        
        t += d;
        
        if(t >= 10000. || d <= 0.003) break;
        
    }
    
    
    col = palette(t*0.01+float(i)*0.01);
    
    fragColor = vec4(col,1);
    

}