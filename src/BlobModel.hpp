//
//  BlobModel.h
//  KinectExplorer
//
//  Created by Stephen OHara on 22/4/21.
//

#ifndef BlobModel_h
#define BlobModel_h

#include "ofxCv.h"

// handy model for collecting data from tracker and procs
// gets passed to everything for each frame

class BlobModel : public ofxCv::RectFollower {

protected:
    float startedDying;

public:
    
    BlobModel()
        :startedDying(0) {
    }
    void setup(const cv::Rect& track);
    void update(const cv::Rect& track);
    void kill();

    //•• make below protected?
    ofPolyline line;
    
//    unsigned int label;
    unsigned int index; //•• do we need this / always use label

    ofVec2f previousPosition;
    ofVec2f currentPosition;
    ofVec2f velocity;
    int age;
    
    unsigned int randomHue;
    
    
    void debug(){
        std::cout << "label:" << ofToString(label) << " index:" << ofToString(index) << std::endl;
    }
    
};

#endif /* BlobModel_h */
