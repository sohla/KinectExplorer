//
//  DepthCameraBase.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 24/7/20.
//

#ifndef DepthCameraBase_hpp
#define DepthCameraBase_hpp

#include <stdio.h>
#include "InputModel.h"
#include "PixelProc.hpp"

class DepthCameraBase {
    
public:

    virtual void setup(InputModel &im, DepthModel &model) = 0;
    virtual void draw(InputModel &im) = 0;
    virtual void update(std::function<void(const ofPixels &videoPixels, const ofPixels &depthPixels)> updatedPixels) = 0;

};


#endif /* DepthCameraBase_hpp */
