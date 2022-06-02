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
    ofParameter<float> speedWParam = ofParameter<float>("speedW",0.5,0.0,1.0);
    ofParameter<float> speedHParam = ofParameter<float>("speedH",0.5,0.0,1.0);

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
        group.add(speedWParam);
        group.add(speedHParam);
        gui.add(group);

        procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);
        fbo.allocate(model.depthCameraWidth, model.depthCameraHeight, GL_RGBA);
    
        randomParam.addListener(this, &Generator_PixelProc::onRandomParam);
        
        makeBlobs();
    }
    
    void onRandomParam(bool& val){
        makeBlobs();
    }
    
    void makeBlobs(){

        gblobs.clear();
        
        // make some gblobs
        for(int i = 0; i < 4; i++){
            gblob b = {
                ofRandom(100,640-100),  // x
                float(480 * 0.8),       // y
                ofRandom(70,90),        // w
                ofRandom(100,190),      // h
                int(ofRandom(190,210)), // hue
                ofRandom(-15,15),       // delta
            };
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
                    gblobs[i].w += sin(ofGetFrameNum() * ofMap(i, 0, blobsParam.get(), 0.10, 0.28)  * speedWParam.get() ) * 1.1;
                    gblobs[i].h += sin(ofGetFrameNum() * ofMap(i, 0, blobsParam.get(), 0.03, 0.18) * speedHParam.get() ) * 1.1;
                }

                if(gblobs[i].x < 0){
                    gblobs[i].x = 0;
                    gblobs[i].delta *= -1;
                }
                if(gblobs[i].x > 540){
                    gblobs[i].x = 540;
                    gblobs[i].delta *= -1;
                }
                // draw it
                gblob gb = gblobs[i];
                ofSetColor(gb.hue);
                ofDrawRectRounded(gb.x, gb.y - gb.h, gb.w, gb.h, 10);
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
