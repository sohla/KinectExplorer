//
//  RealSenseDepthCamera.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 3/11/20.
//

#include "RealSenseDepthCamera.h"

void RealSenseDepthCamera::setup(DepthModel &model){
    
//    ofSetLogLevel(OF_LOG_VERBOSE);
//
//    // enable depth->video image calibration
//    kinect.setRegistration(true);
//
//    //kinect.init();
////    kinect.init(true); // shows infrared instead of RGB video image
//    kinect.init(false, true); // disable video image (faster fps)
//
//    kinect.open();        // opens first available kinect
//    //kinect.open(1);    // open a kinect by id, starting with 0 (sorted by serial # lexicographically))
//    //kinect.open("A00362A08602047A");    // open a kinect using it's unique serial #
//
//    kinect.setPixelFormat(OF_PIXELS_GRAY);
//
//    // print the intrinsic IR sensor values
//    if(kinect.isConnected()) {
//        ofLogNotice() << "sensor-emitter dist: " << kinect.getSensorEmitterDistance() << "cm";
//        ofLogNotice() << "sensor-camera dist:  " << kinect.getSensorCameraDistance() << "cm";
//        ofLogNotice() << "zero plane pixel size: " << kinect.getZeroPlanePixelSize() << "mm";
//        ofLogNotice() << "zero plane dist: " << kinect.getZeroPlaneDistance() << "mm";
//        ofLogNotice() << "width: " << kinect.getWidth() << " height: " << kinect.getHeight();
//        ofLogNotice() << "format: " << short(kinect.getPixelFormat());
//    }

//    model.kinectWidth = kinect.width;
//    model.kinectHeight = kinect.height;
    
//    kinect.setCameraTiltAngle(model.kinectAngle);

    model.depthCameraWidth = 640;
    model.depthCameraHeight = 360;

    
    _pixels.allocate(model.depthCameraWidth,
                     model.depthCameraHeight,
                     OF_PIXELS_RGB);
    realsense.setupDevice(0);
    realsense.setupDepth(model.depthCameraWidth, model.depthCameraHeight, 30);
    realsense.startPipeline(true);


}


void RealSenseDepthCamera::update(std::function<void(const ofPixels &pixels)> updatedPixels){
    
    realsense.update();
    
    realsense.getDepthTex()->readToPixels(_pixels);
    _pixels.setImageType(OF_IMAGE_GRAYSCALE);
    updatedPixels(_pixels);
    
    
    
}

void RealSenseDepthCamera::draw(DepthModel &model){
    
    int width = model.depthCameraWidth * model.depthCameraScale;
    int height = model.depthCameraHeight * model.depthCameraScale;

    ofSetColor(255, 255, 255);
    
    realsense.getDepthTex()->draw(0, 0, width, height);
        
//    if(kinect.isUsingTexture()){
//        ofTexture flippedText = kinect.getTexture();
//        flippedText.draw(width, 0, -width, height);
//    }
}
