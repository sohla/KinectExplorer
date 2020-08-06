//
//  Base_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#ifndef Base_PixelProc_hpp
#define Base_PixelProc_hpp

#include <stdio.h>
#include "PixelProc.hpp"

class Base_PixelProc : public PixelProc {
    
    
    ofParameter<bool> drawParam = ofParameter<bool>("draw",true);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);
    
    virtual string title() = 0;
    virtual void proc() = 0;

public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels);

protected:
    ofxCvGrayscaleImage procImage;

};


class Dilate_PixelProc : public Base_PixelProc {
    void proc(){procImage.dilate();}
    string title(){return "dilate";};
};

class Erode_PixelProc : public Base_PixelProc {
    void proc(){procImage.erode();}
    string title(){return "erode";};
};

#endif /* Base_PixelProc_hpp */
