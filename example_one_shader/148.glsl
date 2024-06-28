/*
    I'm trying to calculate the world-space screen derivatives
    so I can do proper anti-aliasing on blocks.
    fwidth(world) works on block faces, but breaks along block edges.
    
    The color output is displaying the difference between my derivatives and fwidth
    So ideally the only difference should be along block edges and block faces should be black
    This is working correctly when iTime==0.0, but as soon as we begin to rotate, the derivatives break.
    It gets close around 90 degrees, but it's still wrong.
    
    I can't seem to figure it out, so any ideas might help.
    Thanks for your time.
*/

//Max number of voxel steps
#define STEPS 255.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float C = cos(iTime);
    float S = sin(iTime);
    //View rotation matrix
    mat3 view = mat3(C,0,S, 0,1,0, -S,0,C); //mat3(1,0,0, 0,C,S, 0,-S,C);
    //view *= mat3(0.8,0.6,0, -0.6,0.8,0, 0,0,1);
    //view = mat3(1);
    //Ray direction
    vec3 ray = normalize(iResolution.xyy*.5 - vec3(fragCoord,0));
    vec3 dir = ray * view;
    //Prevent division by 0 errors
    dir += vec3(dir.x==0.0, dir.y==0.0, dir.z==0.0) * 1e-5;
    
    vec3 ddx_dir = dFdx(dir);
    vec3 ddy_dir = dFdy(dir);
    
    //Camera position with mouse control
    vec3 pos = vec3(0.0,0.5, 0.0) * view/32.0;
    //Scroll forward
    //pos.z += iTime/.1;
    pos.z+=8.;
    
    //Sign direction for each axis
    vec3 sig = sign(dir);
    //Step size for each axis
    vec3 stp = sig / dir;
    
    //Voxel position
    vec3 vox = floor(pos);
    //Initial step sizes to the next voxel
    vec3 dep = ((vox-pos + 0.5) * sig + 0.5) * stp;
    //Adds small biases to minimize same depth conflicts (z-fighting)
    dep += vec3(0,1,2) * 1e-5;
    
    //Axis index
    vec3 axi;
    
    //Loop iterator
    float steps = 0.0;
    //Loop through voxels
    for(float i = 0.0; i<STEPS; i++)
    {
        //Check map
        if (dot(sin(vox*.13),cos(vox.yzx*.17))+vox.y*.1>1.6) break;
        //Increment steps
        steps++;
        
        //Select the closest voxel axis
        axi = step(dep, min(dep.yzx, dep.zxy));
        axi *= 1.-axi.zxy;
        //Step one voxel along this axis
        vox += sig * axi;
        //Set the length to the next voxel
        dep += stp * axi;
    }
    //Get normal
    vec3 nor = sig * axi;
    //Viewspace normal
    vec3 vnor = view * nor;
    //Hit coordinates
    float dist = dot(dep-stp, axi);
    vec3 hit = pos + dir*dist;
    
    //////////SOLUTION IS HERE!!!!!!!!
    //My derivatives
    vec3 ddx_hit = dist * (ddx_dir - dot(ddx_dir, nor) / dot(dir, nor) * dir);
    vec3 ddy_hit = dist * (ddy_dir - dot(ddy_dir, nor) / dot(dir, nor) * dir);
    vec3 w1 = abs(ddx_hit) + abs(ddy_hit);
    
    /////////FWIDTH FOR COMPARISON
    //Fwidth
    vec3 w2 = fwidth(hit);
    
    vec3 width = 
    mod(dot(ceil(fragCoord*.1),vec2(1)),2.)>.5?
    w1 : w2;
    
    
    vec3 grid = clamp((abs(0.5-fract(hit+0.5+nor*0.5))) / width, 0.0, 1.0);
    vec3 col = sqrt(grid.x*grid.y*grid.z) * (nor*.5+.5); //nor
    vec3 sky = 1.0+(dir.y-1.0) * vec3(0.3,0.2,0.1);
    col = mix(col, sky, sqrt(steps/STEPS));
    
    //Display the difference
    fragColor = vec4(abs(w1-w2)*9.,1);//vec4(col*col,1);//
}