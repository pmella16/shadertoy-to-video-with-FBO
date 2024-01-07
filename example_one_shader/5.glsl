// Includes and constants
#define HSV2RGB_K  vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0)
#define HSV2RGB(c) (c.z * mix(HSV2RGB_K.xxx, clamp(abs(fract(c.xxx + HSV2RGB_K.xyz) * 6.0 - HSV2RGB_K.www) - HSV2RGB_K.xxx, 0.0, 1.0), c.y))

vec4 Noise(in ivec2 x) {
    return vec4(0, (vec2(x) + 0.5) / 256.0, -100.0);
}

// Sun direction and color
vec3 sunDir = normalize(vec3(0.0, -2.0, 20.0));
const vec3 sunCol = HSV2RGB(vec3(0.01, 0.5, 0.002));

// Function for rendering the outer sky
vec3 outerSkyRender(vec3 ro, vec3 rd) {
    vec3 col = HSV2RGB(vec3(1.0, 0.00, 0.008));

  // Sun settings
    col += sunCol / pow((1.002 - dot(sunDir, rd)), 1.9);

  // Horizon light modifier
    vec3 gcol = HSV2RGB(vec3(1.0, 0.4, 0.008));
    gcol = gcol * 0.3;

  // Atmosphere air color
    col += HSV2RGB(vec3(0.97, 0.0, 0.1));
  // add glow to sky
    col += gcol / max(abs(rd.y), 0.0);
    
  // add stars to sky
    vec3 ray = vec3(2.0 * ro.xy, 1.0);
    float offset = iTime * 0.1;
    float speed = 0.2;
    vec3 stp = ray / max(abs(ray.x), abs(ray.y));
    vec3 pos = stp + 0.5;
    for (int i = 0; i < 10; i++) {
        vec2 noise = Noise(ivec2(pos.xy)).xy;
        float z = fract(noise.x - offset);
        float d = 20.0 * z - pos.z;
        float w = pow(max(0.0, 1.0 - 2.0 * length(fract(pos.xy) - 0.5)), 15.0);
        vec3 c = max(vec3(0), vec3(1.0 - abs(d + speed * 0.5) / speed, 1.0 - abs(d) / speed, 1.0 - abs(d) / speed));
        col += (1.0 - z) * c * w;
        pos += stp;
    }
    
    return col;
}

// Function for finding the intersection of a ray with a plane
float rayPlane(vec3 ro, vec3 rd, vec4 p) {
    return -(dot(ro, p.xyz) + p.w) / dot(rd, p.xyz);
}

// Function to calculate the value of an equilateral triangle
float equilateralTriangle(vec2 p) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - 1.0;
    p.y = p.y + 1.0 / k;
    if(p.x + k * p.y > 0.0)
        p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0, 0.0);
    return -length(p) * sign(p.y);
}

// Function for rendering the triangle
vec3 triRender(vec3 col, vec3 ro, vec3 rd) {
  // Triangle fill color
    vec3 fillColor = vec3(0.005, 0.0, 0.0);

  // Triangle calculations
    const vec4 tpdim = vec4(0.0, 0.0, 1.0, -2.0);
    float tpd = rayPlane(ro, rd, tpdim);
    vec3 pp = ro + rd * tpd;
    vec2 p = pp.xy;

  // Triangle resize
    p *= 0.5;

  // Triangle y offset
    p.y -= 0.58;

  // Triangle inner glow factor
    float hoff = dot(cos(0.7),p.y);
    vec3 gcol = HSV2RGB(vec3(clamp(0.1+hoff, 0.0, 0.02), 0.8, 0.005));

  // Triangle displacement
    float dt = equilateralTriangle(p);

  // Triangle to scene visibility ratio
    col -= 10.0 * gcol;
    col = dt < 0.0 ? fillColor : col;

  // Triangle edge glow modification
    col += (gcol / max(abs(dt), 0.002));
    return col;
}

// Function for rendering the ground
vec3 groundRender(vec3 col, vec3 ro, vec3 rd) {
    const vec3 gpn = normalize(vec3(0.0, 1.0, 0.0));
    const vec4 gpdim = vec4(gpn, 0.0);
    float gpd = rayPlane(ro, rd, gpdim);

    if(gpd < 0.0) {
        return col;
    }

  // Tiles reflection modifier
    vec3 gp = ro + rd * gpd;
    float gpfre = 1.15 + dot(rd, gpn);
    gpfre *= gpfre;
    gpfre *= gpfre;

    vec3 grr = reflect(rd, gpn);

    vec2 ggp = gp.xz;
    ggp.y += iTime;
    float dfy = dFdy(ggp.y);
    float gcf = sin(ggp.x) * sin(ggp.y);
    vec2 ggn;

  // Calculate the modulus
    vec2 c = floor(ggp);
    ggp = mod(ggp + vec2(0.5), vec2(1.0)) - vec2(0.5);
    ggn = c;

    float ggd = min(abs(ggp.x), abs(ggp.y));

  // Tiles lines color modifier
    vec3 gcol = HSV2RGB(vec3(0.01 * gcf, 0.7, 0.005));

    vec3 rcol = outerSkyRender(grr, grr);
    rcol = triRender(rcol, gp, grr);

  // Tiles calculations
    col = gcol / max(ggd, 0.0 + 0.25 * dfy) * exp(-0.25 * gpd);

  // Ground horizon reflection color filter
    rcol += HSV2RGB(vec3(0.0, 0.0, 0.0));
  // Ground reflection factor
    col += rcol * gpfre / 2.0;

    return col;
}

// Main image rendering function
void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    const float fov = 2.0;
    vec3 ro = 1.0 * vec3(0.0, 0.5, -5.0);  // Camera location
    vec3 la = vec3(0.0, 1.5, 0.0);          // Camera look at
    vec3 up = vec3(0.0, 1.0, 0.0);           // Up vector

  // Calculate camera coordinate system
    vec3 ww = normalize(la - ro);
    vec3 uu = normalize(cross(up, ww));
    vec3 vv = cross(ww, uu);

  // Convert and adjust pixel coordinates
    vec2 q = (fragCoord / iResolution.xy - 0.5) * 2.0;
    vec2 p = q * vec2(iResolution.x / iResolution.y, 1.0);
    vec2 pp = p;

  // Calculate ray direction
    vec3 rd = normalize(-p.x * uu + p.y * vv + fov * ww);

  // Rendering process
    vec3 col = outerSkyRender(rd, rd);
    col = groundRender(col, ro, rd);
    col = triRender(col, ro, rd);

  // Set the final pixel color
    fragColor = vec4(col, 1.0);
}
