//
//  DepthCameraBase.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 24/7/20.
//

#ifndef PixelSourceBase_hpp
#define PixelSourceBase_hpp

#include <stdio.h>
#include "InputModel.h"
#include "PixelProc.hpp"

class PixelSourceBase {
    
public:

    virtual void setup(InputModel &im, DepthModel &model) = 0;
    virtual void draw(InputModel &im) = 0;
    virtual void update(std::function<void(const ofPixels &pixel)> updatedPixels) = 0;

};


#endif /* PixelSourceBase_hpp */
