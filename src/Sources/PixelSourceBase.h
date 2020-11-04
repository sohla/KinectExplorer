//
//  DepthCameraBase.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 24/7/20.
//

#ifndef PixelSourceBase_hpp
#define PixelSourceBase_hpp

#include <stdio.h>
#include "PixelProc.hpp"

class PixelSourceBase {
    
public:

    virtual void setup(DepthModel &model) = 0;
    virtual void draw(DepthModel &model) = 0;
    virtual void update(std::function<void(const ofPixels &pixels)> updatedPixels) = 0;
    virtual void exit() = 0;
};


/*
 source could be a web cam, depth cam, ndi stream, video
 
 
 
 */

#endif /* PixelSourceBase_hpp */
