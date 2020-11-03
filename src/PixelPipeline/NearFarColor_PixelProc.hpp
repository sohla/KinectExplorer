//
//  NearFarColor_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef NearFarColor_PixelProc_hpp
#define NearFarColor_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class NearFarColor_PixelProc : public Base_PixelProc {

    ofParameter<bool> cvThreshParam = ofParameter<bool>("cv-threshold",false);
    ofParameter<int> nearParam = ofParameter<int>("near",0,200,255);
    ofParameter<int> farParam = ofParameter<int>("far",0,50,255);

    ofParameter<bool> horzInvertParam = ofParameter<bool>("horz-invert",false);
    ofParameter<bool> vertInvertParam = ofParameter<bool>("vert-invert",false);

    
    ofxCvGrayscaleImage depthImage;
    ofxCvGrayscaleImage grayThreshNear;
    ofxCvGrayscaleImage grayThreshFar;
    
    ofImage colorImage;
    ofPixels colorPixels;


    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(cvThreshParam);
        group.add(nearParam);
        group.add(farParam);
        group.add(horzInvertParam);
        group.add(vertInvertParam);
        gui.add(group);
        
        depthImage.allocate(model.depthCameraWidth, model.depthCameraHeight);
        grayThreshNear.allocate(model.depthCameraWidth, model.depthCameraHeight);
        grayThreshFar.allocate(model.depthCameraWidth, model.depthCameraHeight);
        
        colorImage.allocate(model.depthCameraWidth, model.depthCameraHeight, OF_IMAGE_COLOR_ALPHA);
        colorPixels.allocate(model.depthCameraWidth, model.depthCameraHeight, OF_IMAGE_COLOR_ALPHA);

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
                
            unsigned long w = colorPixels.getWidth();
            unsigned long h = colorPixels.getHeight();
        
            for(int i = 0; i < w; i++) {
                for(int j = 0; j < h; j++) {

                    ofColor pixCol = pix.getColor(i,j);
                    
                    int level = pix[i + (j * w)];
                    
                    if(level < nearParam.get() && level > farParam.get()) {
                        ofColor newCol = ofColor(255, 255);
                        colorPixels.setColor(i, j, newCol);
                    }else{
                        ofColor newCol = ofColor(pixCol, 0);
                        colorPixels.setColor(i, j, newCol);

                    }
                }
            }

            colorImage.setFromPixels(colorPixels);

            //            unsigned long numPixels = pix.size();
//            for(int i = 0; i < numPixels; i++) {
//                if(pix[i] < nearParam.get() && pix[i] > farParam.get()) {
//                    pix[i] = 255; // solid white
//                    //pix[i] = ofMap(pix[i], farParam.get(), nearParam.get(), 0, 255); // mapped to far-near
//                } else {
//                    pix[i] = 0;
//                }
//            }
            
//            colorImage.setFromPixels(pix);
        }
        
        //• its own proc!
        procImage.mirror(horzInvertParam.get(), vertInvertParam.get());
        

    };
    string title(){return "near far color";};
    
    void draw(const DepthModel &model){

        if(drawParam.get()){
//            procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
            colorImage.draw(0, 0, model.depthCameraWidth * model.depthCameraScale, model.depthCameraHeight * model.depthCameraScale);
        }
    }


};

#endif /* NearFarColor_PixelProc_hpp */
