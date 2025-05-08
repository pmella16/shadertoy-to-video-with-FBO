// 乱数
#define hash(x) (tan(x) * 43758.5453123)

const float PI = acos(-1.);
const float PI2 = PI * 2.;
//const float BPM = 140.;
const float BPM = 12.;
float reTime; // 速さに変化をつけた時間

// 2Dの乱数
float hash12(vec2 p) {
    return hash(dot(p, vec2(1.9898, 78.233)));
}

// 2Dの回転行列
mat2 rotate2D(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, s, -s, c);
}

// HSVからRGBへの変換
vec3 hsv(float h, float s, float v) {
    vec3 res = fract(h + vec3(0, 2, 1) / 3.);
    res = clamp(abs(res * 6. - 3.) - 1., 0., 1.);
    res = (res - 1.) * s + 1.;
    return res * v;
}

// レイを算出
vec3 rayDir(vec2 uv, vec3 dir, float fov) {
    dir = normalize(dir);
       
    vec3 u = abs(dir.y) < 0.999 ? vec3(0, 1, 0) : vec3(0, 0, 1);
    vec3 side = normalize(cross(dir, u));
    vec3 up = cross(side, dir);
    return normalize(uv.x * side + uv.y * up + dir / tan(fov / 360. * PI));
}

// トーラスの距離関数
float sdTorus(vec3 p, float R, float r) {
    return length(vec2(p.z, length(p.xy) - R)) - r;
}

// 距離関数の値が小さい方の距離とIDを返す
vec3 opU(vec3 d1, vec3 d2) {
    return d1.x < d2.x ? d1 : d2;
}

vec3 myround(vec3 v) {
    return floor(v + 0.5);
}

float myround(float x) {
    return floor(x + 0.5);
}

#define Q(p) p *= 2.*r(myround(atan(p.x, p.y) * 4.) / 4.)
#define r(a) mat2(cos(a + asin(vec4(0,1,-1,0))))
float sdSuperChain(vec3 p, out vec3 ID) {
    ID.xz = floor(p.xz / 2.) * 2.;
    
    p.xz = mod(p.xz, 2.) - 1.;
    vec2 s = sign(p.xz);
    ID.y = s.x * s.y;
  p.xy*=rotate2D(iTime*0.5);
    p.xz = abs(p.xz) - 0.5;

    const float R = 0.85;
    const float a = 0.4;
    const float r = 0.07;
    
    vec4 t1 = vec4(p.xz - 0.5, p.xz + 0.5);
    vec4 t2 = t1 * t1 * a;
    
    float d1 = sdTorus(vec3(t1.xy, p.y - (t2.x - t2.y)), R, r);
    float d2 = sdTorus(vec3(t1.yz, p.y - (t2.y - t2.z)), R, r);
    float d3 = sdTorus(vec3(t1.zw, p.y - (t2.z - t2.w)), R, r);
    float d4 = sdTorus(vec3(t1.wx, p.y - (t2.w - t2.x)), R, r);
    
    vec3 res = vec3(d1, ID.xz + s);

    res = opU(res, vec3(d2, ID.xz + vec2(0, s.y)));
    res = opU(res, vec3(d3, ID.xz));
    res = opU(res, vec3(d4, ID.xz + vec2(s.x, 0)));
    ID.xz = res.yz;
    
    return res.x;
}

// 参考: Log-polar Mapping in 3D
// https://www.osar.fr/notes/logspherical/
const float N = 10.;
vec3 logPolar(vec3 p, out float mul) {
    float L = length(p.xz);
       
    p.xz = vec2(log(L), atan(p.z, p.x));
    float scale = N / PI / sqrt(2.);
    mul = L / scale;
    p *= scale;
    p.y /= L;
    return p;
}

// 距離関数
float map(vec3 p, out vec3 ID) {
    float d;
     p.xz*=rotate2D(iTime*0.5);
   Q(p.xz);
    float mul;
    p = logPolar(p, mul);
    d = p.y; // 床
    p.y -= 0.4;
    p.xz*=rotate2D(iTime*0.5);
    d = min(d, sdSuperChain(p, ID));
  
;
    

    ID.xz -= floor(dot(ID.xz, vec2(0.5 / N))) * N;
    
    return d * mul;
}

// 法線ベクトルを算出
vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0);
   // y軸からの距離に比例してオブジェクトが大きくなるため
    vec3 ID;
    return normalize(vec3(map(p + e.xyy, ID) - map(p - e.xyy, ID),
                          map(p + e.yxy, ID) - map(p - e.yxy, ID),
                          map(p + e.yyx, ID) - map(p - e.yyx, ID)));
}

// オブジェクトの色を計算
vec3 calcColor(vec3 p, vec3 ID) {
    if(p.y < 0.01) {
        return mix(vec3(0.05), vec3(0.9), ID.y * 0.5 + 0.5);
    }
    float h = hash12(ID.xz);
    return hsv(h, 0.8, 1.);
}

// Fresnel反射率のSchlickによる近似
float fresnelSchlick(float f0, float cosTheta) {
    return f0 + (1. - f0) * pow(1. - cosTheta, 5.);
}

// レイマーチング
vec3 raymarch(inout vec3 ro, inout vec3 rd, inout bool hit, inout vec3 refAtt) {
    vec3 col = vec3(0);
    float t = 0.; // オブジェクトの表面まで伸ばしたレイの長さ
    hit = false;
    vec3 far = vec3(0.6, 0.7, 0.9) * 0.1; // 遠景のフォグの色
    vec3 ID; // リングのID
    
    for(int i = 0; i < 100; i++) {
        float d = map(ro + t * rd, ID);
        if(abs(d) < 0.001) {
            hit = true;
            break;
        }
        if(t > 1e3) {
            return far;
        }
        t += d * 0.75;
    }
      Q(ro.xy);
    ro += t * rd; // レイをオブジェクトの表面まで伸ばす
       ro.xz*=rotate2D(iTime*0.5);
    vec3 albedo = calcColor(ro, ID); // アルベド
    albedo.xz*=rotate2D(iTime*0.5);
    vec3 n = calcNormal(ro); // 法線ベクトル
      n.xz*=rotate2D(iTime*0.5);
    vec3 ld = normalize(vec3(2, 5, -1)); // 平行光源の向き
          ld.xz*=rotate2D(iTime*0.5);
    float diff = max(dot(n, ld), 0.); // 直接光による拡散反射
    float spec = pow(max(dot(reflect(ld, n), rd), 0.), 20.); // 直接光による鏡面反射
    float invFog = exp(-t * t * 0.000); // フォグ
  
    //float lp = pow(sin(reTime * 2. + h * PI2) * 0.5 + 0.5, 1000.) * 300.;
    float lp = ro.y ;
    col += albedo * (mix(diff, spec, 0.95) * (5. + lp) + 0.01);
    col = mix(far, col, invFog);
    
    vec3 ref = reflect(rd, n);
    col *= refAtt;
    
    refAtt *= albedo * fresnelSchlick(0.8, dot(ref, n)) * invFog; // 反射の減衰率を更新
    
    ro += 0.01 * n;
    rd = ref;
    
    return col;
}

// 範囲[-1, 1.]の間で等間隔にn個の値を取る滑らかな階段状のノイズ
float stepNoise(float x, float n) {
    const float factor = 0.2;
    float i = floor(x);
    float f = x - i;
    float u = smoothstep(0.5 - factor, 0.5 + factor, f);
    float res = mix(floor(hash(i) * n), floor(hash(i + 1.) * n), u);
    res /= (n - 1.) * 0.5;
    return res - 1.;
}

// ルーマ（色をグレースケールに変換）
float luma(vec3 col) {
    return dot(col, vec3(0.299, 0.587, 0.114));
}

// 三角波
float triWave(float x) {
    //x -= 0.5;
    //x *= 0.5;
    float res = abs(fract(x) - 0.5) - 0.25;
    return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 画面上の座標を正規化
    vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
    uv -= 0.5;
    uv /= vec2(iResolution.y / iResolution.x, 1) * 0.5;
    
    vec3 col = vec3(0); // 色
    


    //reTime = Time + triWave(Time * 1. + 0.5) * 0.9;
    
    vec3 ro = vec3(0, 4, 3); // カメラの位置(レイの原点)

    vec3 ta = vec3(0); // カメラのターゲットの座標

    vec3 dir = ta - ro; // カメラの向き
    float fov = 60.; // 視野角
 
    vec3 rd = rayDir(uv, dir, fov); // レイの向き
    
    bool hit = false;
    vec3 refAtt = vec3(1); // 反射の減衰率
    for(int i = 0; i < 3; i++) {
        col += raymarch(ro, rd, hit, refAtt);
        if(!hit) {
            break;
        }
    }
    
    col = pow(col, vec3(1. / 2.2)); // ガンマ補正
    
    // 口径食（vignetting）
    vec2 p = fragCoord.xy / iResolution.xy;
    col *= 0.5 + 0.5 * pow(16. * p.x * p.y * (1. - p.x) * (1. - p.y), 0.5);
    
    // RGBずらし（色収差）
    float lu = luma(col);
    vec2 dis = (p - 0.5) * 0.05;

    
    fragColor = vec4(col, lu);
}