//
//  NearFar_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef NearFar_PixelProc_hpp
#define NearFar_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class NearFar_PixelProc : public Base_PixelProc {

    ofParameter<bool> cvThreshParam = ofParameter<bool>("cv-threshold",false);
    ofParameter<int> nearParam = ofParameter<int>("near",0,200,255);
    ofParameter<int> farParam = ofParameter<int>("far",0,50,255);

    ofxCvGrayscaleImage depthImage;
    ofxCvGrayscaleImage grayThreshNear;
    ofxCvGrayscaleImage grayThreshFar;

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName("nearFar");
        group.add(onParam);
        group.add(drawParam);
        group.add(cvThreshParam);
        group.add(nearParam);
        group.add(farParam);
        gui.add(group);
        
        depthImage.allocate(model.kinectWidth, model.kinectHeight);
        grayThreshNear.allocate(model.kinectWidth, model.kinectHeight);
        grayThreshFar.allocate(model.kinectWidth, model.kinectHeight);

    }

    void proc(){
        
        if(cvThreshParam.get()) {
            grayThreshNear = procImage;
            grayThreshFar = procImage;
            grayThreshNear.threshold(nearParam.get(), true);
            grayThreshFar.threshold(farParam.get());
            cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), procImage.getCvImage(), NULL);
        } else {
            // or we do it ourselves - show people how they can work with the pixels
            ofPixels & pix = procImage.getPixels();
            unsigned long numPixels = pix.size();
            for(int i = 0; i < numPixels; i++) {
                if(pix[i] < nearParam.get() && pix[i] > farParam.get()) {
                    pix[i] = 255;
                } else {
                    pix[i] = 0;
                }
            }
        }
        
        //• its own proc!
        procImage.mirror(false, true);
        

    };
    string title(){return "near far";};
};

#endif /* NearFar_PixelProc_hpp */