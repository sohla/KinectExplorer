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
#include "MSAInterpolator.h"

#include "ofxCv.h"

#include "ofxBiquadFilter.h"

#include "ofxOsc.h"
// send host (aka ip address)
#define HOST "127.0.0.1"

/// send port
#define PORT 57120

class AnalysisManager {
    
public:
    void setup(InputModel &im);
    void update(InputModel &im, const ofPixels &pixels);
    void draw(InputModel &im);
    void exit();
    
    ofxCvGrayscaleImage depthImage; // grayscale depth image
    ofxCvGrayscaleImage grayThreshNear; // the near thresholded image
    ofxCvGrayscaleImage grayThreshFar; // the far thresholded image

    ofxCvContourFinder contourFinder;

    ofPolyline              dividedLine;
    ofPolyline              storedLine;

    msa::Interpolator2D     spline2D;

    ofxOscSender sender;
    
    ofImage edge;
    
    float oldArea;
    ofxBiquadFilter1f filterLowPass;
};

#endif /* AnalysisManager_hpp */
