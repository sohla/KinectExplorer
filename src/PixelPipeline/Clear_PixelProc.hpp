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
    
    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam); 
        gui.add(group);

        procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);

    }

    void proc(){
        ofPixels & pix = procImage.getPixels();
        for(int i = 0; i < pix.size(); i++) {pix[i] = 0;};
    };
    
    string title(){return "clear";};
};

#endif /* Blur_PixelProc_hpp */
