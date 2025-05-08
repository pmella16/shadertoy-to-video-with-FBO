#define time iTime
#define resolution iResolution
vec3 pos;
float it;

mat2 rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c,s,-s,c);
}

float sph;

vec3 path(float t) {
    vec3 p= vec3(sin(t*.5+cos(t*.2))*3.,cos(t),t);
    p.y+=smoothstep(-2.,2.,sin(t*.5))*2.;
    return p;
}

float de(vec3 p) {
    vec3 p2=p-pos;
    p.xy-=path(p.z).xy;
    p.xy*=rot(time);
    float d=1000.;
    float tun=length(p.xy)-1.-sin(p.z*15.)*.0;
    sph=(length(p2)-.5)-length(sin(p*5.))*.0;
    float sc=1.3;
    float der=1.;
    p*=.3;
    for (int i=0; i<6; i++) {
        p=sin(p*2.);
        der*=sc;
        p.xz*=rot(1.);
        p.xy*=rot(1.5);
        float l=length(p.xy)-.1;
        d=min(d,l);
        if (d==l) it=float(i);
    }
    d=max(d,-tun+2.);
    d=min(d,tun);
    d=max(d,-sph);
    return d*.3;
}

vec3 normal(vec3 p) {
    vec2 e=vec2(0.,.01);
    return normalize(vec3(de(p+e.yxx),de(p+e.xyx),de(p+e.xxy))-de(p));
}

vec3 march(vec3 from, vec3 dir) {
    float d, td=0.;
    vec3 p, col=vec3(0.);
    vec3 ldir=vec3(0.,1.,0.);
    bool inside=false;
    for (int i=0; i<200; i++) {
        p=from+dir*td;
        d=de(p);
        if (d<.01&&!inside) {
            inside=true;
            vec3 n=normal(p);
            vec3 ref=reflect(ldir,n);
            col+=pow(max(0.,dot(ref,dir)),20.)*.05;
        } else inside=false;
        d=max(.003,abs(d));
        if (td>100.) break;
        td+=d;
        vec3 c=.1/(.1+d*50.)*pow(fract(-p.z*.2+length(p.xy)*.2-time*.5+it*.2),1.5)*.1*vec3(1.,0.,0.);
        c*=exp(-.25*td)*3.;
        c.rb*=rot(it*.5);
        c.rg*=rot(it);
        c=abs(c);
        if (sph>.02) col+=c; else col+=.007;
    } 
    col=mix(length(col)*vec3(.5),col,.5);
    return col;
}

mat3 lookat(vec3 dir) {
    vec3 up=vec3(0.,1.,0.);
    vec3 rt=normalize(cross(dir,up));
    return mat3(rt,cross(dir,rt),dir);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t=time*2.;
    vec3 from=path(t);
    vec2 uv = (fragCoord.xy-resolution.xy*.5)/resolution.y;
    from.x+=smoothstep(0.,.8,sin(time*.5))*3.;
    vec3 adv=path(t+1.);
    pos=path(t+2.);
    vec3 dir=normalize(vec3(uv,.5));
    dir=lookat(normalize(adv-from))*dir;
    vec3 col=march(from, dir);
    fragColor = vec4(col,1.0);
}

