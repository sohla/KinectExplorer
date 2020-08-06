//
//  NearFar_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#ifndef NearFar_PixelProc_hpp
#define NearFar_PixelProc_hpp

#include <stdio.h>

#include "PixelProc.hpp"


class NearFar_PixelProc : public PixelProc {
    
    ofParameter<bool> drawParam = ofParameter<bool>("draw",true);
    ofParameter<bool> cvThreshParam = ofParameter<bool>("cv-threshold",false);
    ofParameter<int> nearParam = ofParameter<int>("near",0,200,255);
    ofParameter<int> farParam = ofParameter<int>("far",0,50,255);

    ofxCvGrayscaleImage depthImage;
    ofxCvGrayscaleImage grayThreshNear;
    ofxCvGrayscaleImage grayThreshFar;

public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels);

};
#endif /* NearFar_PixelProc_hpp */
