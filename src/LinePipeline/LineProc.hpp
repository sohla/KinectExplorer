//
//  LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#ifndef LineProc_hpp
#define LineProc_hpp

#include <stdio.h>
#include "ofxGui.h"

#include "ofxOpenCv.h"
#include "ofxCv.h"

#include "PixelProc.hpp"

#define MAX_BLOBS 4


// handy model for collecting data from tracker and procs
// gets passed to everything for each frame

struct BlobModel {

    ofPolyline line;
    
    unsigned int label;
    unsigned int index;

    ofVec2f previousPosition;
    ofVec2f currentPosition;
    ofVec2f velocity;
    int age;
    
    
    void debug(){
        std::cout << "label:" << ofToString(label) << " index:" << ofToString(index) << std::endl;
    }
    
};


class LineProc {
    
public:
    
    virtual void setup(ofxPanel &gui) = 0;
    virtual void draw(const DepthModel &model, const BlobModel &blob) = 0;
    virtual void process(BlobModel &blob) = 0;
    

};

#endif /* LineProc_hpp */
