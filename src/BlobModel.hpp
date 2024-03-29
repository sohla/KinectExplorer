//
//  BlobModel.h
//  KinectExplorer
//
//  Created by Stephen OHara on 22/4/21.
//

#ifndef BlobModel_h
#define BlobModel_h

#include "ofxCv.h"
#include "OSCSender.hpp"

// handy model for collecting data from tracker and procs
// gets passed to everything for each frame

enum BlobState {
    initState = 1, updateState = 2, deinitState = 3
};

class BlobModel : public ofxCv::RectFollower {

protected:
    float startedDying;
    OSCSender oscSender;
    
public:
    
    BlobModel()
        :startedDying(0){

    }
    void setup(const cv::Rect& track);
    void update(const cv::Rect& track);
    void kill();

    void sendOSCMessage();
    void addDataToOSCMessage(ofxOscMessage &oscMessage);
    
    
    // useful data
    //•• make below protected?
    ofPolyline line;
    
    unsigned int index;

    ofVec2f previousPosition;
    ofVec2f currentPosition;
    
    ofVec2f previousVelocity;
    ofVec2f currentVelocity;
    
    ofVec2f acceleration;
    
    float velocityRate;
    float accelerationRate;

    
    cv::Rect currentRect;
    unsigned int randomHue;
    BlobState state;
    int depthCameraWidth;
    int depthCameraHeight;

private:
    

    void debug(){
        std::cout << "label:" << ofToString(label) << " index:" << ofToString(index) << std::endl;
    }
    
};

#endif /* BlobModel_h */
