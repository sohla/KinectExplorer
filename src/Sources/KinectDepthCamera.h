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

    void setup(DepthModel &model); 
    void draw(DepthModel &model);
        
    void update(std::function<void(const ofPixels &pixels)> updatedPixels){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {
            updatedPixels(kinect.getDepthPixels());
        }
        //• what about creating a mesh?`
        
    }

};


#endif /* KinectDepthCamera_hpp */


