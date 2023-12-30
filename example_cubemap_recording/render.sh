#!/bin/sh

# remember to add shift_per_side to size if used (here not used)
# to control "side per buffer" - used start_mouse_ in Buf0-5
# if you need to rotate camera - do it in main_image.glsl
# remember alo you need 90 deg camera FOV to record sides
# use https://github.com/google/spatial-media/releases/tag/v2.0 to convert to 360 video on youtube

python3 ../shadertoy-render.py --output 3.mp4 --size=512x512 --panorama_rec_size=1280x720 --rate=30 --duration=3. --bitrate=5M  main_image.glsl

cd "spatial-media"
python3 spatialmedia -i "../3.mp4" "../3_360_injected.mp4"
