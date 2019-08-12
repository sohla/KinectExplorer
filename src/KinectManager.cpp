//
//  KinectManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#include "KinectManager.h"


void KinectManager::setup(InputModel &im){
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    
    // enable depth->video image calibration
    kinect.setRegistration(true);
    
    kinect.init();
    //kinect.init(true); // shows infrared instead of RGB video image
    //kinect.init(false, false); // disable video image (faster fps)
    
    kinect.open();        // opens first available kinect
    //kinect.open(1);    // open a kinect by id, starting with 0 (sorted by serial # lexicographically))
    //kinect.open("A00362A08602047A");    // open a kinect using it's unique serial #
    
    // print the intrinsic IR sensor values
    if(kinect.isConnected()) {
        ofLogNotice() << "sensor-emitter dist: " << kinect.getSensorEmitterDistance() << "cm";
        ofLogNotice() << "sensor-camera dist:  " << kinect.getSensorCameraDistance() << "cm";
        ofLogNotice() << "zero plane pixel size: " << kinect.getZeroPlanePixelSize() << "mm";
        ofLogNotice() << "zero plane dist: " << kinect.getZeroPlaneDistance() << "mm";
        ofLogNotice() << "width: " << kinect.getWidth() << " height: " << kinect.getHeight();
    }
    im.kWidth = kinect.width;
    im.kHeight = kinect.height;

    // zero the tilt on startup
    angle = 25;
    kinect.setCameraTiltAngle(angle);
}




void KinectManager::draw(InputModel &im){
    
    int width = kinect.width;
    int height = kinect.height;
    int div = im.sliders.get("divide").cast<int>();

    ofSetColor(255, 255, 255);
    
    if(im.switches.get("DrawDepth").cast<bool>()){
        kinect.drawDepth(0, 0, width, height);
    }
}
