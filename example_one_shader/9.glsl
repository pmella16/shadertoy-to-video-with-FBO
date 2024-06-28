
float time = 0.1;
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

 mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

float map(vec3 p)
{

    vec3 q = p;

    vec3 c = vec3(0.2);
    p.z = mod(p.z,c.z)-0.5*c.z;

    
    vec3 p_s;
    
    p = p * rotationMatrix(vec3(0.0, 0.0, 1.0), sin(floor(q.z * 10.0) * 10.0) * 4.0 + 0.1 * (time));
    
    float bars = 1000.0;
    int sides = 9; // not really sides
    float angle = 3.1415 * 2.0 / float(sides) + sin(iTime/10.0)+ 1.0;
    
    for ( int i = 0; i < sides; i ++)
    {
        
        p_s = p * rotationMatrix(vec3(0.0, 0.0, 1.0), angle * float(i));
        
       	p_s += vec3(
            sin(30.0 * floor(q.z))* 0.5 + 1.0, 
            cos(iTime + sin(q.z* 9.0)), 
            0.0);
        
        vec3 boxdim = vec3(
        	0.05 + 0.05 * sin(q.z*5.0 + iTime* 2.0), 
            sin(q.z * 10.0) * 0.5  + 0.5, 
            0.01 + pow(sin(iTime), 0.5)
        );
     	
        
        bars = min(bars, sdBox(p_s, boxdim));  
    }

        
    
    float result = bars;   
    return result;
}


void getCamPos(inout vec3 ro, inout vec3 rd)
{
    ro.z = time;
   // ro.x -= sin(iTime) 2.0;
}

 vec3 gradient(vec3 p, float t) {
			vec2 e = vec2(0., t);

			return normalize( 
				vec3(
					map(p+e.yxx) - map(p-e.yxx),
					map(p+e.xyx) - map(p-e.xyx),
					map(p+e.xxy) - map(p-e.xxy)
				)
			);
		}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	time = iTime * 0.5;
    vec2 _p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
    vec3 ray = normalize(vec3(_p, 1.0));
    vec3 cam = vec3(0.0, 0.0, 0.0);
    bool hit = false;
    getCamPos(cam, ray);
    
    float depth = 0.0, d = 0.0, iter = 0.0;
    vec3 p;
    
    for( int i = 0; i < 40; i ++)
    {
    	p = depth * ray + cam;
        d = map(p);
                  
        if (d < 0.001) {
			hit = true;
            break;
        }
                   
        float ratio = 0.2;
		depth += d * ratio;
		iter++;
                   
    }
    
    vec3 col = vec3(1.0 - iter / 40.0);
	
    
    
    col = pow(col, vec3(
        0.5,
         0.1 + sin(iTime - p.z * 3.6)* 0.4 + 0.5,
        0.1 + sin(iTime - p.z * 10.0)* 0.4 + 0.5));

    
    
    fragColor = vec4(col, hit? length(p.xy) : 0.0 );
    
}