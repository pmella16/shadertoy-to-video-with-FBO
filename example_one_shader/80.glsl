#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.01


float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

vec3 palette(float t) {
    vec3 a = vec3(0.5);
    vec3 b = vec3(0.5);
    vec3 c = vec3(1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 rot3D(vec3 p, vec3 axis, float angle) {
    return mix(dot(axis, p) * axis, p, cos(angle)) + cross(axis, p) * sin(angle);
}

mat2 rot2D(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * h * k * (1.0 / 6.0);
} 

// 定义到球体的距离函数
// 其中p是球体的位置，s是球体的半径
float sdSphere(vec3 p, float s) {
    return length(p) - s;
}

// 定义到盒子的距离函数
// b为边长
float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)),0.0);
}

float GetDist(vec3 p) {
    p.z += iTime * 0.4;
    p.xy = fract(p.xy) - 0.5;
    p.z = mod(p.z, 0.25) - 0.125;
    float box = sdOctahedron(p, 0.15);
    return box;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 m = (iMouse.xy * 2.0 - iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0, 0, -4); // 摄像机的位置
    vec3 rd = normalize(vec3(uv, 1.0)); // 光线方向
    
    // 旋转摄像机(绕y轴旋转)
    // ro.xz *= rot2D(-m.x);
    // rd.xz *= rot2D(-m.x);
    // ro.yz *= rot2D(-m.y);
    // rd.yz *= rot2D(-m.y);
    
    float d0 = 0.0;
    int i;
    for (i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d0;
        p.xy *= rot2D(d0 * 0.2);
        p.y += sin(d0 * (m.y + 1.0) * 0.5) * 0.35;
        float ds = GetDist(p);
        d0 += ds;
        if (d0 > MAX_DIST || ds < SURF_DIST) {
            break;
        }
    }
    vec3 col = palette(d0 * 0.04 + float(i) * 0.005);

    // Output to screen
    fragColor = vec4(col,1.0);
}