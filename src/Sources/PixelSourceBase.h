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
    virtual void update(std::function<void(const ofPixels &pixel)> updatedPixels) = 0;

};


#endif /* PixelSourceBase_hpp */
