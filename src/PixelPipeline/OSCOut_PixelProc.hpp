//
//  OSCOut_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef OSCOut_PixelProc_hpp
#define OSCOut_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"
#include "ofxOscSender.h"

//------------------------------------------------------------
//
//------------------------------------------------------------

class OSCOut_PixelProc : public Base_PixelProc {

    ofxOscSender            sender;

    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57140");

    ofPixels previous;
    ofImage diff;
    
    // a scalar is like an ofVec4f but normally used for storing color information
    cv::Scalar diffMean;

    
    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);

        group.add(ipParam);
        group.add(portParam);
        gui.add(group);
        
        procImage.allocate(model.kinectWidth, model.kinectHeight);

        ofxCv::imitate(previous, procImage);
        ofxCv::imitate(diff, procImage);

    }
    void draw(const DepthModel &model){

        if(drawParam.get()){
            procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
            
            diff.draw(0, 0);
        }
    }

    
    void proc(){

        // TODO procImage is getting mangled
        
        ofxCv::absdiff(procImage, previous, diff);
        diff.update();
        
        // like ofSetPixels, but more concise and cross-toolkit
        ofxCv::copy(procImage, previous);
        
        // mean() returns a Scalar. itofxCv::toCv cv:: function so we have to pass a Mat
        diffMean = mean(ofxCv::toCv(diff));
        
        // you can only do math between Scalars,
        // but it's eofxCv::toCvto make a Scalar from an int (shown here)
        diffMean *= cv::Scalar(10);

        string::size_type sz;
         int portInt = stoi( portParam.get(),&sz);
         sender.setup(ipParam.get(), portInt);

        ofxOscMessage m;
        m.setAddress("/ke/pixel");
        
        m.addDoubleArg(diffMean[0]);
        sender.sendMessage(m, false);
    };
    
    
    string title(){return "pixel osc out";};

    public:
        OSCOut_PixelProc(string ip, string port){
        
            ipParam.set(ip);
            portParam.set(port);
            
        };

};

#endif /* OSCOut_PixelProc_hpp */
