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

class DepthCameraBase {
    
public:

    virtual void setup(InputModel &im){};
    virtual void draw(InputModel &im){};
    virtual void update(std::function<void(const ofPixels &videoPixels, const ofPixels &depthPixels)> updatedPixels){};

};


#endif /* DepthCameraBase_hpp */
