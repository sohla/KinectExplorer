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

#include "ofxSyphon.h"
#include "ofxNDISender.h"
#include "ofxNDISendStream.h"
#include "ofxNDIReceiver.h"
#include "ofxNDIRecvStream.h"

class Base_PixelProc : public PixelProc {
    
    virtual string title() = 0;
    virtual void proc() = 0;

public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &pixels);

protected:

    ofParameter<bool> drawParam = ofParameter<bool>("draw",false);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);

    ofxCvGrayscaleImage procImage;

};




//------------------------------------------------------------

//• recorder proc
//• idn proc



#endif /* Base_PixelProc_hpp */
