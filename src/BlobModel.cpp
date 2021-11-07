//
//  BlobModel.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/11/21.
//

//#include <stdio.h>
#include "BlobModel.hpp"



const float dyingTime = 0.1;

void BlobModel::setup(const cv::Rect& track) {
    
    // •• WARNING ••
    // Tracker.h code needed a fix : setting label before calling setup (line 423)
    
    float curTime = ofGetElapsedTimef();
    std::cout << curTime << ": " << getLabel() << ": setup" <<  std::endl;
    
    randomHue = ofRandom(0,255);
}

void BlobModel::update(const cv::Rect& track) {
    float curTime = ofGetElapsedTimef();
    std::cout << curTime << ": " << getLabel() << ": update" << std::endl;
    if(getDead()){
        std::cout << getDead() << ": " << getLabel() << ": kill" << std::endl;
    }
}

void BlobModel::kill() {

    float curTime = ofGetElapsedTimef();
    if(startedDying == 0) {
        startedDying = curTime;
    } else if(curTime - startedDying > dyingTime) {
        dead = true;
        std::cout << curTime << ": " << getLabel() << ": dead" <<  std::endl;
    }
}

