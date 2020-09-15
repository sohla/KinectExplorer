//
//  Blur_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Blur_PixelProc_hpp
#define Blur_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Blur_PixelProc : public Base_PixelProc {
    
    ofParameter<int> blurParam = ofParameter<int>("blur",3,0,100);

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(blurParam);
        gui.add(group);

        procImage.allocate(model.kinectWidth, model.kinectHeight);

    }

    void proc(){
        procImage.blurGaussian(1 + (blurParam.get() & ~1)); // bitwise not (even) + 1 is....odd
    };
    string title(){return "blur";};
};

#endif /* Blur_PixelProc_hpp */
