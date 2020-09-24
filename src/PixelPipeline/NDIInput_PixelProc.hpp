//
//  NDIInput_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef NDIInput_PixelProc_hpp
#define NDIInput_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"
/*
 
    NOTES ON USE:
 
    16-bit
    60 fps
    no alpha
    640 x 480
 
 
 */

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

#endif /* NDIInput_PixelProc_hpp */
