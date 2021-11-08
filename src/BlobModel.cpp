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
    
    ofxOscMessage m;
    m.setAddress("/ke/init");
    m.addIntArg(label);
    sender.sendMessage(m, false);


    sendData();
}

void BlobModel::update(const cv::Rect& track) {

    state = updateState;

    float curTime = ofGetElapsedTimef();
    std::cout << curTime << ": " << getLabel() << ": update" << std::endl;

    sendData();

}

void BlobModel::kill() {

    float curTime = ofGetElapsedTimef();

    state = deinitState;
    dead = true;
    currentRect = cv::Rect(0,0,0,0);
    line.clear();
    line.addVertex(0,0,0);
    previousPosition = ofVec2f(0,0);
    currentPosition = ofVec2f(0,0);
        
    sendData();
    
    ofxOscMessage m;
    m.setAddress("/ke/deinit");
    m.addIntArg(label);
    sender.sendMessage(m, false);

    std::cout << curTime << ": " << getLabel() << ": deinit" <<  std::endl;

}

void BlobModel::sendData(){

    ofPolyline currLine = line.getResampledByCount(32);
    
    ofxOscMessage m;
    m.setAddress("/ke/update");
    
    float area = ofMap(line.getArea(), 0, -100000, 0.0, 1.0); // range is approx
    float perimeter = ofMap(line.getPerimeter(), 0, 5000, 0.0, 1.0); // range is approx

    glm::vec2 center = line.getCentroid2D(); // range 0..640:0..480 (pixels of cam)
    ofRectangle bounds = line.getBoundingBox();  // range 0..640:0..480 (pixels of cam)

//     std::cout << " : " << line.size() << " : " << area << " : " << perimeter << center << " : " ;
    
    
    
    m.addIntArg(getLabel());//0
    m.addIntArg(state);//1

    m.addFloatArg(area);//2
    m.addFloatArg(perimeter);//3

    m.addFloatArg(ofMap(center.x, 0, 640, 0.0, 1.0));//4
    m.addFloatArg(ofMap(center.y, 0, 480, 0.0, 1.0));//5

    m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));//6
    m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));//7

    m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));//8
    m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));//9

    m.addInt32Arg(index);//10•••••
    
    m.addInt32Arg(velocity.x);//11
    m.addInt32Arg(velocity.y);//12

    m.addInt32Arg(currLine.size());//13

    for( auto &vert :  currLine.getVertices()){//14..( size = //10)
        m.addDoubleArg(vert.x);
        m.addDoubleArg(vert.y);
        //std::cout << vert.x << " , " << vert.y;
    }

    sender.sendMessage(m, false);
}
