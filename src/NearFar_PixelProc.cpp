//
//  NearFar_PixelProc.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#include "NearFar_PixelProc.hpp"


void NearFar_PixelProc::setup(const DepthModel &model, ofxPanel &gui){
    
    ofParameterGroup group;
    
    group.setName("nearFar");
    group.add(drawParam);
    group.add(cvThreshParam);
    group.add(nearParam);
    group.add(farParam);
    gui.add(group);
    
    depthImage.allocate(model.kinectWidth, model.kinectHeight);
    grayThreshNear.allocate(model.kinectWidth, model.kinectHeight);
    grayThreshFar.allocate(model.kinectWidth, model.kinectHeight);

}

void NearFar_PixelProc::draw(const DepthModel &model){

    if(drawParam.get()){
        depthImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectWidth * model.kinectScale);
    }
}

ofPixels NearFar_PixelProc::process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels){
  
    depthImage.setFromPixels(depthPixels);
    
    if(cvThreshParam.get()) {
        grayThreshNear = depthImage;
        grayThreshFar = depthImage;
        grayThreshNear.threshold(nearParam.get(), true);
        grayThreshFar.threshold(farParam.get());
        cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), depthImage.getCvImage(), NULL);
    } else {
        // or we do it ourselves - show people how they can work with the pixels
        ofPixels & pix = depthImage.getPixels();
        unsigned long numPixels = pix.size();
        for(int i = 0; i < numPixels; i++) {
            if(pix[i] < nearParam.get() && pix[i] > farParam.get()) {
                pix[i] = 255;
            } else {
                pix[i] = 0;
            }
        }
    }
    
    depthImage.mirror(false, true);
    //depthImage.flagImageChanged();

    return depthImage.getPixels();
}

