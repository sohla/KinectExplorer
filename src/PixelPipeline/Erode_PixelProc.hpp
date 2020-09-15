//
//  Erode_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Erode_PixelProc_hpp
#define Erode_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Erode_PixelProc : public Base_PixelProc {
 
    ofParameter<int> amountParam = ofParameter<int>("amount",1,1,32);

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(amountParam);
        gui.add(group);

        procImage.allocate(model.kinectWidth, model.kinectHeight);

    }


    void proc(){
        for(int i = 0; i < amountParam.get(); i++){
            procImage.erode();
        }
    }
    string title(){return "erode";};
};

#endif /* Erode_PixelProc_hpp */
