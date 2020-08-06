//
//  Blur_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#ifndef Blur_PixelProc_hpp
#define Blur_PixelProc_hpp

#include <stdio.h>
#include "PixelProc.hpp"

class Blur_PixelProc : public PixelProc {
    
    ofParameter<bool> drawParam = ofParameter<bool>("draw",true);
    ofParameter<int> blurParam = ofParameter<int>("blur",3,0,100);
    
    ofxCvGrayscaleImage blurImage;

public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels);

};

#endif /* Blur_PixelProc_hpp */
