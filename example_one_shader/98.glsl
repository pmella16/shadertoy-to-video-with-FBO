// https://en.wikipedia.org/wiki/Pairing_function

#define R iResolution.xy
#define T (iTime)
mat2 rot(float a) { float s = sin(a); float c = cos(a); return mat2(c, s, -s, c); }
vec3 aces(vec3 x) { return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14),0.0,1.0); }
float cantor(vec2 p) { return ((p.x + p.y) * (p.x + p.y + 1.)) / 2. + p.y;}

float mytanh(float x) {
    return (exp(2.0 * x) - 1.0) / (exp(2.0 * x) + 1.0);
}

vec2 mytanh(vec2 v) {
    return vec2(mytanh(v.x), mytanh(v.y));
}

vec3 mytanh(vec3 v) {
    return vec3(mytanh(v.x), mytanh(v.y), mytanh(v.z));
}

vec2 decant(float c) {
  float w = floor((sqrt(c * 8. + 1.) - 1.) / 2.);
  float y = c - (w * (w + 1.)) / 2.; float x = w - y;
  return vec2(x,y);
}
float smin(float a, float b, float k) {float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
return mix(a, b, h) - k*h*(1.0-h); }
float smax(float a, float b, float k) {return smin(a, b, -k); }
float sabs(in float v, in float k) {return smax(-v, v, k);}
vec2 sabs(in vec2 v,  in float k){ return vec2(sabs(v.x, k), sabs(v.y, k)); }

void mainImage(out vec4 o, in vec2 fc) {
  vec3 col = vec3(0.0);
  vec2 uv = (fc-0.5*R.xy)/R.y;
  vec4 m = vec4((iMouse.xy-0.5*R.xy)/R.y,iMouse.zw);
  uv.xy *= rot(T*0.25+cantor(sabs(uv*0.25, 0.25)));
  uv.xy += 0.5*vec2(sin(T*0.5), cos(T*0.5));
  vec2 p = uv*10.;
  vec2 id = floor(p);
  vec2 lv = fract(p);
  lv = lv*lv*(3.0-2.0*lv);
  float mu = mix(2.0, 10.0, 0.5+0.5*sin(T));
  float ex = -1.6;
  col.xy += exp(decant(length(lv-0.5)*mu)+ex);
  col.z = exp(cantor(col.xy)+ex);
  vec2 alv = abs(lv-0.5);
  col = col*col;
  col = mytanh(col-0.25);
  o = vec4(pow(aces(col), vec3(1.0 / 2.2)), 1.0);
}
