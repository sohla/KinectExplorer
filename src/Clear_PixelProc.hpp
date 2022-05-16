//
//  Clear_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 10/5/22.
//

#ifndef Clear_PixelProc_hpp
#define Clear_PixelProc_hpp

#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Clear_PixelProc : public Base_PixelProc {
    
    ofParameter<bool> triggerParam = ofParameter<bool>("trigger",true);

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(triggerParam);
        gui.add(group);

        procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);

    }

    void proc(){

        if(triggerParam.get()){
            procImage.clear();
        }

    };
    string title(){return "clear";};
};

#endif /* Blur_PixelProc_hpp */
