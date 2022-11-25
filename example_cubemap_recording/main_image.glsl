
// set this define PANORAMA_REC when use as image
// mainImage doing 12x texture filtering, remove if not needed (rename mainImage_orig back to mainImage)

// https://www.shadertoy.com/view/DdfXzj

#define PANORAMA_REC

#ifdef PANORAMA_REC

// no need to change order
/*
#define iChannel0 u_channel0
#define iChannel1 u_channel1
#define iChannel2 u_channel2
#define iChannel3 u_channel3
#define iChannel4 u_channel4
#define iChannel5 u_channel5
*/





mat3 rotx(float a){float s = sin(a);float c = cos(a);return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c));  }
mat3 roty(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, 0.0, s), vec3(0.0, 1.0, 0.0), vec3(-s, 0.0, c));}
mat3 rotz(float a){float s = sin(a);float c = cos(a);return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0 ));}


// --------------

// return rd in Equirectangular projection
// uv is screen space
void panorama_screen_uv_to_rd(vec2 uv, out vec3 rd){
    float M_PI = 3.1415926535;
    float ymul = 2.0; float ydiff = -1.0;
    uv.x = 2.0 * uv.x - 1.0;
    uv.y = ymul * uv.y + ydiff;
    rd=vec3(0.0, 0.0, 1.0)*rotx(-uv.y*M_PI/2.0)*roty(-uv.x*M_PI);
    if(length(rd)<0.0001)rd+=0.0001;
    rd = normalize(rd);
}

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

void mainImage_orig( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 rd;
    fragColor = vec4(0.0,0.0,0.0,0.0);
    vec2 uv=fragCoord/iResolution.xy;
    panorama_screen_uv_to_rd(uv, rd);
    vec2 side_uv;int index;
    convert_xyz_to_cube_uv(rd, index, side_uv);
    if(index==0)fragColor = textureLod(iChannel0,side_uv,0.);
    if(index==1)fragColor = textureLod(iChannel1,side_uv,0.);
    if(index==2)fragColor = textureLod(iChannel2,side_uv,0.); // switch 2 to 3 and 3 to 2 if need to swap top/bot side
    if(index==3)fragColor = textureLod(iChannel3,side_uv,0.); // switch 2 to 3 and 3 to 2 if need to swap top/bot side
    if(index==4)fragColor = textureLod(iChannel4,side_uv,0.);
    if(index==5)fragColor = textureLod(iChannel5,side_uv,0.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec4 tcol=vec4(0.);
    const int AA=12;
    fragCoord.x=iResolution.x-floor(fragCoord.x)+0.5-1.; //flip if needed
    fragCoord.y=iResolution.y-floor(fragCoord.y)+0.5-1.; //flip if needed
    for( int mx=0; mx<AA; mx++ )
    for( int nx=0; nx<AA; nx++ )
    {
        vec2 o = vec2(float(mx),float(nx)) / float(AA) - 0.5;
        mainImage_orig(fragColor,fragCoord+o);
        tcol+=clamp(fragColor,0.,1.);
    }
    fragColor=tcol/float(AA*AA);
    fragColor.a=1.;
}




#else

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0.0,0.0,1.0,1.0);
}

#endif








