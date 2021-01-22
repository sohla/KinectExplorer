//
//  PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#ifndef PixelProc_hpp
#define PixelProc_hpp

#include <stdio.h>
#include "ofxGui.h"

#include "ofxOpenCv.h"
#include "ofxCv.h"


struct DepthModel {
  
    int depthCameraWidth = 0;
    int depthCameraHeight = 0;
    int kinectAngle = 20;
    float depthCameraScale = 1.6;


};

class PixelProc {
    
public:
    
    virtual void setup(const DepthModel &model, ofxPanel &gui) = 0;
    virtual void draw(const DepthModel &model) = 0;
    virtual ofPixels process(const DepthModel &model, const ofPixels &pixels) = 0;
    virtual void exit() = 0;

};
#endif /* PixelProc_hpp */
