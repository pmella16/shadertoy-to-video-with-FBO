/*original https://www.shadertoy.com/view/lslyRn, /* original https://www.shadertoy.com/view/lsyXDK https://www.shadertoy.com/view/lslyRn https://www.shadertoy.com/view/DlycWR and other*/
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

#define USE_CHEBYSHEV_DISTANCE 0

// Fun effect, to clamp the ball positions to a grid
#define BALLS_IN_GRID 0
#define BALL_GRID_SIZE 150.3
// if you use the grid, I'd also increase the speed - maybe 30-50 or so...
#define BALL_SPEED 3.3

const float speed2 = BALL_SPEED;

const float radius = 0.07;
const float thresholdFactor = 0.18;
const int ballCount = 23;

const vec3 backgroundColor = vec3(0.0);
const vec3 metaballColor = vec3(1.0, 0.5, 0.0);

const float zoomFactor = 2.5;
const float orbitRadius = 0.3;
#define R(p,a,r)mix(a*dot(p,a),p,cos(r))+sin(r)*cross(p,a)
#define H(h)(cos((h)*6.3+vec3(0,23,21))*.5+.5)
float dstMetaball(vec2 pos, vec2 center, float radius)
{
  vec2 diff = pos - center;
 
#if USE_CHEBYSHEV_DISTANCE
  diff = abs(diff);
  diff = vec2(max(diff.x, diff.y));
#endif

  return radius / dot(diff, diff);
}

vec3 colorByDistance(float dst, float falloff, vec3 color, vec3 oldColor)
{
  return mix(color, oldColor, smoothstep(0.0, falloff, dst));
}

// see: iquilezles.org/articles/palettes
vec3 colorIQ(float i)
{
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return (a + b * cos(((c * i + d) * 6.2831852)));
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 ro, in vec3 rd )
{
//get coords and direction
vec3 dir=rd;
vec3 from=ro;

//volumetric rendering
float s=0.1,fade=1.;
vec3 v=vec3(0.);
for (int r=0; r<volsteps; r++) {
vec3 p=from+s*dir*.5;
p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
float pa,a=pa=0.;
for (int i=0; i<iterations; i++) {
p=abs(p)/dot(p,p)-formuparam; // the magic formula
a+=abs(length(p)-pa); // absolute sum of average change
pa=length(p);
}
float dm=max(0.,darkmatter-a*a*.001); //dark matter
a*=a*a; // add contrast
if (r>6) fade*=1.1; // dark matter, don't render near
//v+=vec3(dm,dm*.5,0.);
v+=fade;
v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
fade*=distfading; // distance fading
s+=stepsize;
}
v=mix(vec3(length(v)),v,saturation); //color adjust
fragColor = vec4(v*.03,1.);
}
#define Rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
//get coords and direction
vec2 uv=fragCoord.xy/iResolution.xy-.5;

vec3 dir=vec3(uv*zoom,iTime*0.001);
float time=iTime*speed+.25;

  float aspect = iResolution.x / iResolution.y;
  vec2 pos = (fragCoord.xy / iResolution.xy) * vec2(aspect, 1.0);
  pos -= clamp(vec2(aspect, 1.0 / aspect) - 1.0, 0.0, 1.0)  * 0.5;
  pos = pos * 2.0 - 1.0;
  pos /= zoomFactor;
   
  vec3 color = backgroundColor;
  float time2 = float(iTime);
   
  float dst = dstMetaball(pos, vec2(0.0), radius);
  color += colorIQ(time2 * speed2 * 0.01) * dst * thresholdFactor * (sin(radians(time2 * (speed2 + 5.3))) * 0.5 + 0.5) * 30.0;

  // init the vars for the other balls
  vec2 ballPos = vec2(orbitRadius*cos(iTime), 0.0);
  float angle = radians(time2 * speed2);
  mat2 matRotate = mat2(cos(angle), -sin(angle),
                        sin(angle),  cos(angle));
                        vec4 O= fragColor;
                        vec2 C=fragCoord;
 O=vec4(0);
    vec3 p,q,r=iResolution,
    d=normalize(vec3((C*2.-r.xy)/r.y,1));  
    for(float i=0.,a,s,e,g=0.;
        ++i<110.;
        O.xyz+=mix(vec3(1),H(g*.1),sin(.8))*1./e/8e3
    )
    {
        p=g*d;
        p.z+=iTime*1.5;
        a=10.;
          float t = mod(iTime*0.1,4.);
     
     
        p=mod(p-a,a*2.)-a;
        s=5.;
       
        for(int i=0;i++<8;){
            p=.3-abs(p);
           
            p.x<p.z?p=p.zyx:p;
            p.z<p.y?p=p.xzy:p;
             
            s*=e=1.4+sin(iTime*.234)*.1;
            p=abs(p)*e-
                vec3(
                    5.+cos(iTime*.3+.5*cos(iTime*.3))*3.,
                    60,
                    8.+cos(iTime*.5)*1.
                 );
         }
         g+=e=length(p.yz)/s;
    }
  for (int i=0; i < ballCount; ++i)
  {
    ballPos = matRotate * ballPos;
#if BALLS_IN_GRID
    ballPos = round(ballPos * BALL_GRID_SIZE) / BALL_GRID_SIZE;
#endif
    dst = dstMetaball(pos, ballPos, radius);
    color += colorIQ(((float(i) + 3.0) / float(ballCount)) + time2* speed2 * 0.00) * dst * thresholdFactor;
    //color += getColor(tex.x) * dst * thresholdFactor;
  }
color /= float(ballCount) + 1.0;
vec3 from=vec3(1.,.5,0.5)*O.xyz;



mainVR(fragColor, fragCoord, from, dir);
    fragColor*=vec4(color*O.xyz,1.);
 
}

