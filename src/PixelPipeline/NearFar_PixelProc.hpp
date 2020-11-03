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
    ofParameter<bool> mapParam = ofParameter<bool>("map",false);

    ofParameter<bool> horzInvertParam = ofParameter<bool>("horz-invert",false);
    ofParameter<bool> vertInvertParam = ofParameter<bool>("vert-invert",false);


    ofxCvGrayscaleImage depthImage;
    ofxCvGrayscaleImage grayThreshNear;
    ofxCvGrayscaleImage grayThreshFar;
    

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(cvThreshParam);
        group.add(nearParam);
        group.add(farParam);
        group.add(mapParam);
        group.add(horzInvertParam);
        group.add(vertInvertParam);
       gui.add(group);
        
        depthImage.allocate(model.depthCameraWidth, model.depthCameraHeight);
        grayThreshNear.allocate(model.depthCameraWidth, model.depthCameraHeight);
        grayThreshFar.allocate(model.depthCameraWidth, model.depthCameraHeight);
        
    }

    void proc(){
        
        if(cvThreshParam.get()) {
            grayThreshNear = procImage;
            grayThreshFar = procImage;
            grayThreshNear.threshold(nearParam.get(), true);
            grayThreshFar.threshold(farParam.get());
            cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), procImage.getCvImage(), NULL);
        } else {
            ofPixels & pix = procImage.getPixels();
            unsigned long numPixels = pix.size();
            for(int i = 0; i < numPixels; i++) {
                if(pix[i] < nearParam.get() && pix[i] > farParam.get()) {
                    if(mapParam.get()){
                        pix[i] = ofMap(pix[i], farParam.get(), nearParam.get(), 0, 255); // mapped to far-near
                    }else{
                        pix[i] = 255; // solid white
                    }
                } else {
                    pix[i] = 0;
                }
            }
            procImage.setFromPixels(pix);
        }
        
        procImage.mirror(horzInvertParam.get(), vertInvertParam.get());

    };
    string title(){return "near far";};
    
//    void draw(const DepthModel &model){
//
//        if(drawParam.get()){
//            procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
//        }
//    }


};

#endif /* NearFar_PixelProc_hpp */
