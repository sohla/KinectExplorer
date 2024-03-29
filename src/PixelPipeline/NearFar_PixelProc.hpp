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
    ofParameter<int> farParam = ofParameter<int>("far",0,5,255);
    ofParameter<bool> mapParam = ofParameter<bool>("map",false);

    ofParameter<bool> horzInvertParam = ofParameter<bool>("horz-invert",false);
    ofParameter<bool> vertInvertParam = ofParameter<bool>("vert-invert",false);

    ofParameter<float> cropTopParam = ofParameter<float>("cropTop",0.3,0.0,1.0);
    ofParameter<float> cropBotParam = ofParameter<float>("cropBot",0.75,0.0,1.0);

    ofParameter<float> cropRightParam = ofParameter<float>("cropRight",1.0,0.6,1.0);
    ofParameter<float> cropLeftParam = ofParameter<float>("cropLeft",0.0,0.0,0.4);

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
        group.add(cropTopParam);
        group.add(cropBotParam);
        group.add(cropLeftParam);
        group.add(cropRightParam);
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
            
            unsigned long w = pix.getWidth();
            unsigned long h = pix.getHeight();

            // row / col implentation
            for(int i = 0; i < w; i++) {
                for(int j = 0; j < h; j++) {

                    int index = i + (j * w);

                    if(i >= (w * cropLeftParam.get()) && i <= (w * cropRightParam.get()) ){

                        if( index > (h * cropTopParam.get() * w) && index < (h * cropBotParam.get() * w)){ //hack cropping
                            
                            
                            if(pix[index] < nearParam.get() && pix[index] > farParam.get()) {
                                if(mapParam.get()){
                                    pix[index] = ofMap(pix[index], farParam.get(), nearParam.get(), 0, 255); // mapped to far-near
                                }else{
                                    pix[index] = 255; // solid white
                                };
                            } else {
                                pix[index] = 0;
                            };
                            
                        }else{
                            pix[index] = 0; //hack cropping
                        };
                    }else{
                        pix[index] = 0; //hack cropping
                    };
                
              };

                };

//            for(int i = 0; i < numPixels; i++) {
//                if(pix[i] < nearParam.get() && pix[i] > farParam.get()) {
//                    if(mapParam.get()){
//                        pix[i] = ofMap(pix[i], farParam.get(), nearParam.get(), 0, 255); // mapped to far-near
//                    }else{
//                        pix[i] = 255; // solid white
//                    }
//                } else {
//                    pix[i] = 0;
//                }
//            }
            procImage.setFromPixels(pix);
        }
        
        procImage.mirror(horzInvertParam.get(), vertInvertParam.get());

    };
    string title(){return "nearfar";};
    
//    void draw(const DepthModel &model){
//
//        if(drawParam.get()){
//            procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
//        }
//    }


};

#endif /* NearFar_PixelProc_hpp */
