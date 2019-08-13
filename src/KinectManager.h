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
#include "MSAInterpolator.h"

class KinectManager {
    
public:

    void setup(InputModel &im);
    void draw(InputModel &im);
    
    template<typename F>
    void update(F next){
        
        kinect.update();
        
        if(kinect.isFrameNew()) {
            next(kinect.getDepthPixels());
        }
    }
    
    ofxKinect kinect;
    int angle;


};


#endif /* KinectManager_hpp */


