#  Kinect Explorer





## Develpoment @Cabin

developmachine : soh_la@192.168.20.6
jetson nano : sohla@192.168.20.14

* not static ip addresses

OF path
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release

Project Path 
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release/apps/myApps/KinectExplorer

Data
~/Documents/Development/openframeworks/of_v0.11.0_linuxarmv7l_release/apps/myApps/KinectExplorer/bin/data


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

	
