//
//  AnalysisManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#ifndef AnalysisManager_hpp
#define AnalysisManager_hpp

#include <stdio.h>
#include "ofMain.h"

#include "InputModel.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
//#include "MSAInterpolator.h"

#include "ofxCv.h"

#include "ofxBiquadFilter.h"

#include "ofxOsc.h"

#include "ofxPostProcessing.h"


// send host (aka ip address)
#define HOST "127.0.0.1"
// send port
#define PORT 57120

#define MAX_BLOBS 4

class AnalysisManager {
    
public:
    void setup(InputModel &im);
    void update(InputModel &im, const ofPixels &pixels, const ofMesh &inMesh);
    void draw(InputModel &im);
    void exit();
    
    ofxCvGrayscaleImage depthImage;
    
    ofxCvGrayscaleImage grayThreshNear;
    ofxCvGrayscaleImage grayThreshFar;

    ofxCvContourFinder contourFinder;
    
    ofImage edge;


    ofxOscSender            sender;

//    float                   oldArea;
//    ofxBiquadFilter1f       filterLowPass;
    
    std::vector<ofPolyline> smoothLines;
    std::vector<ofPolyline> resampledLines;
    
    ofEasyCam cam;

    ofxCv::ContourFinder finder;
    std::vector<cv::Point> points;
    ofPolyline              finderLine;
    ofMesh                  mesh;

    ofxPostProcessing post;
    ofLight light;

};

#endif /* AnalysisManager_hpp */
