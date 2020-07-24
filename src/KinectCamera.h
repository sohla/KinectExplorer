//
//  KinectCamera.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef KinectCamera_hpp
#define KinectCamera_hpp

#include <stdio.h>

#include "DepthCameraBase.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"

class KinectCamera : public DepthCameraBase {
    
public:

    void setup(InputModel &im);
    void draw(InputModel &im);
        
    void update(std::function<void(const ofPixels &videoPixels, const ofPixels &depthPixels)> updatedPixels){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {
            updatedPixels(kinect.getPixels(), kinect.getDepthPixels());
        }
    }
    
    //private: not yet need dimensions and setting angle
    ofxKinect   kinect;

};


#endif /* KinectCamera_hpp */


