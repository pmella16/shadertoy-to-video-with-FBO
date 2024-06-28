/* original  https://www.shadertoy.com/view/msKBzD  https://www.shadertoy.com/view/cltczN  https://www.shadertoy.com/view/wsGSRz*/
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+atan(r)*cross(p,a)
#define H(h)(sin((h)*6.3+vec3(0,23,21))*.5+.5)
vec3 palette( float t ) {
    vec3 a = vec3(0.5,0.5,0.5);
    vec3 b = vec3(0.5,0.5,0.5);
    vec3 c = vec3(2.000,1.000,0.000);
    vec3 d = vec3(0.5,0.2,0.25);

    return a + b*cos( 6.28318*(c*t+d) );
}
#define RAYMARCH_ITERATIONS 60.0
#define TIME (iTime * 0.4)
#define LINE_LENGTH 1.0
#define LINE_SPACE 1.0
#define LINE_WIDTH 0.007
#define BOUNDING_CYLINDER 1.8
#define INSIDE_CYLINDER 0.32
#define EPS 0.0001
#define FOG_DISTANCE 30.0

#define FIRST_COLOR vec3(1.2, 0.5, 0.2) * 1.2
#define SECOND_COLOR vec3(0.2, 0.8, 1.1)

float hash12(vec2 x)
{
 	return fract(sin(dot(x, vec2(42.2347, 43.4271))) * 342.324234);   
}

vec2 hash22(vec2 x)
{
 	return fract(sin(x * mat2x2(23.421, 24.4217, 25.3271, 27.2412)) * 342.324234);   
}

vec3 hash33(vec3 x)
{
 	return fract(sin(x * mat3x3(23.421, 24.4217, 25.3271, 27.2412, 32.21731, 21.27641, 20.421, 27.4217, 22.3271)) * 342.324234);   
}


mat3x3 rotationMatrix(vec3 angle)
{
 	return 	mat3x3(cos(angle.z), sin(angle.z), 0.0,
                 -sin(angle.z), cos(angle.z), 0.0,
                 0.0, 0.0, 1.0)
        	* mat3x3(1.0, 0.0, 0.0,
                    0.0, cos(angle.x), sin(angle.x),
                    0.0, -sin(angle.x), cos(angle.x))
        	* mat3x3(cos(angle.y), 0.0, sin(angle.y),
                    0.0, 1.0, 0.0,
                    -sin(angle.y), 0.0, cos(angle.y));
}
vec3 castPlanePoint(vec2 fragCoord)
{
 	vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.x;
    return vec3(uv.x, uv.y, -1.0);
}

float planeSDF(vec3 point)
{
 	return point.y;
}

//source https://iquilezles.org/articles/distfunctions
float boxSDF( vec3 point, vec3 bounds )
{
    vec3 q = abs(point) - bounds;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

//rgb - colors
//a - sdf
vec4 repeatBoxSDF(vec3 point)
{
    vec3 rootPoint = floor(vec3(point.x / LINE_SPACE, point.y / LINE_SPACE, point.z / LINE_LENGTH)); 
    rootPoint.z *= LINE_LENGTH;
    rootPoint.xy *= LINE_SPACE;
    float minSDF = 10000.0;
    vec3 mainColor = vec3(0.0);
    
    for (float x = -1.0; x <= 1.1; x++)
    {
        for (float y = -1.0; y <= 1.1; y++)
        {
			for (float z = -1.0; z <= 1.1; z++)
            {
				vec3 tempRootPoint = rootPoint + vec3(x * LINE_SPACE, y * LINE_SPACE, z * LINE_LENGTH);
                
                vec3 lineHash = hash33(tempRootPoint);
                lineHash.z = pow(lineHash.z, 10.0);
                
                float hash = hash12(tempRootPoint.xy) - 0.5;
                tempRootPoint.z += hash * LINE_LENGTH;
                
                vec3 boxCenter = tempRootPoint + vec3(0.5 * LINE_SPACE, 0.5 * LINE_SPACE, 0.5 * LINE_LENGTH);
                boxCenter.xy += (lineHash.xy - 0.5) * LINE_SPACE;
                vec3 boxSize = vec3(LINE_WIDTH, LINE_WIDTH, LINE_LENGTH * (1.0 - lineHash.z));
                
                vec3 color = FIRST_COLOR;
                if(lineHash.x < 0.5) color = SECOND_COLOR;
                
                float sdf = boxSDF(point - boxCenter, boxSize);
                if (sdf < minSDF)
                {
                    mainColor = color;
                    minSDF = sdf;
                }
            }
        }
    }
    
    return vec4(mainColor, minSDF);
}

float cylinderSDF(vec3 point, float radius)
{
 	return length(point.xy) - radius;
}

float multiplyObjects(float o1, float o2)
{
 	return max(o1, o2);   
}

vec3 spaceBounding(vec3 point)
{
 	return vec3(sin(point.z * 0.15) * 5.0, cos(point.z * 0.131) * 5.0, 0.0); 
}

//rgb - color,
//a - sdf
vec4 objectSDF(vec3 point)
{
    point += spaceBounding(point);
    
    vec4 lines = repeatBoxSDF(point);
    float cylinder = cylinderSDF(point, BOUNDING_CYLINDER);
    float insideCylinder = -cylinderSDF(point, INSIDE_CYLINDER);
    
    float object = multiplyObjects(lines.a, cylinder);
    object = multiplyObjects(object, insideCylinder);
 	return vec4(lines.rgb, object);
}


vec3 rayMarch(vec3 rayOrigin, vec3 rayDirection, out vec3 color)
{
    color = vec3(0.0);
    float dist = 0.0;
 	for (float i = 0.0; i < RAYMARCH_ITERATIONS; i++)
    {
     	vec4 sdfData = objectSDF(rayOrigin);
        color += sdfData.rgb * sqrt(smoothstep(0.8, 0.0, sdfData.a)) * pow(smoothstep(FOG_DISTANCE * 0.6, 0.0, dist), 3.0) * 0.2;
        rayOrigin += rayDirection * sdfData.a * 0.7;
        dist += sdfData.a;
        if (length(rayOrigin.xy) > BOUNDING_CYLINDER + 10.0) break;
    }


    return rayOrigin;
}
 
float SDF_Triangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)/sign(p.y);
}

float spiral(in vec2 p)
{
    float x = p.x*3.;
    
    float m = min (fract (x), fract (3. -x)) ;
    return smoothstep (-0.2, 0.1, m*.5+.2-p.y) ;
}

vec2 rotate(vec2 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}
void mainImage(out vec4 O, vec2 C)
{
    O=vec4(0);
    
    
    vec2 uv = (C.xy-.5*iResolution.xy) / iResolution.y;
    
    vec2 st = vec2 (atan(uv.x, uv.y), length (uv)) ;
    uv = vec2 (st.x / 6.2831+.5 - (-iTime + st.y), st.y);
    float c = 0.0;
    
    float triangle = SDF_Triangle((C.xy-.5*iResolution.xy) / iResolution.y, .3);
    
    c = spiral(uv) * 1.1 * spiral(vec2(spiral(uv / 50.6), triangle))*cos(iTime);
    
    
    c += triangle / 10.6;
 float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + 0.07)) * 2.2;
	float si = sin(t);
	float co = cos(t);
    mat2 ma = mat2(co, si, -si, co);
    uv*=ma;
    
    
    vec3 col = palette(length(st.y) + 1.4 + iTime*.4);
    col *= c;
    vec3 cameraCenter = vec3(0.0, 0.0, -TIME * 10.0);
    cameraCenter -= spaceBounding(cameraCenter);
    vec3 cameraAngle = vec3(0.0, 0.0, 0.0);
    
    vec3 prevCameraCenter = vec3(0.0, 0.0, -(TIME - 0.01) * 10.0);
    prevCameraCenter -= spaceBounding(prevCameraCenter);
    vec3 nextCameraCenter = vec3(0.0, 0.0, -(TIME + 0.4) * 10.0);
    nextCameraCenter -= spaceBounding(nextCameraCenter);
    
    vec3 velocityVector = -normalize(nextCameraCenter - prevCameraCenter);
    vec3 cameraUp = -normalize(cross(velocityVector, vec3(1.0, 0.0, 0.0)));
    vec3 cameraRight = -(cross(velocityVector, cameraUp));
    
    
    mat3x3 cameraRotation = mat3x3(cameraRight, cameraUp, velocityVector);
    
    vec3 rayOrigin = cameraCenter;
    vec3 rayDirection = cameraRotation * normalize(castPlanePoint(C));
    
    vec3 color = vec3(0.0);
    vec3 hitPoint = rayMarch(rayOrigin, rayDirection, color);
    vec4 sdf = objectSDF(hitPoint);
    
    float vision = smoothstep(0.01, 0.0, sdf.a);
    
    float fog = sqrt(smoothstep(FOG_DISTANCE, 0.0, distance(cameraCenter, hitPoint)));
    
    vec3 ambient = mix(SECOND_COLOR, FIRST_COLOR, pow(sin(TIME) * 0.5 + 0.5, 2.0) * 0.6);
    ambient *= sqrt((sin(TIME) + sin(TIME * 3.0)) * 0.25 + 1.0);
    vec3 bloom = smoothstep(-0.0, 15.0, color);
    
    color = color * vision * 0.07 * fog + bloom + ambient * 0.3;
    color = smoothstep(-0.01, 1.5, color * 1.1);
    
    uv = (C.xy-.5*iResolution.xy) / iResolution.y;
    c *= smoothstep(0.0, 0.05, length(uv));

    col *= c;

    st.x=fract(9.*sin(8.*(ceil(st.x*384.)/128.)));

    float
        t2=iTime*2.*((st.x+.5)/2.), 
        b=pow(1.-fract(st.y+st.x+t2),4.);

    b=(b*.5)+step(1.-b,.05);
    col += st.y * b*vec3(0.,.5,1.);
    
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.x,1));  
    
    
    for(float i=0.,a,s,e,g=0.;
        ++i<150.;
        O.xyz+=mix(vec3(1),H(g*.3),sin(.8))*1./e/8e3
    )
    
    
    
    {
        p=g*d;
         p.x+=cos(iTime*0.5);
             p.xy*=ma;
 p.y+=sin(iTime*0.5);
  p.xy*=rotate(  p.xy,iTime/10.-length(  p.xy)*1.);
        p.z+=iTime*6.5;
        a=12.;
        p=mod(p-a,a*2.)-a;
        s=2.;
        for(int i=0;i++<8;){
            p=1.3-abs((p));
            
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p; 
            p.y<p.y?p=p.yzx:p;
         
            s*=e=1.4+cos(iTime*.050)*.1*c*col.x;
            p=abs(p)*e-
                vec3(
                    1.+atan(iTime*.3+.05*tan(iTime*.3))*3.,
                    160,
                    1.+atan(iTime*.5)*5.
                
                 );
         }
         g+=e=length(p.yz)/s;
    }
    O.xyz += color;
}