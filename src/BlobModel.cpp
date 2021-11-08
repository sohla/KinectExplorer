//
//  BlobModel.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/11/21.
//

//#include <stdio.h>
#include "BlobModel.hpp"



const float dyingTime = 0.5;

void BlobModel::setup(const cv::Rect& track) {
    
    // •• WARNING ••
    // Tracker.h code needed a fix : setting label before calling setup (line 423)

    state = initState;
    randomHue = ofRandom(0,255);

    float curTime = ofGetElapsedTimef();
    std::cout << curTime << ": " << getLabel() << ": init" <<  std::endl;
    
}

void BlobModel::update(const cv::Rect& track) {

    state = updateState;

    float curTime = ofGetElapsedTimef();
    std::cout << curTime << ": " << getLabel() << ": update" << std::endl;
}

void BlobModel::kill() {

    float curTime = ofGetElapsedTimef();
//
//    if(startedDying == 0) {
//
//        startedDying = curTime;
//
//    } else if(curTime - startedDying > dyingTime) {

        state = deinitState;
        dead = true;
        
        std::cout << curTime << ": " << getLabel() << ": deinit" <<  std::endl;
//    }
}

