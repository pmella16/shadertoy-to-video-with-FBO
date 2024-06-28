// Winning shader made at Nova 2019 Shader Showdown,
// First round round against LovelyHannibal / Amnesty
// Video of the battle: https://youtu.be/xegAFqulK8I?t=319

// The "Shader Showdown" is a demoscene live-coding shader battle competition.
// 2 coders battle for 25 minutes making a shader on stage. No google, no cheat sheets.
// The audience votes for the winner by making noise or by voting on their phone.

// "It turns out that if you bang 2 halves of a horse together, it does not make the sound of a coconut." Sir Ken Dodd

vec2 s,e=vec2(.00035,-.00035);float t,tt,att,g,f;vec3 np;
#define pi acos(-1.)
float bo(vec3 p,vec3 r){p=abs(p)-r;return max(max(p.x,p.y),p.z);}
mat2 r2(float r){return mat2(cos(r),sin(r),-sin(r),cos(r));}
vec2 fb( vec3 p)
{
    vec2 h,t=vec2(bo(abs(p)-vec3(3,0,0),vec3(1)),3);
    t.x=min(bo(p,vec3(3,.5,.5)),t.x);
    h=vec2(bo(abs(abs(p)-vec3(3,0,0))-vec3(.4,0,.4),vec3(.3,1.2,.3)),5);
    h.x=min(bo(abs(p)-vec3(1,0,0),vec3(.1,100,.1)),h.x);
    h.x=min(length(p-vec3(0,att*.3,0))-2.5,h.x);
    t=t.x<h.x?t:h;
    h=vec2(bo(p,vec3(10,.3,.7)),6);
    t=t.x<h.x?t:h;
    p.xz*=r2(pi/2.+sin(tt)*pi);
    h=vec2(bo(abs(p)-vec3(2,2,0),vec3(10,0,0)),6);
    g+=0.1/(0.1+h.x*h.x*10.);
    t=t.x<h.x?t:h;
    t.x*=.5;  
    return t;
}
vec2 mp( vec3 p)
{
    p.yz*=r2(sin(p.x*.1+tt)*.75);
    np=p;
    np.x=mod(np.x-tt*5.,10.)-5.;
    att=min(length(p)-(10.+f*6.),15.);
    for(int i=0;i<6;i++){
        np=abs(np)-vec3(2,2,0)-att*.3;
        np.xz*=r2(.3-att*.02);
    }
    vec2 h,t=fb(np);
    h=vec2(.7*bo(p,vec3(1,100,1)),6);
    t=t.x<h.x?t:h;
    return t;
}
vec2 tr( vec3 ro, vec3 rd)
{
    vec2 h,t=vec2(.1);
    for(int i=0;i<128;i++){
        h=mp(ro+rd*t.x);
        if(t.x<.0001||t.x>70.) break;
        t.x+=h.x;t.y=h.y;    
    }
    if(t.x>70.) t.x=0.;
    return t;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = vec2(fragCoord.x/iResolution.x,fragCoord.y/iResolution.y);
    uv -= 0.5;uv/=vec2(iResolution.y/iResolution.x,1);
    tt=mod(iTime*.6,37.7);
    //f=abs(sin(tt))*texelFetch( iChannel1, ivec2(200,0), 0 ).x; 
    vec3 ro=vec3(10,cos(tt)*10.,sin(tt)*40.),
        cw=normalize(vec3(0)-ro),
        cu=normalize(cross(cw,vec3(0,1,0))),
        cv=normalize(cross(cu,cw)),
        rd=mat3(cu,cv,cw)*normalize(vec3(uv,.5)),co,fo,ld=normalize(vec3(.1,.3,-.1));
    co=fo=vec3(.5)*(1.-(length(uv)-.4));
    s=tr(ro,rd);t=s.x;
    if(t>0.){
        vec3 po=ro+rd*t,no=normalize(e.xyy*mp(po+e.xyy).x+e.yyx*mp(po+e.yyx).x+e.yxy*mp(po+e.yxy).x+e.xxx*mp(po+e.xxx).x),
            al=vec3(1,.5,0);
        if(s.y<5.) al=vec3(0);
        if(s.y>5.) al=vec3(1);
        float dif=max(0.,dot(no,ld)),aor=t/50.,ao=exp2(-2.*pow(max(0.,1.-mp(po+no*aor).x/aor),2.)),
            spo=exp2(5.*1.0),
            fr=pow(1.+dot(no,rd),4.),
            sss=0.5+smoothstep(0.,1.,mp(po+ld*.4).x/.4),
            sp=pow(max(dot(reflect(-ld,no),-rd),0.),spo);    
        co=mix(sp+al*(.2+ao)*(dif+sss),fo,min(fr,.5));
        co=mix(co,fo,1.-exp(-.00002*t*t*t));
    }
    fragColor = vec4(pow(co+g*.3*vec3(.2,.3,.9),vec3(.45)),1);
}