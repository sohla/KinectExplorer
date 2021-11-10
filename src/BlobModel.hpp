//
//  BlobModel.h
//  KinectExplorer
//
//  Created by Stephen OHara on 22/4/21.
//

#ifndef BlobModel_h
#define BlobModel_h

#include "ofxCv.h"
#include "ofxOscSender.h"

// handy model for collecting data from tracker and procs
// gets passed to everything for each frame

enum BlobState {
//    enum type {
        initState = 1, updateState = 2, deinitState = 3
//    };
};

class BlobModel : public ofxCv::RectFollower {

protected:
    float startedDying;
    ofxOscSender scSender;
    ofxOscSender tdSender;

public:
    
    BlobModel()
        :startedDying(0){

    }
    void setup(const cv::Rect& track);
    void update(const cv::Rect& track);
    void kill();

    void sendOSCMessage();
    void addDataToOSCMessage();
    
    
    ofxOscMessage getOSCMessage(){return oscMessage;};
    
    
    //•• make below protected?
    ofPolyline line;
    
    unsigned int index;

    ofVec2f previousPosition;
    ofVec2f currentPosition;
    ofVec2f velocity;
    cv::Rect currentRect;
    unsigned int randomHue;
    BlobState state;
    
private:
    ofxOscMessage oscMessage;

    void debug(){
        std::cout << "label:" << ofToString(label) << " index:" << ofToString(index) << std::endl;
    }
    
};

#endif /* BlobModel_h */
