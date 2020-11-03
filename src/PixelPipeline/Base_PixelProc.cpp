//
//  Base_PixelProc.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#include "Base_PixelProc.hpp"


void Base_PixelProc::setup(const DepthModel &model, ofxPanel &gui){
    
    ofParameterGroup group;
    
    group.setName(title());
    group.add(onParam);
    group.add(drawParam);
    gui.add(group);
 
    // default behaviour keeps group closed
    gui.getGroup(title()).minimize();
    
    procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);

}

void Base_PixelProc::draw(const DepthModel &model){

    if(drawParam.get()){
        procImage.draw(0, 0, model.depthCameraWidth * model.depthCameraScale, model.depthCameraHeight * model.depthCameraScale);
    }
}

ofPixels Base_PixelProc::process(const DepthModel &model, const ofPixels &pixels){
    
    procImage.setFromPixels(pixels);
    if(onParam.get()){proc();};
    return procImage.getPixels();
}

void Base_PixelProc::exit(){
    
}

string Base_PixelProc::title(){
    return "pixel base";
}



