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

    depthImage.allocate(kinect.width, kinect.height);
    grayThreshNear.allocate(kinect.width, kinect.height);
    grayThreshFar.allocate(kinect.width, kinect.height);
    
    nearThreshold = 225;
    farThreshold = 150;
    bThreshWithOpenCV = true;
    
    ofSetFrameRate(60);
    
    // zero the tilt on startup
    angle = 25;
    kinect.setCameraTiltAngle(angle);
    
 
    
    for(int j = 0; j < 16; j++){
        ofVec3f v = ofVec3f(0,0,0);
        storedLine.addVertex(v);
    }

}

void KinectManager::update(InputModel &im){
    
    
    nearThreshold = im.sliders.get("near").cast<int>() * 2;
    farThreshold = im.sliders.get("far").cast<int>() * 2;

    bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();
    
    kinect.update();
    
    // there is a new frame and we are connected
    if(kinect.isFrameNew()) {
        
        // load grayscale depth image from the kinect source
        depthImage.setFromPixels(kinect.getDepthPixels());
        
        // we do two thresholds - one for the far plane and one for the near plane
        // we then do a cvAnd to get the pixels which are a union of the two thresholds
        if(bThreshWithOpenCV) {
            grayThreshNear = depthImage;
            grayThreshFar = depthImage;
            grayThreshNear.threshold(nearThreshold, true);
            grayThreshFar.threshold(farThreshold);
            cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), depthImage.getCvImage(), NULL);
        } else {
            
            // or we do it ourselves - show people how they can work with the pixels
            ofPixels & pix = depthImage.getPixels();
            unsigned long numPixels = pix.size();
            for(int i = 0; i < numPixels; i++) {
                if(pix[i] < nearThreshold && pix[i] > farThreshold) {
                    pix[i] = 255;
                } else {
                    pix[i] = 0;
                }
            }
        }
        
        // update the cv images
        depthImage.flagImageChanged();
        depthImage.mirror(false, true);
        
        int count = im.sliders.get("blobCount").cast<int>();
        int min = 1;
        int max = (kinect.width * kinect.height) / 3;
        contourFinder.findContours(depthImage, min, max, count, false);

    }
}

void KinectManager::draw(InputModel &im){
    
    int width = kinect.width;
    int height = kinect.height;
    int div = im.sliders.get("divide").cast<int>();

    ofSetColor(255, 255, 255);
    
    if(im.switches.get("DrawDepth").cast<bool>()){
        kinect.drawDepth(0, 0, width, height);
    }

    if(im.switches.get("DrawGray").cast<bool>()){
        depthImage.draw(0, 0, width, height);
    }

    if(im.switches.get("DrawContour").cast<bool>()){
        ofSetHexColor(0x00FFFF);
        contourFinder.draw(0, 0, width, height);
    }
    int nb = contourFinder.nBlobs;

    
    for (int i=0; i<nb; i++) {
        ofxCvBlob blob = contourFinder.blobs[i];

        ofPolyline polyline;
        for(int j = 0; j < blob.nPts; j++){
            polyline.addVertex(ofVec3f(blob.pts[j].x, blob.pts[j].y));
        }
        polyline.close();
        
        if(im.switches.get("DrawBlob").cast<bool>()){
            ofSetHexColor(0xFF0000);
            polyline.draw();
        }
        
        ofPolyline outline;
        spline2D.reserve(div);
        storedLine.resize(div);
        
        for(int j = 0; j < div; j++){
            
            ofVec3f v = ofVec3f(polyline.getPointAtPercent( float(1.0 / div) * j ));
            ofVec3f o = storedLine[j];
            float f = 0.2;// TODO add control!s
            
            o.x = (f * v.x + ((1.0 - f) * o.x));
            o.y = (f * v.y + ((1.0 - f) * o.y));
            
            outline.addVertex(v);
            storedLine[j] = o;
            spline2D.push_back(o);
        }

        outline.close();


        storedLine[div-1] = storedLine[0];
        ofVec3f v = storedLine[0];
        spline2D.push_back(v);

        if(im.switches.get("DrawFilter").cast<bool>()){

            ofSetHexColor(0x0000FF);
            storedLine.draw();
        }

        if(im.switches.get("DrawOutline").cast<bool>()){
            
            ofSetHexColor(0xFFFF00);
            outline.draw();
        }

        if(im.switches.get("DrawSpline").cast<bool>()){


            spline2D.setInterpolation(msa::kInterpolationCubic);
            
            glPushMatrix();
            glColor3f(1, 0, 1);
            //inline void drawInterpolatorSmooth(Interpolator2D &spline, int numSteps, int dotSize = 8, int lineWidth = 2) {
            
            drawInterpolatorSmooth(spline2D, div, 0, 10);
            glPopMatrix();
            
            spline2D.clear();
        }


    }
    

}
