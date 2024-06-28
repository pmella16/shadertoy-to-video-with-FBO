#define N 23    // Number of sources
const float k = 2.*3.14159/.04, c = 0.1; // Wavelength and wave speed constants
#define t iTime  // Use global time for animation

// Random number generator for source placement
float rnd(float i) {
    return mod(4000.*sin(23464.345*i+45.345),1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 R = iResolution.xy, uv = (2.*fragCoord - R ) / R.y;
    float x = -.75, y = -.7;
    const float stp = 1.54/float(N);
    float Phi[N], D2[N];

    // Calculate source contributions
    for (int i = 0; i < N; i++) {
        vec2 P;
        P = .7*vec2(sin(4.*x),-cos(4.*x));
        //if 		(MODE==1) { P = vec2(x,-.9); x+= stp;}
		//else if (MODE==2) { P = vec2(x,-.9); x+= stp*(1.+srnd(float(i))); }
		//else if (MODE==3) { P = .99*vec2(sin(4.*xt),-cos(4.*xt)); xt+= stp;}
		//else if (MODE==4) { P = .99*vec2(sin(4.*xt),-cos(4.*xt)); xt+= stp*(1.+.7*srnd(float(i)));}
        x += 1.4*sqrt(stp);
        if (x > .7) { x = -.7; y += sqrt(1.4*stp); }
        
        float d = length(uv-P), phi = d - c*t;
        Phi[i] = k*phi; // Wave attributes
        D2[i] = pow(d,1.0); // Distance fading

        if (d < 0.01) { fragColor = vec4(0,0,1,0); return; } // Source point coloring
    }
    
    // Combine waves
    float v = 0.;
    for (int i = 0; i < N; i++) {
        v += cos(Phi[i])/D2[i];
    }

    // Normalize and color
    v = v*4.5/float(N);
    fragColor = v*vec4(1,.5,.25, 1);
}
