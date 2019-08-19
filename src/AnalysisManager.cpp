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

    // get from input model
    int blobCount = im.sliders.get("blobCount").cast<int>();
    int nearThreshold = im.sliders.get("near").cast<int>() * 2;
    int farThreshold = im.sliders.get("far").cast<int>() * 2;
    bool bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();
    int div = im.sliders.get("divide").cast<int>();

    int min = 1;
    int max = (im.kWidth * im.kHeight) / 3;

    // load gray image from source
    depthImage.setFromPixels(pixels);

    //---------------------------------------------------------------------------
    // PROCESS pipeline START
    //---------------------------------------------------------------------------

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
    
    //depthImage.dilate();
    
    depthImage.mirror(false, true);
    depthImage.flagImageChanged();

    // basic ofxCv working in the pipeline
    // need to hook it all up to input model (gui)
    ofxCv::Canny(depthImage, edge, 50, 130, 3);
    edge.update();
    
    //---------------------------------------------------------------------------
    // PROCESS pipeline END
    //---------------------------------------------------------------------------

    //---------------------------------------------------------------------------
    // ANALYSIS START
    //---------------------------------------------------------------------------

    contourFinder.findContours(depthImage, min, max, blobCount, false);

    for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {

        // loval polyline to iterate
        ofPolyline polyline;
        for(int j = 0; j < blob.nPts; j++){
            polyline.addVertex(ofVec3f(blob.pts[j].x, blob.pts[j].y));
        }
        polyline.close();

        dividedLine.clear();
        spline2D.reserve(div);
        storedLine.resize(div);
        
        // hand coded filter of div points
        for(int j = 0; j <= div; j++){
            
            ofVec3f v = ofVec3f(polyline.getPointAtPercent( float(1.0 / div) * j ));
            ofVec3f o = storedLine[j];
            float f = 0.2;// TODO add control!s
            
            o.x = (f * v.x + ((1.0 - f) * o.x));
            o.y = (f * v.y + ((1.0 - f) * o.y));
            
            dividedLine.addVertex(v);
            storedLine[j] = o;
            
        }
        
        dividedLine.close();
        
        storedLine[div-1] = storedLine[0];

        for(int j = 0; j <= div; j++){
            spline2D.push_back(storedLine[j]);
        }

        // OUTPUT ANALYSIS DATA
        float area = ofMap(blob.area, 20000, 100000, 0.1, 4.0);
        //std::cout << blob.area << " " << area << m << std::endl;

        
        float rocArea = (area - oldArea);
        
        filterLowPass.setFc(0.03);
        filterLowPass.update(abs(rocArea));

        float score = abs(filterLowPass.value()) * 5.0;
        
        
        float ms = ofMap(score, 0.0, 1.0, 0.1, 4.0);

        // move to oscTransmitterManager :
        ofxOscMessage m;
        m.setAddress("/gyrosc/rrate");
        m.addFloatArg(ms);
        m.addFloatArg(ms);
        m.addFloatArg(ms);
        sender.sendMessage(m, false);

//        std::cout << score << " " << ms << m << std::endl;

//        for(int i = 0; i < score; i++){
//            std::cout << "•";
//        };
//        std::cout << std::endl;
//        std::cout << filterLowPass.value() << std::endl;
        
        oldArea = area;
        
    });
}

void AnalysisManager::draw(InputModel &im){
   
    int width = im.kWidth;
    int height = im.kHeight;
    int div = im.sliders.get("divide").cast<int>();

    
//    ofSetHexColor(0xFF0000);
//    edge.draw(0,0);
    
    if(im.switches.get("DrawGray").cast<bool>()){
        
        ofSetHexColor(0xFFFFFF);
        depthImage.draw(0, 0, width, height);
    }

    if(im.switches.get("DrawContour").cast<bool>()){
        
        ofSetHexColor(0x00FFFF);
        contourFinder.draw(0, 0, width, height);
    }
    
    int nb = contourFinder.nBlobs;
    
    for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {
        

        if(im.switches.get("DrawFilter").cast<bool>()){

            ofSetHexColor(0x0000FF);
            storedLine.draw();
        }

        if(im.switches.get("DrawOutline").cast<bool>()){

            ofSetHexColor(0xFFFF00);
            dividedLine.draw();
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
    });
}

void AnalysisManager::exit(){
    
}
