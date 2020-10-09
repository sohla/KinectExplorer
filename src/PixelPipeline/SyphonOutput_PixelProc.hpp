//
//  SyphonOutput_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef SyphonOutput_PixelProc_hpp
#define SyphonOutput_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class SyphonOutput_PixelProc : public Base_PixelProc {

    ofTexture tex;
    ofxSyphonServer keServer;


    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
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

#endif /* SyphonOutput_PixelProc_hpp */
