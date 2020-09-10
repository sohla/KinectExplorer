//
//  Base_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/8/20.
//

#ifndef Base_PixelProc_hpp
#define Base_PixelProc_hpp

#include <stdio.h>
#include "PixelProc.hpp"

#include "ofxSyphon.h"
#include "ofxNDISender.h"
#include "ofxNDISendStream.h"
#include "ofxNDIReceiver.h"
#include "ofxNDIRecvStream.h"

class Base_PixelProc : public PixelProc {
    
    virtual string title() = 0;
    virtual void proc() = 0;

public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &pixels);

protected:

    ofParameter<bool> drawParam = ofParameter<bool>("draw",false);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);

    ofxCvGrayscaleImage procImage;

};

//------------------------------------------------------------
//
//------------------------------------------------------------
class Dilate_PixelProc : public Base_PixelProc {
    
    void proc(){procImage.dilate();}
    string title(){return "dilate";};
};

//------------------------------------------------------------
//
//------------------------------------------------------------
class Erode_PixelProc : public Base_PixelProc {
 
    void proc(){procImage.erode();}
    string title(){return "erode";};
};

//------------------------------------------------------------
//
//------------------------------------------------------------
class Blur_PixelProc : public Base_PixelProc {
    
    ofParameter<int> blurParam = ofParameter<int>("blur",3,0,100);

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(blurParam);
        gui.add(group);

        procImage.allocate(model.kinectWidth, model.kinectHeight);

    }

    void proc(){
        procImage.blurGaussian(1 + (blurParam.get() & ~1)); // bitwise not (even) + 1 is....odd
    };
    string title(){return "blur";};
};

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

//------------------------------------------------------------
//
//------------------------------------------------------------

class NDIInput_PixelProc : public Base_PixelProc {

//    ofTexture tex;
//    ofxSyphonServer keServer;
    ofxNDIReceiver receiver;
    ofxNDIRecvVideoFrameSync ndiVideo;
    ofPixels inPixels;
    ofImage inImage;
    ofxCvColorImage colorImage;

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName("keNDIReceiver");
        group.add(onParam);
        group.add(drawParam);
        gui.add(group);

        NDIlib_initialize();

        
        colorImage.allocate(model.kinectWidth, model.kinectHeight);
        
        
        auto findSource = [](const string &name_or_url) {
            auto sources = ofxNDI::listSources();
            if(name_or_url == "") {
                return make_pair(ofxNDI::Source(), false);
            }
            auto found = find_if(begin(sources), end(sources), [name_or_url](const ofxNDI::Source &s) {
                return ofIsStringInString(s.p_ndi_name, name_or_url) || ofIsStringInString(s.p_url_address, name_or_url);
            });
            if(found == end(sources)) {
                ofLogWarning("ofxNDI") << "no NDI source found by string:" << name_or_url;
                return make_pair(ofxNDI::Source(), false);
            }
            return make_pair(*found, true);
        };
        
        // Specify name or address of expected NDI source.
        // In case of blank or not found, receiver will grab default(which is found first) source.
        string name_or_url = "TouchDesigner";
        auto result = findSource(name_or_url);
        
        if(result.second ? receiver.setup(result.first) : receiver.setup()) {
            ndiVideo.setup(receiver);
        }

        
    }
    
    
    void proc(){

        // this is rather CPU intense
        if(receiver.isConnected()) {
            ndiVideo.update();
            if(ndiVideo.isFrameNew()) {
                ndiVideo.decodeTo(inPixels);
                inImage.setFromPixels(inPixels);

                // !! important !! must re-set this
                // https://forum.openframeworks.cc/t/cannot-convert-oftexture-or-ofimage-to-ofxcvcolorimage/30674
                inImage.setImageType(OF_IMAGE_COLOR);

                colorImage = inImage;
                procImage = colorImage;
                
            }
        }

    };
    
    void draw(const DepthModel &model){

        if(drawParam.get()){
            procImage.draw(0, 0 , model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
        }
    }

    string title(){return "ndi receiver";};
};

//------------------------------------------------------------
//
//------------------------------------------------------------

class SyphonOutput_PixelProc : public Base_PixelProc {

    ofTexture tex;
    ofxSyphonServer keServer;


    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName("keServer");
        group.add(onParam);
        group.add(drawParam);
        gui.add(group);
        
        tex.allocate(model.kinectWidth, model.kinectHeight, GL_RGBA);
        
        keServer.setName("keSyphonOutput");
    }
    
    
    void proc(){
        tex.loadData(procImage.getPixels());
        keServer.publishScreen();
        
        // not working : format and size?
        //keServer.publishTexture(&tex);
    };
    
    
    string title(){return "syphon server";};
};

//------------------------------------------------------------
//
//------------------------------------------------------------

class NDIOutput_PixelProc : public Base_PixelProc {

    ofxNDISender sender;
    ofxNDISendVideo video;

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName("ndi server");
        gui.add(group);
        
        if(sender.setup("keNDIOutput")) {
            video.setup(sender);
            video.setAsync(true);
        }

        auto pixelFormat = OF_PIXELS_BGRA;

    }

    void proc(){
        ofPixels p;
        ofGetGLRenderer()->saveFullViewport(p);
        video.send(p);
    };
    
    
    string title(){return "ndi sender";};
};

//------------------------------------------------------------

//• recorder proc
//• idn proc



#endif /* Base_PixelProc_hpp */
