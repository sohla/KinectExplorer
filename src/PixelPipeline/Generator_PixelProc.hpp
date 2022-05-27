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
    ofParameter<float> speedParam = ofParameter<float>("speed",0.5,0.0,1.0);

    vector<gblob> gblobs;
    
    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(blobsParam);
        group.add(randomParam);
        group.add(animateParam);
        group.add(speedParam);
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
                ofRandom(100,640-100),
                float(480 * 0.7),
                ofRandom(70,90),
                ofRandom(100,300),
                int(ofRandom(190,210)),
                ofRandom(-15,15),
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
                    gblobs[i].x += gblobs[i].delta * speedParam.get();
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
