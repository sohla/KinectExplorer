//
//  KinectManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef KinectManager_hpp
#define KinectManager_hpp

#include <stdio.h>

#include "DepthCameraBase.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"

class KinectCamera : public DepthCameraBase {
    
public:

    void setup(InputModel &im);
    void draw(InputModel &im);
        
    void update(std::function<void(const ofPixels &pixels)> updatedPixels){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {

            ofPixels p = kinect.getDepthPixels();
            updatedPixels(p);
        }
    }
    
    ofxKinect   kinect;

};


#endif /* KinectManager_hpp */


