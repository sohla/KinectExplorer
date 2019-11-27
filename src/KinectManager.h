//
//  KinectManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef KinectManager_hpp
#define KinectManager_hpp

#include <stdio.h>
#include "InputModel.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
//#include "MSAInterpolator.h"

class KinectManager {
    
public:

    void setup(InputModel &im);
    void draw(InputModel &im);
    void update(InputModel &im);

    template<typename F>
    void update(F next){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {

            ofPixels p = kinect.getDepthPixels();

            mesh.clear();
            
            int w = kinect.width;
            int h = kinect.height;
            
            int step = 10;
            for(int y = 0; y < h; y += step) {
                for(int x = 0; x < w; x += step) {
                    if(kinect.getDistanceAt(x, y) < 3000) {
                        mesh.addColor(kinect.getColorAt(x,y));
                        ofVec3f p = kinect.getWorldCoordinateAt(x, y);
                        mesh.addVertex(p);
                    }
                }
            }

            next(p,mesh);
        }
    }
    
    ofxKinect   kinect;
    ofMesh      mesh;

};


#endif /* KinectManager_hpp */


