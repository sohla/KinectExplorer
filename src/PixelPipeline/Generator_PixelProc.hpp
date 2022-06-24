//
//  Generator_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 27/5/2022.
//

#ifndef Generator_PixelProc_hpp
#define Generator_PixelProc_hpp

#include "Base_PixelProc.hpp"


struct gblob {
    
    float x,y;
    float w,h;
    float dw, dh;
    int hue;
    float delta;

};
//------------------------------------------------------------
//
//------------------------------------------------------------

class Generator_PixelProc : public Base_PixelProc {
    
    ofFbo fbo;

    ofParameter<int> blobsParam = ofParameter<int>("blobs",1,0,4);
    ofParameter<bool> randomParam = ofParameter<bool>("random", false);
    ofParameter<bool> animateParam = ofParameter<bool>("animate", false);
    ofParameter<float> speedXParam = ofParameter<float>("speedX",0.5,0.0,1.0);
    ofParameter<float> deltaWParam = ofParameter<float>("deltaW",1.0,0.5,2.0);
    ofParameter<float> deltaHParam = ofParameter<float>("deltaH",1.0,0.5,2.0);
    
    vector<gblob> gblobs;
    
    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(blobsParam);
        group.add(randomParam);
        group.add(animateParam);
        group.add(speedXParam);
        group.add(deltaWParam);
        group.add(deltaHParam);
        gui.add(group);

        procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);
        fbo.allocate(model.depthCameraWidth, model.depthCameraHeight, GL_RGBA);
    
        randomParam.addListener(this, &Generator_PixelProc::onRandomParam);
        deltaWParam.addListener(this, &Generator_PixelProc::onDeltaWHParam);
        deltaHParam.addListener(this, &Generator_PixelProc::onDeltaWHParam);

        makeBlobs();
    }
    
    void onRandomParam(bool& val){
        makeBlobs();
    }
    
    void onDeltaWHParam(float& val){
        for(int i = 0; i < blobsParam.get(); i++){
            gblobs[i].dw = gblobs[i].w * deltaWParam.get();
            gblobs[i].dh = gblobs[i].h * deltaHParam.get();
        }
    }
    
    
    void makeBlobs(){

        gblobs.clear();
        
        // make some gblobs
        for(int i = 0; i < 4; i++){
            gblob b = {
                ofRandom(100,440),  // x
                float(480 * 0.8),       // y
                ofRandom(50,110),        // w
                ofRandom(80,240),      // h
                10,        // dw
                10,      // dh
                int(ofRandom(190,210)), // hue
                ofRandom(-15,15),       // delta
            };
            b.dw = b.w;
            b.dh = b.h;

            gblobs.push_back(b);
        };
    };

    void proc(){
        
        fbo.begin();
            ofClear(0);
        
            for(int i = 0; i < blobsParam.get(); i++){
                
                // animate blob
                if(animateParam.get()){
                    gblobs[i].x += gblobs[i].delta * speedXParam.get();
                }

                if(gblobs[i].x < 100){
                    gblobs[i].x = 100;
                    gblobs[i].delta *= -1;
                }
                if(gblobs[i].x > 440){
                    gblobs[i].x = 440;
                    gblobs[i].delta *= -1;
                }
                // draw it
                gblob gb = gblobs[i];
                ofSetColor(gb.hue);
                ofDrawRectRounded(gb.x, 250 - gb.dh , gb.dw, gb.dh, 10);
            };

        fbo.end();
        
        fbo.readToPixels(procImage.getPixels());
        
        // MUST reset image type as readToPixels re-allocates and sets internal format
        procImage.getPixels().setImageType(OF_IMAGE_GRAYSCALE);
        
    };

    void onBlobParam(bool& val){

    };
    
    string title(){return "generator";};
};


#endif /* Generator_PixelProc_hpp */
