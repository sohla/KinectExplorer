//
//  KinectManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#include "KinectCamera.h"
#include "ofApp.h"

void KinectCamera::setup(InputModel &im){
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    
    // enable depth->video image calibration
    kinect.setRegistration(true);
    
    //kinect.init();
    kinect.init(true); // shows infrared instead of RGB video image
    //kinect.init(false, false); // disable video image (faster fps)
    
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

    // tilt on startup
//    kinect.setCameraTiltAngle(-20);
    kinect.setCameraTiltAngle(-30);

    
    //
//    mesh.setMode(OF_PRIMITIVE_POINTS);

}


//void KinectManager::update(InputModel &im){
//
//    
//}

void KinectCamera::draw(InputModel &im){
    
    int width = im.kWidth * ofApp::scale;
    int height = im.kHeight * ofApp::scale;
    int div = im.sliders.get("divide").cast<int>();

    ofSetColor(255, 255, 255);
    
    if(im.switches.get("DrawDepth").cast<bool>()){
        
        // kinect.drawDepth(0, 0, width, height);
        //kinect.draw(0, 0, width, height);
        
        if(kinect.isUsingTexture()){
            ofTexture flippedText = kinect.getTexture();
            flippedText.draw(width, 0, -width, height);
        }
    }
}
