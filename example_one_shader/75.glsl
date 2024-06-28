// adjusts the saturation
vec3 sat(vec3 rgb)
{
    // Algorithm from Chapter 16 of "OpenGL Shading Language"
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, 1.5); // adjust strength here
}

// varying speed
float funkySpeed(float x)
{
    x = mod(x + 1.0, 2.0) - 1.0;
    float n = x * x * x; // implement the speed change using x cubed
	return (8. * n - 4. * x) * 3.14159265;
}

// gets brightness from some factor of dist and angle
float fn(float x)
{
    float n = abs(sin(x));
    return max((n - 0.5) * 1.5, 0.);
}

// makes edges darker than the center
float vignette(float v, float d)
{
    return v * (0.8 - 0.35 * d);
}

// this is where most of the magic happens
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // some constants that we'll use thru-out the spiral
    const float PI = 3.14159265; // of course, we need π for trig
    const float PI_3 = PI / 3.; // pre-compute π/3 for hue rotation
    const float speed = 0.4; // speed of spiral movement
    float hue = fract(iTime * 1.2) * PI; // offset of hue [0, π)
    
    // Normalized pixel coordinates [-1, 1]
    float scale = min(iResolution.x, iResolution.y);
    vec2 uv = fragCoord / scale;
	uv -= vec2(iResolution.x / scale, iResolution.y / scale) / 2.;
    uv *= 2.0;
    
    // calculate "distance" to prepare for a log spiral
    float distance = log(uv.x*uv.x+uv.y*uv.y);
    // calculate angle [0, 2π)
    float angle = atan(uv.y, uv.x);
    
    // Time varying pixel color
    // spiral 1
    float c1 = vignette(fn(distance * 1.5 + angle * 3.0 + funkySpeed(iTime * speed) + PI), distance);
    // spiral 2
    float c2 = vignette(fn(distance * 1.5 - angle * 3.0 + funkySpeed((iTime * speed) + 2. / 3.) + PI), distance);
    // rings 
    float c3 = vignette(fn(angle * 16.0 + sin(iTime) * 8.0 - iTime * 0.5) * 0.5
             + fn(distance * 4.0 + funkySpeed((iTime * speed) + 4. / 3.) * 0.5), distance);
    
    // Flashing
    const float flashIntvl = 0.2;
    const float flashStrength = 1.5;
    const float flashSudden = flashStrength / flashIntvl * 6.0;
    float f1 = max(0., flashStrength - mod(iTime, flashIntvl) * flashSudden);
    float f2 = max(0., flashStrength - mod(iTime + flashIntvl * 1.0/3.0, flashIntvl) * flashSudden);
    float f3 = max(0., flashStrength - mod(iTime + flashIntvl * 2.0/3.0, flashIntvl) * flashSudden);
	c1 += f1; c2 += f2; c3 += f3;

    // Saturation
    vec3 fragColorRGB = sat(
        // this part rotates the hue away from each other by 2π/3 radians
        vec3(
        	abs(c1 * sin(hue))        + abs(c2 * -sin(hue + PI_3)) + abs(c3 * -sin(hue - PI_3)),
        	abs(c1 * sin(hue + PI_3)) + abs(c2 * -sin(hue - PI_3)) + abs(c3 * -sin(hue)       ),
        	abs(c1 * sin(hue - PI_3)) + abs(c2 * -sin(hue))        + abs(c3 * -sin(hue + PI_3))
        )
    );
    
    // Output to screen
    fragColor = vec4(fragColorRGB, 1); // just add alpha and we're done
}