//
//  OSCSender.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 29/5/2022.
//

#ifndef OSCSender_hpp
#define OSCSender_hpp

#include <stdio.h>


#include "ofxOscSender.h"
#include "ofxArgParser.h"

class OSCSender {

protected:
 
    ofxOscSender scSender;
    ofxOscSender tdSender;
    std::string scIP;
    std::string tdIP;

public:

    void sendOSCMessage(const ofxOscMessage &oscMessage);

};
#endif /* OSCSender_hpp */
