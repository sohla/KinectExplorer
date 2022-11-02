//
//  RealSenseDepthCamera.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 3/11/20.
//

#include "RealSenseDepthCamera.h"

void RealSenseDepthCamera::setup(DepthModel &model){
    

    model.depthCameraWidth = 640;
    model.depthCameraHeight = 480;
    
    _pixels.allocate(model.depthCameraWidth,
                     model.depthCameraHeight,
                     OF_PIXELS_RGB);
    realsense.setupDevice(0);
    
    realsense.setupDepth(model.depthCameraWidth, model.depthCameraHeight, 60);
    realsense.startPipeline(true);


}

void RealSenseDepthCamera::exit(){
    realsense.exit();
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
