//
//  KinectCamera.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef KinectDepthCamera_hpp
#define KinectDepthCamera_hpp

#include <stdio.h>

#include "PixelSourceBase.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"

class KinectDepthCamera : public PixelSourceBase {

    ofxKinect   kinect;

public:

    void setup(InputModel &im, DepthModel &model); 
    void draw(InputModel &im);
        
    void update(std::function<void(const ofPixels &pixels)> updatedPixels){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {
            updatedPixels(kinect.getDepthPixels());
        }
    }

};


#endif /* KinectDepthCamera_hpp */


