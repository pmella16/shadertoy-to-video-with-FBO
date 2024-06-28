 #define PI 3.1415926538
float min_dist(float d1,float d2,float d3,float d4){
    if(d1<d2 && d1<d3 && d1 < d4)
        return d1;
    else if(d2<d3 && d2<d4)
        return d2;
    else if(d3<d4)
        return d3;
    else 
        return d4;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


mat2 rot2D(float angle){
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c,-s,s,c);
}

vec3 palette(float x){

     vec3 a = vec3(0.058, 0.478, 1.008);
     vec3 b = vec3(-0.242, 0.398, 0.398);
     vec3 c = vec3(-0.204, 0.458, 0.530);
     vec3 d = vec3(0.358, 1.728, 1.225);

     return a + b *cos(5.8*(c*x+d));
     
     
}
     
float sdPyramid( in vec3 p, in float h )
{
    float m2 = h*h + 0.25;
    
    // symmetry
    p.xz = abs(p.xz);
    p.xz = (p.z>p.x) ? p.zx : p.xz;
    p.xz -= 0.5;
	
    // project into face plane (2D)
    vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
    float s = max(-q.x,0.0);
    float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
    float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
	float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
    float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
    // recover 3D and scale, and add sign
    return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));;
}


float makearrow(vec3 pos , float rotation){
    
    
    pos.xy *= rot2D(rotation);
    
    float box_dist_1 = sdBox(pos, vec3(0.1)); //cube SDF
    
    vec3 pos2 = pos;
    
    pos2.y -=0.1;//reposition the pyramid SDF
    
    //to scale, multiply pos within signed distance call, then divide result by same number to remove artifacts.
    float Pyramid_1 = sdPyramid(pos2*3., 1.)/3.; //tri SDF
    
    return min(box_dist_1,Pyramid_1);
}

//distance to scene
float map(vec3 pos){

    
    vec3 q = pos; //input point copy
    
    q.z += iTime;
    
    //q.x += iTime /2.;
    
    //space repitition
    q.y = mod(q.y,1.5) -.75; 
    q.x = mod(q.x,3.) - 1.5; 
    q.z = mod(q.z,1.) -.5;
    
    //make arrows!
    q.x -=.5;
    q.y +=.25;
    float dist_arrow1 = makearrow(q,0.0);
    
    vec3 q2 = q;
    q2.x += .5;
    
    float dist_arrow2 = makearrow(q2,PI);
    
    vec3 q3 = q2;
    q3.x += .5;
    
    float dist_arrow3 = makearrow(q3,PI*3./2.);
    
    vec3 q4= q3;
    q4.x -= 1.5;
    
    float dist_arrow4 = makearrow(q4,PI/2.);
    
    return min_dist(dist_arrow1,dist_arrow2,dist_arrow3,dist_arrow4);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord*2.0 - iResolution.xy)/iResolution.y;
    vec2 mouse = (iMouse.xy * 2.0 - iResolution.xy)/iResolution.y;
    float FOV = 1.0;

    //initialization
    vec3 rayorigin = vec3(0,0,-3.);
    
    vec3 raydirection = normalize(vec3(uv * FOV, 1));
    
    vec3 col = vec3(0);
    
    float dist_travelled = 0.;
    
    //raymarching
    
    int i;
    for(i =0; i < 1000 ;++i ){
    
        vec3 pos = rayorigin + raydirection * dist_travelled * .15; //play with this variable and the one below it's fun
    
        pos.xy *= rot2D(dist_travelled*.12 +iTime*.25) ; //second variable to edit
        
        float dist = map(pos);
        
        dist_travelled += dist; //march the ray
        
        if (dist <.0001 ) {
        break;
       
        }
        if( dist_travelled > 500.){
         fragColor = vec4(0,0,0,1);
         return;
         //break;
            
        }
    }
    
            
    col = vec3(dist_travelled *.02,dist_travelled *.03,dist_travelled *.04);
    
    col = palette(dist_travelled *.1 + float(i)*.005 + iTime*.3);
    
    fragColor = vec4(col,1);
    
    
    
    
    
    
   



}