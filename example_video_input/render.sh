#!/bin/sh

# iTexture0 will be new frame every frame
mkdir "video_frames_0"
ffmpeg -i "shadertoy_video.webm" -vf fps=30 "video_frames_0/%d.png"

# for multiple channels
#mkdir "video_frames_1"
#ffmpeg -i "shadertoy_video.webm" -vf fps=30 "video_frames_1/%d.png"
# etc - video_frames_X where X is number and X is channel input

python3 ../shadertoy-render.py --output 3.mp4 --size=1280x720 --rate=30 --duration=10. --bitrate=5M  main_image.glsl
