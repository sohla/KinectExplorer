//
//  KinectManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#include "KinectDepthCamera.h"
#include "ofApp.h"

void KinectDepthCamera::setup(InputModel &im, DepthModel &model){
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    
    // enable depth->video image calibration
    kinect.setRegistration(true);
    
    //kinect.init();
//    kinect.init(true); // shows infrared instead of RGB video image
    kinect.init(false, true); // disable video image (faster fps)
    
    kinect.open();        // opens first available kinect
    //kinect.open(1);    // open a kinect by id, starting with 0 (sorted by serial # lexicographically))
    //kinect.open("A00362A08602047A");    // open a kinect using it's unique serial #

    kinect.setPixelFormat(OF_PIXELS_GRAY);

    // print the intrinsic IR sensor values
    if(kinect.isConnected()) {
        ofLogNotice() << "sensor-emitter dist: " << kinect.getSensorEmitterDistance() << "cm";
        ofLogNotice() << "sensor-camera dist:  " << kinect.getSensorCameraDistance() << "cm";
        ofLogNotice() << "zero plane pixel size: " << kinect.getZeroPlanePixelSize() << "mm";
        ofLogNotice() << "zero plane dist: " << kinect.getZeroPlaneDistance() << "mm";
        ofLogNotice() << "width: " << kinect.getWidth() << " height: " << kinect.getHeight();
        ofLogNotice() << "format: " << short(kinect.getPixelFormat());
    }
    im.kWidth = kinect.width;
    im.kHeight = kinect.height;

    model.kinectWidth = kinect.width;
    model.kinectHeight = kinect.height;
    
    kinect.setCameraTiltAngle(model.kinectAngle);

    
    //
//    mesh.setMode(OF_PRIMITIVE_POINTS);

}


//void KinectManager::update(InputModel &im){
//
//    
//}

void KinectDepthCamera::draw(InputModel &im){
    
    int width = im.kWidth * ofApp::scale;
    int height = im.kHeight * ofApp::scale;
    int div = im.sliders.get("divide").cast<int>();

    ofSetColor(255, 255, 255);
        
    if(kinect.isUsingTexture()){
        ofTexture flippedText = kinect.getTexture();
        flippedText.draw(width, 0, -width, height);
    }
}