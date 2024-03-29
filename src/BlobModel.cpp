//
//  BlobModel.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 6/11/21.
//

//#include <stdio.h>
#include "BlobModel.hpp"
/*
 
 OSC API
 
 Command        Notes
 /ke/init       sent for each follower setup called followed by data.
 /ke/update     sent for each follower update called followed by data.
 /ke/deinit     sent for each follower kill called followed by data.
 
 Index      Data
 0          label
 1          state
 2          area
 3          perimeter
 4          center x
 5          center y
 6          bounds x
 7          bounds y
 8          bounds width
 9          bounds height
 10         index
 11         velocity x
 12         velocity y
 13         vertices size
 14         vertices[x0,y0,x1,y1...]
 
 
 */

const float dyingTime = 0.5;

void BlobModel::setup(const cv::Rect& track) {
    
    // •• WARNING ••
    // Tracker.h code needed a fix : setting label before calling setup (line 423)

    state = initState;
    randomHue = ofRandom(0,255);

    //build message
    ofxOscMessage oscMessage;
    oscMessage.setAddress("/ke/init");
    addDataToOSCMessage(oscMessage);
    oscSender.sendOSCMessage(oscMessage);

//    float curTime = ofGetElapsedTimef();
//   std::cout << curTime << ": " << getLabel() << ": init" <<  std::endl;

}


void BlobModel::update(const cv::Rect& track) {

    state = updateState;

//    float curTime = ofGetElapsedTimef();
//    std::cout << curTime << ": " << getLabel() << ": update" << std::endl;
    ofxOscMessage oscMessage;
    oscMessage.setAddress("/ke/update");
    addDataToOSCMessage(oscMessage);
    oscSender.sendOSCMessage(oscMessage);

}

void BlobModel::addDataToOSCMessage(ofxOscMessage &oscMessage){

    ofPolyline currLine = line.getResampledByCount(127);
    
    float area = ofMap(line.getArea(), 0, -100000, 0.0, 1.0); // range is approx
    float perimeter = ofMap(line.getPerimeter(), 0, 5000, 0.0, 1.0); // range is approx

    glm::vec2 center = line.getCentroid2D(); // range 0..640:0..480 (pixels of cam)
    ofRectangle bounds = line.getBoundingBox();  // range 0..640:0..480 (pixels of cam)

//     std::cout << " : " << line.size() << " : " << area << " : " << perimeter << center << " : " ;
    
    //send dimensions of camera img

    oscMessage.addIntArg(getLabel());//0
    oscMessage.addIntArg(state);//1

    oscMessage.addFloatArg(area);//2
    oscMessage.addFloatArg(perimeter);//3

    oscMessage.addFloatArg(ofMap(center.x, 0, depthCameraWidth, 0.0, 1.0));//4
    oscMessage.addFloatArg(ofMap(center.y, 0, depthCameraHeight, 0.0, 1.0));//5

    oscMessage.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));//6
    oscMessage.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));//7

    oscMessage.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));//8
    oscMessage.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));//9

    oscMessage.addIntArg(depthCameraWidth);// 10
    oscMessage.addIntArg(depthCameraHeight);// 11

    
    oscMessage.addInt32Arg(index);//12 internal use : current index within followers array
    
    oscMessage.addFloatArg(currentVelocity.x);//13
    oscMessage.addFloatArg(currentVelocity.y);//14
    
    oscMessage.addFloatArg(acceleration.x);//15
    oscMessage.addFloatArg(acceleration.y);//16

    oscMessage.addFloatArg(velocityRate);//17
    oscMessage.addFloatArg(accelerationRate);//18

    oscMessage.addInt32Arg(currLine.size());//19
    
    for( auto &vert :  currLine.getVertices()){//20..( size = //15)
        oscMessage.addDoubleArg(vert.x);
        oscMessage.addDoubleArg(vert.y);
        //std::cout << vert.x << " , " << vert.y;
    }
}

void BlobModel::kill() {

    state = deinitState;
    dead = true;
    currentRect = cv::Rect(0,0,0,0);
    line.clear();
    line.addVertex(0,0,0);
    previousPosition = ofVec2f(0,0);
    currentPosition = ofVec2f(0,0);
        
    // build message
    ofxOscMessage oscMessage;
    oscMessage.setAddress("/ke/deinit");
    oscMessage.addIntArg(label);
    oscSender.sendOSCMessage(oscMessage);

//    float curTime = ofGetElapsedTimef();
//    std::cout << curTime << ": " << getLabel() << ": deinit" <<  std::endl;

}
