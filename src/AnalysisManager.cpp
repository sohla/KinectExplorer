//
//  AnalysisManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#include "AnalysisManager.h"


void AnalysisManager::setup(InputModel &im){

    int width = im.kWidth;
    int height = im.kHeight;

    depthImage.allocate(width, height);
    grayThreshNear.allocate(width, height);
    grayThreshFar.allocate(width, height);

    nearThreshold = 225;
    farThreshold = 150;
    bThreshWithOpenCV = true;
    
    for(int j = 0; j < 64; j++){
        ofVec3f v = ofVec3f(0,0,0);
        storedLine.addVertex(v);
    }
    
    sender.setup(HOST, PORT);

    ofxOscMessage m;
    m.setAddress("/gyrosc/button");
    m.addFloatArg(1.0);
    sender.sendMessage(m, false);

}

void AnalysisManager::update(InputModel &im, const ofPixels &pixels){

    nearThreshold = im.sliders.get("near").cast<int>() * 2;
    farThreshold = im.sliders.get("far").cast<int>() * 2;

    bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();

    // load gray image from source
    depthImage.setFromPixels(pixels);

    if(im.switches.get("Blur").cast<bool>()){
        depthImage.blurHeavily();
    }

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
    
    depthImage.dilate();
    
    depthImage.flagImageChanged();
    depthImage.mirror(false, true);

    int count = im.sliders.get("blobCount").cast<int>();
    int min = 1;
    int max = (im.kWidth * im.kHeight) / 3;
    
    contourFinder.findContours(depthImage, min, max, count, false);

    
}

void AnalysisManager::draw(InputModel &im){
   
    int width = im.kWidth;
    int height = im.kHeight;
    int div = im.sliders.get("divide").cast<int>();
    
    if(im.switches.get("DrawGray").cast<bool>()){
        ofSetHexColor(0xFFFFFF);
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
        
        float area = ofMap(blob.area, 20000, 100000, 0.1, 4.0);
        
        ofxOscMessage m;
        m.setAddress("/gyrosc/rrate");
        m.addFloatArg(area);
        m.addFloatArg(area);
        m.addFloatArg(area);
        sender.sendMessage(m, false);

        //std::cout << blob.area << " " << area << m << std::endl;
        div = blob.nPts;
        
        ofPolyline outline;
        spline2D.reserve(div);
        storedLine.resize(div);

        for(int j = 0; j < div; j++){

            ofVec3f v = polyline[j];//ofVec3f(polyline.getPointAtPercent( float(1.0 / div) * j ));
            ofVec3f o = storedLine[j];
            float f = 0.2;// TODO add control!s

            o.x = (f * v.x + ((1.0 - f) * o.x));
            o.y = (f * v.y + ((1.0 - f) * o.y));

            outline.addVertex(v);
            storedLine[j] = o;
            spline2D.push_back(o);
        }

//        outline.close();


//        storedLine[div-1] = storedLine[0];
//        ofVec3f v = storedLine[0];
//        spline2D.push_back(v);

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

            drawInterpolatorSmooth(spline2D, div, 0, 2);
            glPopMatrix();

            spline2D.clear();
        }
    }
}

void AnalysisManager::exit(){
    
}
