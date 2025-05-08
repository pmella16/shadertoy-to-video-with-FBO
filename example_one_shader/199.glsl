// Inspired by https://www.shadertoy.com/view/4sVfWw
// but unfinished it looked interesting so went with it

float rand3(vec3 p) {
    p += 17.;
    p *= 1.45;
    return fract(sin( dot(p,p.yzx) ));
}

#define COLOR(X) (.5 + .5 * cos( (X) * 6. * 7. + vec3(0,2.15,-2.15) )) 

void mainImage(out vec4 O,vec2 U)
{
    vec2 R = iResolution.xy, u = (U+U-R) / min(R.x,R.y);
    vec3 cam = vec3( .5+.45*sin(iTime*.8), .5+.45*cos(iTime*.6), iTime ), dir = vec3( u, 1 );
    dir = dir / dir.z;
    cam += dir / dir.z * ( ceil(cam.z) - cam.z );
    vec3 col = vec3(0);
    float size = 1.;
    for ( int deep = 0; deep < 50; deep += 1 )
    {
        vec3 camfl = floor(cam/size);
        float type = rand3( camfl );
        if ( type < .2 && ( camfl.x != 0. || camfl.y != 0. ) ) // somethings there
            if ( type < .1 )
                size *= .25; // divide
            else
                if ( length( fract(cam.xy/size)-.5 ) < .5 )
                    col = mix( COLOR( rand3(floor(cam/size)*5.) ), col, clamp( 0., 1., float(deep) / 60. )  );
        cam += dir * size; // advance to next Z
    }
    O = vec4( col, 1. );
}