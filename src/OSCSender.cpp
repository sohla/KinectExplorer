//
//  OSCSender.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 29/5/2022.
//

#include "OSCSender.hpp"



void OSCSender::sendOSCMessage(const ofxOscMessage &oscMessage){

    std::string scip = "127.0.0.1";
    std::string tdip = "127.0.0.1";

    if(ofxArgParser::hasKey("sc")){
        scip = ofxArgParser::getValue("sc");
    }

    if(ofxArgParser::hasKey("td")){
        tdip = ofxArgParser::getValue("td");
    }

    scSender.setup(scip, 57120);
    scSender.sendMessage(oscMessage, false);

    tdSender.setup(tdip , 57130);
    tdSender.sendMessage(oscMessage, false);
}



