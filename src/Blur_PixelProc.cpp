//
//  Blur_PixelProc.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#include "Blur_PixelProc.hpp"

void Blur_PixelProc::setup(const DepthModel &model, ofxPanel &gui){
    
    ofParameterGroup group;
    
    group.setName("blur");
    group.add(drawParam);
    group.add(blurParam);
    gui.add(group);
 
    blurImage.allocate(model.kinectWidth, model.kinectHeight);

}

void Blur_PixelProc::draw(const DepthModel &model){

    if(drawParam.get()){
        blurImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectWidth * model.kinectScale);
    }
}

ofPixels Blur_PixelProc::process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels){
    
    blurImage.setFromPixels(depthPixels);
    blurImage.blurGaussian(blurParam.get());
    
    return blurImage.getPixels();
}
