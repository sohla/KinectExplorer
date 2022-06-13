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
    std::string sp = "57120";
    std::string tp = "57130";

    if(ofxArgParser::hasKey("sc")){
        scip = ofxArgParser::getValue("sc");
    }

    if(ofxArgParser::hasKey("td")){
        tdip = ofxArgParser::getValue("td");
    }

    if(ofxArgParser::hasKey("sp")){
        sp = ofxArgParser::getValue("sp");
    }

    if(ofxArgParser::hasKey("tp")){
        tp = ofxArgParser::getValue("tp");
    }

    scSender.setup(scip, stoi(sp));
    scSender.sendMessage(oscMessage, false);

    tdSender.setup(tdip, stoi(tp));
    tdSender.sendMessage(oscMessage, false);
}



