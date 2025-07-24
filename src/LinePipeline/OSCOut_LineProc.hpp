//
//  OSCOut_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef OSCOut_LineProc_hpp
#define OSCOut_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"
#include "ofxOscSender.h"

//------------------------------------------------------------
//
//------------------------------------------------------------

class OSCOut_LineProc : public Base_LineProc {

    ofParameter<int> resampleParam = ofParameter<int>("resample",32,4,255);
    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57120");

    int numBlobs = 0;
    
//    vector<ofxOscSender*>    senders;
    ofxOscSender sender;
    
    string title(){
        return "line osc out " + portParam.get();
    }

    void setup(ofxPanel &gui){

        ofParameterGroup group;
        //•• add listening
        group.setName(title());
        group.add(onParam);
        group.add(ipParam);
        group.add(portParam);
        group.add(resampleParam);
        gui.add(group);

        // default behaviour keeps group closed
        gui.getGroup(title()).minimize();

        onParam.addListener(this, &OSCOut_LineProc::onOnParam);
    
    }
    
    
    void onOnParam(bool& val){

    };

    void process(BlobModel &blob){
        
        if(onParam.get()){

//            string::size_type sz;
//            int portInt = stoi( portParam.get(),&sz);
//            sender.setup(ipParam.get(), portInt);
//            sender.sendMessage(blob.getOSCMessage(), false);

            
            //    blob.addDataToOSCMessage();
            //    blob.sendOSCMessage();

        };
        
    };

    public:
        OSCOut_LineProc(string ip, string port){
        
            ipParam.set(ip);
            portParam.set(port);
            
        };

    void exit(){
        
        onParam.removeListener(this, &OSCOut_LineProc::onOnParam);
    };

};

#endif /* OSCOut_LineProc_hpp */
