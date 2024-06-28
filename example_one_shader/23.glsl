#define T iDate.w
#define r(p, a) {p*= mat2(cos(a + .8*vec4(6,0,0,2)));}
float m(vec3 p)
{
    p.z -= T+T;
    p = mod(p, 2.)-1.;
    p *= .5;
    r(p.xy, p.z + T);
    return length(max(abs(p)-.5*vec3(.5, .3, .8), 0.));
}

void mainImage(out vec4 f,vec2 g)
{
	g = -abs(g+g-(g.xy=iResolution.xy))/g.y;
    vec3 r = vec3(0, 0, 1), d = vec3(g, -1), p;
    r(d.xz, T);
    r(d.yz, -T);
    r(d.xy, T);
    float t = 0., h;
    for (int i = 0; i < 99; i++)
    {
        p = r + d * t;
        h = m(p);
        t += h;
        if (h < .005 || t > 40.) break;
    }
    f.rgb = abs(p);
}