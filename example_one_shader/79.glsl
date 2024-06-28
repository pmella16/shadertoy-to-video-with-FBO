#define TURN 6.283185307
#define HEX(x) vec3((ivec3(x)>>ivec3(16,8,0))&255)/255.

// Random integers used for Perlin noise.
uint rand[] = uint[] (244u, 69u,224u, 39u,208u,151u,201u,255u,189u,202u,157u, 92u,206u,154u,199u,194u,232u,101u,216u,134u, 62u,242u,163u,248u,140u,183u,120u, 90u,215u, 30u,211u,186u,150u,100u, 57u,106u,118u,142u, 61u,246u, 11u,230u,141u, 55u,147u,180u, 27u,226u, 99u,125u,122u, 13u,  2u,112u,192u, 60u,137u, 80u,198u,252u, 94u,245u,162u,113u, 24u,146u, 49u,110u,253u, 81u, 10u,165u,109u,115u,218u,  0u,254u,129u, 71u, 88u,187u,114u,176u,243u,  7u, 87u, 45u,209u, 23u,168u,103u,121u, 93u,153u, 22u,133u, 34u, 78u,241u,182u,221u, 38u,136u,104u, 18u,105u,164u, 65u, 91u, 25u,132u,119u,174u,173u, 15u,170u, 29u, 37u,212u,210u, 44u,169u,181u,251u,  4u,  8u,229u, 79u, 32u, 21u,203u,214u, 75u, 12u,225u, 97u, 40u, 35u, 28u, 64u,231u, 19u,185u,123u,236u, 77u,238u,  5u,128u,179u,127u, 48u, 72u,156u,190u, 54u,124u,250u,205u,161u,228u, 56u,158u,207u,148u, 17u, 95u, 52u,111u,126u, 36u, 74u,197u,152u,160u, 20u,219u,130u, 66u,239u,240u,  6u,108u, 47u,116u,213u,237u,138u, 70u, 33u, 26u, 46u, 96u, 53u, 41u,200u, 59u, 58u,135u, 83u,235u, 31u,131u, 63u, 42u,  1u,149u,139u,247u,  9u,159u, 73u, 98u,222u, 68u, 51u, 67u,144u, 82u,233u,177u,155u,178u, 50u,143u, 84u,184u, 85u,217u,166u,193u,145u, 89u,107u,172u, 76u,117u,196u, 86u,220u,  3u,171u,223u, 16u,167u,195u,191u,102u, 14u,188u,227u,234u,204u,249u, 43u,175u);

// fade function defined by ken perlin
vec2 fade(vec2 t) {
  return t * t * t * (t * (t * 6. - 15.) + 10.);
}
// corner vector
vec2 cvec(vec2 uv, float time) {
  uint x = uint(mod(uv.x, 256.));
  uint y = uint(mod(uv.y, 256.));
  float n = (float(rand[(x + rand[y]) & 255u]) / 255. + time) * TURN;
  return vec2(
      sin(n), cos(n)
  );
}
// perlin generator
// perlin generator
float perlin(vec2 uv, float offset, vec2 loop) {  
  vec2 i = floor(mod(uv, loop));
  vec2 iNext = mod(i + 1., loop);
  vec2 f = fract(uv);

  vec2 u = fade(f);
  offset = fract(offset);

  return
  mix(
    mix(
      dot( cvec(i,                  offset ), f - vec2(0.0,0.0) ),
      dot( cvec(vec2(iNext.x, i.y), offset ), f - vec2(1.0,0.0) ),
    u.x),
    mix(
      dot( cvec(vec2(i.x, iNext.y), offset ), f - vec2(0.0,1.0) ),
      dot( cvec(iNext,              offset ), f - vec2(1.0,1.0) ),
    u.x),
  u.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = fract(iTime * 0.5);

    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;
    float r = log(length(uv));
    float theta = atan(uv.y, uv.x) / TURN;

    float basic = r + 2. * theta - 2. * t;
    float progress = floor(basic) - 2.* theta + 2. * t;
    float colormask = mod(floor(basic), 2.);
    float stripeDist = fract(basic);

    float v1 = (
        abs(2. * stripeDist - 1.)
    );
    float v2 = (
        clamp(-5.0 * r + 4.5 * stripeDist - 7.5, 0.0, 1.0)
    );
    float v = 1. - sqrt(v1 * v1 + v2 * v2);
    v = smoothstep(0.1, 0.5, v);
    float noise = perlin(
        vec2(r * 24. - t * 48., theta * 96.), 0.0, vec2(24., 96.)
    ) + 0.5 * perlin(
        vec2(r * 64. - t * 128., theta * 256.), 0.0, vec2(64., 256.)
    );
    v += 0.5 * noise - 0.3;
    v = smoothstep(0.0, 1.0, v);
    
    vec3 col = mix(
        mix(
            vec3(0.9),
            vec3(0.98),
            step(
                0., noise + smoothstep(
                    -1.0, -3.0, r
                )
            )
        ),
        mix(
            HEX(0xefaf00),
            HEX(0xaf00ef),
            colormask
        ),
        step(0.55, v)
    );

    // Output to screen
    fragColor = vec4(col,1.0);
}