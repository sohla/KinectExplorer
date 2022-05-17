#  Kinect Explorer

Tool for processing depth data, image processing, blob tracking and sending data out via OSC.

Depth Camera supported : 
Kinetic
Realsense 400 series

Platforms :
OSX and Linux arm7 (Jetson Nano)

## Dependencies

openframeworks
including :
ofxOpenCv
ofxCv
ofxGui
ofxKinect
ofxOsc
ofxVideoRecorder
ofxLibRealSense2

## Installation

Download openframeworks 
Install OF Dependencies 
Build OF if needed
Build Examples for testing
Download each ofx and test 




https://openframeworks.cc/setup/linux-install/

https://gist.github.com/madelinegannon/237733e6c114f156b31366f47c1f3d32

https://gist.github.com/jvcleave/e49c0b52085d040a5cd8a3385121cb91

```
> code
```

OF
install dependencies! in scripts/ubuntu/

projectGenerator -o"~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release" -t"vscode" kinectExample/

do we need to pass ofx addons paths : its seems not
to add ofx : use
-a"ofxGui ofxCv"




ofxKinect

install libfreenect
add rules.d to /etc/udev to bypass permissions
xbox 360 works
kinect for Windows does not (yet)


Libs to add :
ffmpeg
also need poco : check website for a build (needs restart)

ofxVideoRecorder : set path to ffmpeg /  remove some audio calls : 
framerate issues : machine not fast enough. can build ffmpeg for cuda? 


install : lm-sensors for temp monitoring




OF path
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release

Project Path 
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release/apps/myApps/KinectExplorer

Data
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release/apps/myApps/KinectExplorer/bin/data



Realsense

https://jetsonhacks.com/2019/12/22/install-realsense-camera-in-5-minutes-jetson-nano/


## OSC control

GUI : 
    in port : 57000
    out port: 57120 (SC)

Example : 
b = NetAddr("192.168.20.14",57000);
b.sendMsg("/inputSettings/blur/blur", 1);
b.sendMsg("/inputSettings/realtime/realtime", 1);
b.sendMsg("/inputSettings/pixel_recorder/recording", true);
b.sendMsg("/inputSettings/pixel_recorder/recording", false);
b.free;
    
Kinect Explorer : 
    pixels : port 57140
    lines : port 57130

Example 


    
API :

    /ke/pixel
        0 diffMean

    /ke/line
        0 number of blobs
        1 area
        2 perimeter
        3 center.x
        4 center.y
        5 rect.x
        6 rect.y
        7 rect.h
        8 rect.w
        9 size of line points (max = line 220)
        10...n n=size of line points, data is interleaved (x0,y0,x1,y1...)

    
    
Path : /ke/line

0 /blobi
1 number of blobs
2 area
3 perimeter
4 center.x
5 center.y
6 rect.x
7 rect.y
8 rect.h
9 rect.w
10 size of line points (max = line 220)
11...n n=size of line points, data is interleaved (x0,y0,x1,y1...)

    
    
    
## Monitoring

tegrastats --interval 2000

* in ms. 





## Notes

#!## copy movie files 

scp sohla@192.168.20.14:~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release/apps/myApps/KinectExplorer/bin/data/ke_depth2020-10-16-11-50-26.mov ~/Movies






## TODO

+ refactor contour finder using ofxCv::ContourFinder
+ add tracker and persist name
+ struct for each blob/line
+ find ordered line
+ top/bottom half of line
+ velocity of blob

+ player as a pixel proc?

	
