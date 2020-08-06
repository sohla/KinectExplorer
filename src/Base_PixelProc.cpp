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
    group.add(drawParam);
    group.add(onParam);
    gui.add(group);
 
    procImage.allocate(model.kinectWidth, model.kinectHeight);

}

void Base_PixelProc::draw(const DepthModel &model){

    if(drawParam.get()){
        procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectWidth * model.kinectScale);
    }
}

ofPixels Base_PixelProc::process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels){
    
    procImage.setFromPixels(depthPixels);
    if(onParam.get()){
        proc();
        //        procImage.adaptiveThreshold(4);
    }
    
    return procImage.getPixels();
}

string Base_PixelProc::title(){
    return "base";
}



