#define PI 3.141592653589792
#define r iResolution.xy

// random numbers
float random(float p) {return fract(p * (fract(p * 7.3 + 0.3256) * 1.3 + 2.6) * 6.54 + 0.356);}
float random(vec2 p) {return random(p.y + random(p.x));}
float random(vec3 p) {return random(p.z + random(p.xy));}
float random(vec4 p) {return random(p.w + random(p.xyz));}

// perlin noise
float onoise(vec3 p, float s, float l) {
    //find corners of cube
    p.y = mod(p.y,l);
    vec3 corn000 = vec3(floor(p.x),floor(p.y),floor(p.z));
    vec3 corn001 = vec3(ceil(p.x),floor(p.y),floor(p.z));
    vec3 corn010 = vec3(floor(p.x),ceil(p.y),floor(p.z));
    vec3 corn011 = vec3(ceil(p.x),ceil(p.y),floor(p.z));
    vec3 corn100 = vec3(floor(p.x),floor(p.y),ceil(p.z));
    vec3 corn101 = vec3(ceil(p.x),floor(p.y),ceil(p.z));
    vec3 corn110 = vec3(floor(p.x),ceil(p.y),ceil(p.z));
    vec3 corn111 = vec3(ceil(p.x),ceil(p.y),ceil(p.z));
    vec3 corr000 = corn000;
    vec3 corr001 = corn001;
    vec3 corr010 = corn010;
    vec3 corr011 = corn011;
    vec3 corr100 = corn100;
    vec3 corr101 = corn101;
    vec3 corr110 = corn110;
    vec3 corr111 = corn111;
    corr000.y = mod(corr000.y,l);
    corr001.y = mod(corr001.y,l);
    corr010.y = mod(corr010.y,l);
    corr011.y = mod(corr011.y,l);
    corr100.y = mod(corr100.y,l);
    corr101.y = mod(corr101.y,l);
    corr110.y = mod(corr110.y,l);
    corr111.y = mod(corr111.y,l);
    //random numbers
    vec2 rand000 = vec2(random(vec4(corr000,s)),random(vec4(corr000,s + 0.1)));
    vec2 rand001 = vec2(random(vec4(corr001,s)),random(vec4(corr001,s + 0.1)));
    vec2 rand010 = vec2(random(vec4(corr010,s)),random(vec4(corr010,s + 0.1)));
    vec2 rand011 = vec2(random(vec4(corr011,s)),random(vec4(corr011,s + 0.1)));
    vec2 rand100 = vec2(random(vec4(corr100,s)),random(vec4(corr100,s + 0.1)));
    vec2 rand101 = vec2(random(vec4(corr101,s)),random(vec4(corr101,s + 0.1)));
    vec2 rand110 = vec2(random(vec4(corr110,s)),random(vec4(corr110,s + 0.1)));
    vec2 rand111 = vec2(random(vec4(corr111,s)),random(vec4(corr111,s + 0.1)));
    //turn random numbers into random vectors
    vec3 grad000 = vec3(sin(rand000.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand000.y * 2. - 1.) * (rand000.y * 2. - 1.)),rand000.y * 2. - 1.);
    vec3 grad001 = vec3(sin(rand001.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand001.y * 2. - 1.) * (rand001.y * 2. - 1.)),rand001.y * 2. - 1.);
    vec3 grad010 = vec3(sin(rand010.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand010.y * 2. - 1.) * (rand010.y * 2. - 1.)),rand010.y * 2. - 1.);
    vec3 grad011 = vec3(sin(rand011.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand011.y * 2. - 1.) * (rand011.y * 2. - 1.)),rand011.y * 2. - 1.);
    vec3 grad100 = vec3(sin(rand100.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand100.y * 2. - 1.) * (rand100.y * 2. - 1.)),rand100.y * 2. - 1.);
    vec3 grad101 = vec3(sin(rand101.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand101.y * 2. - 1.) * (rand101.y * 2. - 1.)),rand101.y * 2. - 1.);
    vec3 grad110 = vec3(sin(rand110.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand110.y * 2. - 1.) * (rand110.y * 2. - 1.)),rand110.y * 2. - 1.);
    vec3 grad111 = vec3(sin(rand111.x * PI * 2. + vec2(0.,0.5) * PI) * sqrt(1. - (rand111.y * 2. - 1.) * (rand111.y * 2. - 1.)),rand111.y * 2. - 1.);
    //find vector form corners to point
    vec3 ofst000 = p - corn000;
    vec3 ofst001 = p - corn001;
    vec3 ofst010 = p - corn010;
    vec3 ofst011 = p - corn011;
    vec3 ofst100 = p - corn100;
    vec3 ofst101 = p - corn101;
    vec3 ofst110 = p - corn110;
    vec3 ofst111 = p - corn111;
    //dot produt
    float val000 = dot(ofst000,grad000);
    float val001 = dot(ofst001,grad001);
    float val010 = dot(ofst010,grad010);
    float val011 = dot(ofst011,grad011);
    float val100 = dot(ofst100,grad100);
    float val101 = dot(ofst101,grad101);
    float val110 = dot(ofst110,grad110);
    float val111 = dot(ofst111,grad111);
    //caculate position in cube and do some smoothing
    vec3 tval = fract(p);
    //tval = tval * tval * tval * (tval * (6. * tval - 15.) + 10.);
    tval = tval * tval * (3. - tval * 2.);
    //interpolate values
    return mix(mix(mix(val000,
                       val001,tval.x),
                   mix(val010,
                       val011,tval.x),tval.y),
               mix(mix(val100,
                       val101,tval.x),
                   mix(val110,
                       val111,tval.x),tval.y),tval.z);
}

float noise(vec3 p, float s) {
    return 
    onoise(p * 1.0, s + 0.0, 1.0 * 15.0) / 1.0 + 
    onoise(p * 2.0, s + 1.0, 2.0 * 15.0) / 2.0 + 
    onoise(p * 4.0, s + 2.0, 4.0 * 15.0) / 3.0 + 
    onoise(p * 8.0, s + 3.0, 8.0 * 15.0) / 5.0 + 
    onoise(p * 16.0, s + 4.0, 16.0 * 15.0) / 8.0 + 
    onoise(p * 32.0, s + 5.0, 32.0 * 15.0) / 13.0 + 
    onoise(p * 64.0, s + 5.0, 64.0 * 15.0) / 21.0 + 
    onoise(p * 128.0, s + 5.0, 128.0 * 15.0) / 34.0 + 
    0.0;
}

void mainImage(out vec4 c,vec2 o){
   vec3 p = vec3((o / r * 2. - 1.) * sqrt(r / r.yx) * 2.,iTime * 0.4);
   c = vec4(0.3 / length(p.xy));
   p.xy = vec2(0.5 / sqrt(length(p.xy) - 0.25) + iTime * 1.7,atan(p.y,p.x) / PI / 2. * 15.);
   if(p.x != p.x) {
       return;
   }
   float s = 3.;
   float epsilon = 0.5;
   float vaz = noise(p,s);
   vec2 vp = vec2(noise(p + vec3(1,0,0) * epsilon,s),noise(p + vec3(0,1,0) * epsilon,s));
   vec2 vn = vec2(noise(p - vec3(1,0,0) * epsilon,s),noise(p - vec3(0,1,0) * epsilon,s));
   vec2 d1 = vp - vn;
   vec2 d2 = vaz * 2. - vp - vn;
   d1,d2 /= epsilon;
   c.xyz += pow(d2.x + d2.y,2.) / sqrt(length(d1)) * 0.1 * (vec3(3. * dot(sin(vec2(0,1.5) + iTime * 2.),d2 * d1),dot(sin(vec2(0,1.5) + 2. + iTime * 2.),d2 * d1),dot(sin(vec2(0,1.5) + 4. + iTime * 2.),d2 * d1)) * 0.5 + 0.5);
}