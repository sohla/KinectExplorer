//
//  RealSenseDepthCamera.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 3/11/20.
//

#ifndef RealSenseDepthCamera_hpp
#define RealSenseDepthCamera_hpp

#include <stdio.h>

#include "PixelSourceBase.h"
#include "ofxLibRealSense2.hpp"

class RealSenseDepthCamera : public PixelSourceBase {

    ofxLibRealSense2 realsense;
    ofPixels _pixels;
public:

    void setup(DepthModel &model);
    void draw(DepthModel &model);
    void update(std::function<void(const ofPixels &pixels)> updatedPixels);
};



#endif /* RealSenseDepthCamera_hpp */
