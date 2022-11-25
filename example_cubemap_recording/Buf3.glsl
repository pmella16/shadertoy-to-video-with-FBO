
// Created by Danil (2022+) https://github.com/danilw
// CC0 license (use as you wish)

// self https://www.shadertoy.com/view/DdfXzj

// This is 360 video recording example/template 
// https://github.com/danilw/shadertoy-to-video-with-FBO

// BufA is build panorama from cubemap
// Image is example cubemap for video recording

// two ways of using it:
// 1. record single video per side and then convert videos to frames and use frames as iTexture (for video recording, look video recordin example)
// and just render BufA as Image using sides as textures
// and REMEMBER to set clamp_to_edge instead of repeat on textures (in python script)
// 2. use this Image shader as Buf0-5 and use BifA as Image in recording - example_cubemap


// if you edit it - REMEMBER to multiply by 2 and add to VIDEO SIDE SIZE and convert command
const float shift_per_side = 0.; //pixel shift for TAA shaders, can be 0 if not needed

// Idea of shift_per_side - in TAA sides will "appears" with noise (on cubemap side that opposite moement direction)
// and it makes cubemap sides visible in 3d(360) video
// so I render XX - pixels around original screen border
// screen is 3256 and shift_per_side=128 - real screen size 3000
// because I cut 128x2 in every side of image/screen
// so render 3256 target resolution then cut 128 from sides then use this image as input for BufA (when BufA used as Image shader)

// if you dont have TAA - then shift_per_side can be 0 it useless

// and remember - effect such as Bloom/Blur will break cubemap consistensy in 360 video
// Bloom/Blur should be applied to entire cubemap (as cubemap) - I do not have setup for it right now


// this is start_mouse_Down_side

// edit start_mouse
const vec2 start_mouse_Front_side = vec2(3.1415965/2., 0.); //  Front_side = 0
const vec2 start_mouse_Back_side = vec2(-3.1415965/2., 0.); //  Back_side = 1
const vec2 start_mouse_Up_side = vec2(0., 3.1415965/2.);    //  Up_side = 2
const vec2 start_mouse_Down_side = vec2(0., -3.1415965/2.); //  Down_side = 3
const vec2 start_mouse_Left_side = vec2(0., 0.);            //  Left_side = 4
const vec2 start_mouse_Right_side = vec2(3.1415965, 0.);    //  Right_side = 5

const vec2 start_mouse = start_mouse_Down_side;



// FOV set to 90 in SetCamera()







#define iResolution (iResolution.xy-shift_per_side*2.)



#define AA 0

#define MAX_DIST 1000.
#define MIN_DIST .001



void SetCamera(vec2 uv, out vec3 ro, out vec3 rd);
vec3 render(vec3 ro, vec3 rd);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    fragCoord+=-shift_per_side;
    vec3 ret_col = vec3(0.0);
    vec3 ro; vec3 rd;
    #if AA>1
    for( int mx=0; mx<AA; mx++ )
    for( int nx=0; nx<AA; nx++ )
    {
    vec2 o = vec2(float(mx),float(nx)) / float(AA) - 0.5;
    vec2 uv = (fragCoord+o)/iResolution.xy * 2.0 - 1.0;
    #else
    vec2 uv = fragCoord/iResolution.xy * 2.0 - 1.0;
    #endif
    uv.y *= iResolution.y/iResolution.x;
    SetCamera(uv, ro, rd);
    //panorama_screen_uv_to_rd(fragCoord/iResolution.xy, rd); //test
    vec3 col = render(ro, rd);
    ret_col += col;
    #if AA>1
    }
    ret_col /= float(AA*AA);
    #endif
    
    

    ret_col = 0.9*mix(ret_col, ret_col*ret_col, 0.5);
    fragColor = vec4(ret_col,1.);
    
    //fragColor=texture(iChannel0,fragCoord/iResolution.xy);
}




const vec3 white=vec3(0xef,0xea,0xe0)/float(0xff);
const vec3 dark=vec3(0x16,0x14,0x32)/float(0xff);
const vec3 blue=vec3(0x0a,0x0f,0x73)/float(0xff);

// REWORK ROTATIONS!!!!!!!!!!

mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c));  }
mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}



const vec3 sun_color = vec3(2.5, 1.74, 1.09);
const vec3 sky_color = vec3(0.4, 0.7, 1.0);
const vec3 horizon_color = vec3(1.0, 1.1, 1.1);
const vec3 ground_color = vec3(0.3, 0.14, 0.04);

vec3 sun_dir()
{
  ///return normalize(vec3(sin(iTime), 0.6, cos(iTime)));
  return vec3(0.72155,0.514495,0.4633);
  return normalize(vec3(sin(1.), 0.6, cos(1.)));
}

vec3 blurred_background(vec3 rd)
{
    float sun = max(0.0, dot(rd, sun_dir()));
    return mix(ground_color, sky_color, (dot(rd, vec3(0.0, 1.0, 0.0))*0.5 + 0.5)) +
        0.24*pow(sun, 2.0)*sun_color;
}

vec3 background_sky(vec3 rd)
{
    float sun = max(0.0, dot(rd, sun_dir()));
    float horizon = max(0.0, dot(rd, vec3(0.0, 1.0, 0.0))) + max(0.0, dot(rd, vec3(0.0, -1.0, 0.0)));
    horizon = 1.0 - horizon;
    horizon = horizon*horizon; 
    return pow(sun, 256.0)*sun_color + mix(blurred_background(rd), horizon_color, horizon);
}


// simple 2

const vec3  skyCol1        = pow(vec3(0.2, 0.4, 0.6), vec3(0.25))*1.0;
const vec3  skyCol2        = pow(vec3(0.4, 0.7, 1.0), vec3(2.0))*1.0;
const vec3  sunCol         = vec3(8.0,7.0,6.0)/8.0;
const float miss          = 1E4;

vec3 background_sky2(vec3 rd) {
vec3 ro = vec3(0.);
  vec3 sunDir = normalize(sun_dir());
  float sunDot = max(dot(rd, sunDir), 0.0);  
  vec3 final = vec3(0.);

  final += mix(skyCol1, skyCol2, rd.y);
  final += 0.5*sunCol*pow(sunDot, 20.0);
  final += 4.0*sunCol*pow(sunDot, 400.0);    
  return final;

}


void SetCamera(vec2 uv, out vec3 ro, out vec3 rd)
{
    ro = vec3(0.,2.*abs(sin(3.14159265*iTime/3.)),0.);
    vec2 m = iMouse.z>0.?(3.1415926*(iMouse.xy/(iResolution.y+shift_per_side*2.)-0.5*(iResolution.xy/iResolution.y))):start_mouse;
    m.y = -m.y;
    float fov=90.;
    float aspect = iResolution.x / iResolution.y;
    float screenSize = (1.0 / (tan(((180.-fov)* (3.1415926 / 180.0)) / 2.0)));
    rd = vec3(uv*screenSize, 1./aspect);

    rd = normalize(rd);
    mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));

    rd = (rotY * rotX) * rd;
}

vec3 color_grid(vec2 p,float d) {
    vec2 e = min(vec2(1.0), fwidth(p)); 
    vec2 l = smoothstep(vec2(1.0), 1.0 - e, fract(p)) + smoothstep(vec2(0.0), e, fract(p)) - (1.0 - e);
    return mix(vec3(0.4), vec3(0.8) * (l.x + l.y) * 0.5, exp(-d*0.01));
}
vec4 calcColortb(vec3 ro, vec3 rd, float d, vec3 norm) {

    vec2 p = (ro+rd*d).xz;

    return vec4(vec3(color_grid(p,d)),1.);
}



//-------------------


#define OBJ_SKY 0
#define OBJ_BALL 1
#define OBJ_FLOOR 2
#define OBJ_WALL 3
#define OBJ_BOX 4

struct HitInfo {
    float t;
    vec3 norm;
    vec4 color;
    int obj_type;
};


bool PlaneIntersect(vec4 Plane, vec3 ro, vec3 rd, out float t, out vec3 norm) {
    norm=vec3(0.,1.,0.);
    t=-1.;
    float dd = dot(rd, Plane.xyz);
    if (dd == 0.0) return false;
    float t1 = -(dot(ro, Plane.xyz) + Plane.w) / dd;
    if (t1 < 0.0) return false;
    norm = normalize(Plane.xyz);
    t = t1;
    return true;
}

void GroundIntersectMin(vec3 ro, vec3 rd, inout bool result, inout HitInfo hit) {
    float tnew;
    vec3 normnew;
    vec4 pp=vec4(0.0,01.,0.0,0.);
    ro+=vec3(0.,1.2,0.);
    if (PlaneIntersect(pp, ro, rd, tnew, normnew)) {
        if (tnew < hit.t) {
            hit.t = tnew;
            hit.norm = normnew;
            hit.color = calcColortb(ro,rd,hit.t,hit.norm);
            hit.obj_type = OBJ_FLOOR;
            result = true;
        }
    }
}

vec2 Box_hit(vec3 ro,vec3 rd,vec3 p0,vec3 p1)
{
    vec3 t0 = (mix(p1, p0, step(0., rd * sign(p1 - p0))) - ro) / rd;
    vec3 t1 = (mix(p0, p1, step(0., rd * sign(p1 - p0))) - ro) / rd;
    return vec2(max(t0.x, max(t0.y, t0.z)),min(t1.x, min(t1.y, t1.z)));
}

vec3 boxNormal(vec3 pos,vec3 p0,vec3 p1, vec3 bsize)
{
    pos = pos - (p0 + p1) / 2.;
    vec3 arp = abs(pos) / bsize;
    return step(arp.yzx, arp) * step(arp.zxy, arp) * sign(pos);
}

// box intersection, inverted faces
bool BoxIntersect_min_inv( in vec3 ro, in vec3 rd, vec3 opos, vec3 size, out float tN, out vec3 norm){
    vec3 p = size*0.5+opos;
    vec3 q = -size*0.5+opos;
    vec2 b = Box_hit(ro, rd, p, q);
    tN=MIN_DIST;
    norm=vec3(0.,1.,0.);

    if(b.y > MIN_DIST && b.x < b.y && b.y < MAX_DIST)
    {
        tN = b.y;
        vec3 pos = ro + rd * tN;
        norm = -boxNormal(pos, p, q, size);
        return true;
    }
    return false;
}

// box intersection
bool BoxIntersect_min( in vec3 ro, in vec3 rd, vec3 opos, vec3 size, out float tN, out vec3 norm){
    vec3 p = size*0.5+opos;
    vec3 q = -size*0.5+opos;
    vec2 b = Box_hit(ro, rd, p, q);
    tN=MIN_DIST;
    norm=vec3(0.,1.,0.);

    if(b.x > MIN_DIST && b.x < b.y && b.x < MAX_DIST)
    {
        tN = b.x;
        vec3 pos = ro + rd * tN;
        norm = boxNormal(pos, p, q, size);
        return true;
    }
    return false;
}




// --------------
// debug drawing 2D


//https://www.shadertoy.com/view/ldsyz4
// The MIT License
// Copyright © 2017 Inigo Quilez
// Digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
const int[] font = int[](0x75557, 0x22222, 0x74717, 0x74747, 0x11574, 0x71747, 0x71757, 0x74444, 0x75757, 0x75747);
const int[] powers = int[](1, 10, 100, 1000, 10000, 100000, 1000000);

int PrintInt( in vec2 uv, in int value, const int maxDigits )
{
    if( abs(uv.y-0.5)<0.5 )
    {
        int iu = int(floor(uv.x));
        if( iu>=0 && iu<maxDigits )
        {
            int n = (value/powers[maxDigits-iu-1]) % 10;
            uv.x = fract(uv.x);//(uv.x-float(iu)); 
            ivec2 p = ivec2(floor(uv*vec2(4.0,5.0)));
            return (font[n] >> (p.x+p.y*4)) & 1;
        }
    }
    return 0;
}


// https://www.shadertoy.com/view/XsBBRd

// ------------------------------------------------------------------------------------------------
float m_stretch(float point, float stretch){
    return .5 * (sign(point) * stretch - point) * (sign(abs(point) - stretch) + 1.);
}

float ollj_rotate(vec2 uv){
    const float ROTATE_PARAM0 = sqrt(1.);
    const float ROTATE_PARAM1 = sqrt(.0);
    return dot(uv, vec2(ROTATE_PARAM0 + ROTATE_PARAM1, ROTATE_PARAM0 - ROTATE_PARAM1));
}


float sdf_arrow(vec2 uv, float norm, float angle, float head_height, float stem_width){
    uv = vec2(cos(angle) * uv.x + sin(angle) * uv.y, -sin(angle) * uv.x + cos(angle) * uv.y);

    norm -= head_height;
    uv.x -= norm;

    uv.y = abs(uv.y);   
    float head = max(ollj_rotate(uv) - head_height, -uv.x);

    uv.x = (.5 * m_stretch(2. * uv.x + norm, norm));
    uv.y = (.5 * m_stretch(2. * uv.y, stem_width));
    float stem = length(uv);

    return min(head, stem);
}

float get_arrow(vec2 arrow_uv, float arrow_aa, float arrow_angle){
    float arrow_norm = 1.15; 
    float arrow_head_height = .1;  
    float arrow_stem_width = .04; 
    float arrow;
    arrow = sdf_arrow(arrow_uv, arrow_norm, arrow_angle, arrow_head_height, arrow_stem_width);
    arrow = 1.-smoothstep(0., arrow_aa, arrow);

    return arrow;
}

// ------------------------------------------------------------------------------------------------


vec4 grid(vec2 p, float grid_line, int id, vec3 idx_color){
    vec3 colr_r=vec3(0.8,0.,0.);
    vec3 colr_g=vec3(0.0,0.8,0.);
    vec3 colr_r2=vec3(0.35,0.,0.);
    vec3 colr_gr=vec3(0.16);
    vec3 colr_w=vec3(0.98);
    const float grid_size=2.;
    
    vec2 op=p;
    
    vec3 col=vec3(0.);
    float al=0.;
    vec2 dv=1.-step(0.5,abs(p));
    if(dv.x*dv.y==0.)return vec4(col,al);
    p=fract(p*grid_size)-0.5;
    dv=step(0.35,abs(p));
    if(dv.x*dv.y==0.){
        dv=step(0.5-grid_line*grid_size,abs(p));
        float r1=max(dv.x,dv.y);
        p=fract(p*2.)-0.5;
        dv=step(0.5-grid_line*grid_size*2.,abs(p));
        float r2=max(dv.x,dv.y);
        p=fract((p-0.5)*5.)-0.5;
        dv=step(0.5-grid_line*grid_size*2.*5.,abs(p));
        float gr=max(dv.x,dv.y);
        col=colr_r*r1;
        col=max(col,colr_r2*r2);
        col=max(col,colr_gr*gr*(1.-r1));
        al=max(max(r1,r2),gr);
    }
    else{
        dv=step(0.4,abs(p));
        if(dv.x*dv.y>0.){
            dv=step(0.5-grid_line*grid_size*2.,abs(p));
            al=max(dv.x,dv.y);
            col=colr_w*al;
        }
    }
    float arow = get_arrow(op*2.+vec2(0.25,0.45), grid_line*4., 0.);
    al=max(al, arow);
    col=mix(col, colr_g*0.7, arow);
    
    arow = get_arrow(op*2.+vec2(0.45,0.25), grid_line*4., 3.1415926/2.);
    al=max(al, arow);
    col=mix(col, colr_r*0.7, arow);
    
    float idx=float(PrintInt((op+vec2(-0.25))*6.,id,1));
    al=max(al, idx);
    col=mix(col, idx_color, idx);
    
    return vec4(col,al);
}

// --------------

void convert_xyz_to_cube_uv(in vec3 rd, out int index, out vec2 uv)
{
    int Front_side = 0;
    int Back_side = 1;
    int Up_side = 2;
    int Down_side = 3;
    int Left_side = 4;
    int Right_side = 5;
    
    uv = vec2(0.);
    index = -1;
    if(length(rd)<0.0001)return;
    
    vec3 a = abs(rd);
    bvec3 ip = greaterThan(rd,vec3(0.));
    vec2 uvc = vec2(0.);
    if (ip.x && a.x >= a.y && a.x >= a.z) {uvc.x = -rd.z;uvc.y = rd.y;
    uv = vec2(0.5 * (uvc / a.x + 1.)); index = Front_side;return;
    }else
    if (!ip.x && a.x >= a.y && a.x >= a.z) {uvc.x = rd.z;uvc.y = rd.y;
    uv = vec2(0.5 * (uvc / a.x + 1.)); index = Back_side;return;
    }else
    if (ip.y && a.y >= a.x && a.y >= a.z) {uvc.x = rd.x;uvc.y = -rd.z;
    uv = vec2(0.5 * (uvc / a.y + 1.)); index = Up_side;return;
    }else
    if (!ip.y && a.y >= a.x && a.y >= a.z) {uvc.x = rd.x;uvc.y = rd.z;
    uv = vec2(0.5 * (uvc / a.y + 1.)); index = Down_side;return;
    }else
    if (ip.z && a.z >= a.x && a.z >= a.y) {uvc.x = rd.x;uvc.y = rd.y;
    uv = vec2(0.5 * (uvc / a.z + 1.)); index = Left_side;return;
    }else
    if (!ip.z && a.z >= a.x && a.z >= a.y) {uvc.x = -rd.x;uvc.y = rd.y;
    uv = vec2(0.5 * (uvc / a.z + 1.)); index = Right_side;return;
    }
}

vec4 get_grid_color(vec3 p){
    int side_idx; vec2 side_uv;
    convert_xyz_to_cube_uv(p, side_idx, side_uv);
    side_uv+=-.5;
    vec3 side_col = vec3(0.);
    
    vec3 Front_side_col = vec3(1.,0.,0.);
    vec3 Back_side_col = vec3(0.,1.,1.);
    vec3 Up_side_col = vec3(0.,1.,0.);
    vec3 Down_side_col = vec3(1.,0.,1.);
    vec3 Left_side_col = vec3(1.,1.,0.);
    vec3 Right_side_col = vec3(0.,0.,1.);
    
    int Front_side = 0;
    int Back_side = 1;
    int Up_side = 2;
    int Down_side = 3;
    int Left_side = 4;
    int Right_side = 5;
    if(Front_side == side_idx)side_col = Front_side_col;else
    if(Back_side == side_idx)side_col = Back_side_col;else
    if(Up_side == side_idx)side_col = Up_side_col;else
    if(Down_side == side_idx)side_col = Down_side_col;else
    if(Right_side == side_idx)side_col = Right_side_col;else
    if(Left_side == side_idx)side_col = Left_side_col;
    return vec4(grid(side_uv, 0.005, side_idx, side_col).rgb,1.);
}

// --------------


void BoxIntersectMin_minimal_inv(vec3 ro, vec3 rd, vec3 box, vec3 opos, inout bool result, inout HitInfo hit) {
    float tnew;
    vec3 normnew;
    //bool inbox = false;
    //inbox=(abs(ro-opos).x<box.x*0.5&&abs(ro-opos).y<box.y*0.5&&abs(ro-opos).z<box.z*0.5);
    
    if (BoxIntersect_min_inv(ro, rd, opos, box, tnew, normnew)) {
        if (tnew < hit.t) {
            hit.t = tnew;
            hit.norm = normnew;
            
            hit.color = vec4(normnew,1.);
            hit.color = get_grid_color(ro+rd*tnew);
            hit.obj_type = OBJ_BOX;
            result = true;
        }
    }
}

void BoxIntersectMin_minimal(vec3 ro, vec3 rd, vec3 box, vec3 opos, inout bool result, inout HitInfo hit) {
    float tnew;
    vec3 normnew;
    bool inbox = false;
    inbox=(abs(ro-opos).x<box.x*0.5&&abs(ro-opos).y<box.y*0.5&&abs(ro-opos).z<box.z*0.5);
    bool intr;
    if(inbox)intr=BoxIntersect_min_inv(ro, rd, opos, box, tnew, normnew);
    else intr=BoxIntersect_min(ro, rd, opos, box, tnew, normnew);
    if (intr) {
        if (tnew < hit.t) {
            hit.t = tnew;
            hit.norm = normnew;
            
            hit.color = vec4(normnew,1.);
            hit.obj_type = OBJ_BOX;
            result = true;
        }
    }
}



bool minDist(vec3 ro, vec3 rd, out HitInfo hit)
{
    hit.t = MAX_DIST;
    hit.obj_type = OBJ_SKY;
    hit.color=vec4(background_sky(rd),1.);
    bool result = false;

    GroundIntersectMin(ro, rd, result, hit);
    

    vec3 box0=vec3(-12.33,2.25,6.25);
    vec3 box01=vec3(12.33,2.25,6.25);
    vec3 box1=vec3(-0.0,0.0,0.0);
    BoxIntersectMin_minimal(ro, rd,vec3(2.),box0,result, hit);
    BoxIntersectMin_minimal(ro, rd,vec3(2.),box01,result, hit);
    BoxIntersectMin_minimal_inv(ro, rd,vec3(2.),box1,result, hit);

    return result;
}

const float eps = 1e-3;

vec3 render(vec3 ro, vec3 rd)
{
    vec3 col = vec3(0.0);
    vec3 objectcolor = vec3(1.0);
    vec3 mask = vec3(1.0);
    HitInfo hit;
    hit.color=vec4(0.);
    {
        if(minDist(ro, rd, hit)){
            objectcolor = hit.color.rgb;
            vec3 p = ro + rd * hit.t + hit.norm*eps;
            vec3 l1Pos = vec3(2,1,0);
            vec3 sunDir = normalize(l1Pos-p);
            col = objectcolor;
        }else col = background_sky(rd);
    }
    return col;
}

void panorama_screen_uv_to_rd(vec2 uv, out vec3 rd){
    float M_PI = 3.1415926535;
    float ymul = 2.0; float ydiff = -1.0;
    uv.x = 2.0 * uv.x - 1.0;
    uv.y = ymul * uv.y + ydiff;
    rd=vec3(0.0, 0.0, 1.0)*rotx(-uv.y*M_PI/2.0)*roty(-uv.x*M_PI);
    if(length(rd)<0.0001)rd+=0.0001;
    rd = normalize(rd);
}






