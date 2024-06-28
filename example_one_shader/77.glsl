mat2 rot(float amt) {
    float c = cos(amt);
    float s = sin(amt);
    return mat2(c,-s,s,c);
}

float sminCubic( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

#if 1
// this is inexplicably faster than the other branch on my machine
float voronoi(vec2 uv, float softness) {
    vec2 pos = uv;
    vec2 innerPos = mod(pos, 1.0);
    vec2 index = floor(pos);
 
    float minDistance;
    #define smc(a,b) sminCubic(a,b,softness)
    minDistance = distance(innerPos, vec2(-1.0, -1.0) + hash22(index + vec2(-1.0, -1.0)));
    minDistance = smc(minDistance, distance(innerPos, vec2(-1.0,  0.0) + hash22(index + vec2(-1.0,  0.0))));
    minDistance = smc(minDistance, distance(innerPos, vec2(-1.0,  1.0) + hash22(index + vec2(-1.0,  1.0))));
    
    minDistance = smc(minDistance, distance(innerPos, vec2(0.0, -1.0) + hash22(index + vec2(0.0, -1.0))));
    minDistance = smc(minDistance, distance(innerPos, vec2(0.0,  0.0) + hash22(index + vec2(0.0,  0.0))));
    minDistance = smc(minDistance, distance(innerPos, vec2(0.0,  1.0) + hash22(index + vec2(0.0,  1.0))));
    
    minDistance = smc(minDistance, distance(innerPos, vec2(1.0, -1.0) + hash22(index + vec2(1.0, -1.0))));
    minDistance = smc(minDistance, distance(innerPos, vec2(1.0,  0.0) + hash22(index + vec2(1.0,  0.0))));
    minDistance = smc(minDistance, distance(innerPos, vec2(1.0,  1.0) + hash22(index + vec2(1.0,  1.0))));
    return smoothstep(0.0, 1.0,minDistance);
}
#else
// IQ's smooth voronoi
float voronoi( in vec2 x, float w )
{
    vec2 n = floor( x );
    vec2 f = fract( x );

	float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
        vec2 o = hash22( n + g );

        // distance to cell		
		float d = length(g - f + o);
        	
		float h = smoothstep( -1.0, 1.0, (md-d)/w );
	    md   = mix( md,     d, h ) - h*(1.0-h)*w/(1.0+3.0*w);
    }
	
	return smoothstep(0.0, 1.0, md);
}
#endif


float smoothmap(float x, float inMin, float inMax, float outMin, float outMax) {
    return mix(outMin, outMax, smoothstep(inMin, inMax, x));
}

vec3 smoothmap13(float x, float inMin, float inMax, vec3 outMin, vec3 outMax) {
    return mix(outMin, outMax, smoothstep(inMin, inMax, x));
}

float fmod(float x, float m) {
    return x - m * floor(x / m);
}

float angleVoronoi(vec2 uv, vec2 scale, vec2 offset, float smoothness) {
    float theta = 0.5 + atan(uv.y, uv.x) / (2.0 * acos(-1.0));
    float phi = length(uv);
    vec2 auv = vec2(theta, phi);
    auv += offset;
    
    vec2 pos = auv * scale;
    vec2 innerPos = mod(pos, 1.0);
    vec2 index = floor(pos);
 
    float minDistance = 1e3;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 cellPos = offset + hash22(
                vec2(
                    fmod(index.x + offset.x, scale.x),
                    index.y + offset.y
                )
            );
            float cellDistance = distance(innerPos, cellPos);
            minDistance = sminCubic(minDistance, cellDistance, smoothness);
        }
    }
    return minDistance;
}

float angleVoronoiSharp(vec2 uv, vec2 scale, vec2 offset) {
    float theta = 0.5 + atan(uv.y, uv.x) / (2.0 * acos(-1.0));
    float phi = length(uv);
    vec2 auv = vec2(theta, phi);
    auv += offset;
    
    vec2 pos = auv * scale;
    vec2 innerPos = mod(pos, 1.0);
    vec2 index = floor(pos);
 
    float minDistance = 1e3;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 cellPos = offset + hash22(
                vec2(
                    fmod(index.x + offset.x, scale.x),
                    index.y + offset.y
                )
            );
            float cellDistance = distance(innerPos, cellPos);
            minDistance = min(minDistance, cellDistance);
        }
    }
    return minDistance;
}

float voronoiSharp(vec2 uv) {
    vec2 pos = uv;
    vec2 innerPos = mod(pos, 1.0);
    vec2 index = floor(pos);
 
    float minDistance = 1e4;
    for (float x = -1.0; x <= 1.0; x += 1.0) {
        for (float y = -1.0; y <= 1.0; y += 1.0) {
            vec2 offset = vec2(x, y);
            vec2 cellPos = hash22(index + offset);
            vec2 diff = innerPos - (cellPos + offset);
            float sd = dot(diff, diff);
            minDistance = min(minDistance, sd);
        }
    }
    return sqrt(minDistance);
}
const float MAX_DIST = 50.0;
const float PI = 3.14159;
// #define ANTIALIAS

float height(vec2 xz) {
    float waves = 0.35 * sin(0.5 * (xz.x + xz.y));
    vec2 offset = vec2(0.5, iTime * 0.1);
    float softness = smoothmap(length(xz), 0.0, 12.0, 3.0, 2.0);
    float dunes = 1.5 * pow(angleVoronoi(xz, vec2(24.0,0.7), offset, 0.1),softness);
    
    float sl = dot(xz, xz);
    float flattening = smoothstep(9.0, 64.0, sl);
    float depression = pow(1.0 - smoothstep(0.0,72.0,sl), 0.5) * -4.0;
    float sinkhole = pow(1.0 - smoothstep(0.0,32.0,sl), 2.0) * -12.0;
    
    return depression + sinkhole + flattening * (waves + dunes);
}

float heightFine(vec2 xz) {
    float flattening = smoothstep(16.0, 64.0, dot(xz, xz));
    return height(xz) + flattening * 0.125 * angleVoronoi(xz, vec2(50.0,2.0), vec2(0.0), 0.4);
}

float heightNormal(vec2 xz) {
    float baseHeight = heightFine(xz);
    float scale = 0.0025;
    float disp = scale * 
        angleVoronoiSharp(
            xz,
            25.0 * vec2(16.0, 1.0),
            vec2(0.0, iTime * 0.5)
    ) - (scale * 0.5);
    return baseHeight + disp;
}

float marchHeightmap(vec3 ro, vec3 rd) {
    // discard ray if it'll never hit the terrain
    // (max heights of each step)
    const float maxHeight = 0.35 + 1.5 + 0.125 + 0.0025;
    float endHeight = ro.y + rd.y * MAX_DIST;
    if (endHeight > maxHeight) {
        return MAX_DIST;
    }
    
    // coarse march
    float stepSize = MAX_DIST / 300.0;
    float dist;
    for (dist = 0.0; dist < MAX_DIST; dist += stepSize) {
        vec3 pos = ro + rd * dist;
        float sampledHeight = height(pos.xz);
        if (pos.y < sampledHeight) {
            break;
        }
    }
    
    if (dist >= MAX_DIST) {
        return dist;
    }
    
    // step back and march fine
    // this technique fails on thin edges, since the coarse march
    // misses them entirely, but is a good tradeoff of quality versus speed
    float fineStepSize = stepSize / 15.0;
    float fineDist;
    for (
        fineDist = dist - stepSize;
        fineDist < dist;
        fineDist += fineStepSize
    ) {
        vec3 pos = ro + rd * fineDist;
        float sampledHeight = height(pos.xz);
        if (pos.y < sampledHeight) {
            break;
        }
    }
    
    return fineDist;
}

vec3 normal(vec2 xz) {
    // https://stackoverflow.com/questions/5281261/generating-a-normal-map-from-a-height-map
    const vec2 eps = vec2(0.005, 0.0);
    float x = heightNormal(xz - eps) - heightNormal(xz + eps);
    float z = heightNormal(xz - eps.yx) - heightNormal(xz + eps.yx);
    float dist = eps.x * 2.0;
    x /= dist;
    z /= dist;
    return normalize(vec3(x, 1.0, z));
}

vec3 sky(vec3 dir) {
    // angle
    float theta = (atan(dir.z, dir.x) / PI) * 0.5 + 0.5;
    float phi = acos(dir.y) / PI;
    
    // general color
    vec3 side = vec3(0.89,0.68,0.47);
    vec3 top = vec3(0.25, 0.18, 0.13);
    
    vec3 skyColor = mix(top, side, phi * 2.0);
    
    // stars
    vec2 coords = vec2(theta, phi);
    float fade = distance(coords, vec2(0.75,0.3));
    fade = smoothstep(0.3,0.075,fade) * 0.8;
    
    coords *= 500.0;
    coords += iTime * vec2(0.1,0.05);
    
    float stars = voronoiSharp(coords);
    stars = 1.0 - smoothstep(0.0, 0.1, stars);
    
    vec3 fadeColor = mix(
        vec3(0.05,0.05,0.06),
        vec3(1.0),
        stars
    );
    
    return mix(skyColor, fadeColor, fade); // vec3(1.0 - smoothstep(0.0,0.1,stars));
}

vec3 shade(
    vec3 rd,
    float depth,
    vec3 pos,
    vec3 norm
) { 
    if (depth >= MAX_DIST) {
        return sky(rd);
    }
    
    vec3 sunDir = normalize(vec3(1.0,1.0,1.0));
    float fog = smoothstep(5.0, MAX_DIST, depth);
    
    vec3 sunColor = smoothmap13(
        dot(norm, sunDir),
        -1.0,
        1.0,
        0.25 * vec3(0.73, 0.26, 0.08),
        vec3(0.96, 0.5, 0.2)
    );
    
    vec3 heightColor = smoothmap13(
        pos.y,
        0.0,
        2.0,
        vec3(0.7,0.6,0.6),
        vec3(1.0)
    );
    
    vec3 diffuseColor = sunColor * heightColor;
    
    float specularFactor = pow(max(0.0, dot(reflect(rd, norm), sunDir)), 4.0);
    vec3 specularColor = vec3(0.15, 0.1, 0.1) * specularFactor;
    
    float holeFactor = smoothstep(-10.0, -4.0, pos.y);
    vec3 holeColor = 0.3 * vec3(0.7,0.3,0.1);
    
    vec3 baseColor = diffuseColor + specularColor;
    return mix(holeColor, mix(baseColor, sky(rd), fog), holeFactor);
}

void cameraRay(vec2 uv, out vec3 ro, out vec3 rd) {
    float z = -1.0 + 0.25 * sin(uv.x * 3.14159);
    ro = vec3(0.0, 0.0, z);
    rd = normalize(vec3(2.0 * (uv - 0.5), 0.0) - ro);
    
    ro.y = 3.0;
    ro.z -= 10.0;
}

vec3 mainSample(vec2 uv) {
    vec3 ro, rd;
    cameraRay(uv, ro, rd);
    
    float depth = marchHeightmap(ro, rd);
    
    vec3 pos = ro + rd * depth;
    
    vec3 col = shade(rd, depth, pos, normal(pos.xz));
    return sqrt(col);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    #ifdef ANTIALIAS
    vec3 offset = vec3(0.5 / iResolution.xy, 0.0);
    vec3 color = mainSample(uv);
    color += mainSample(uv + offset.xz);
    color += mainSample(uv + offset.zy);
    color += mainSample(uv + offset.xy);
    color *= 0.25;
    fragColor = vec4(color, 1.0);
    #else
    fragColor = vec4(mainSample(uv), 1.0);
    #endif
}