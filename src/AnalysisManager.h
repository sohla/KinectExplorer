//
//  AnalysisManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#ifndef AnalysisManager_hpp
#define AnalysisManager_hpp

#include <stdio.h>
#include "Model.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
#include "MSAInterpolator.h"

class AnalysisManager {
    
public:
    void setup(InputModel &im);
    void update(InputModel &im, const ofPixels &pixels);
    void draw(InputModel &im);
    void exit();
    
    ofxCvGrayscaleImage depthImage; // grayscale depth image
    ofxCvGrayscaleImage grayThreshNear; // the near thresholded image
    ofxCvGrayscaleImage grayThreshFar; // the far thresholded image

    bool bThreshWithOpenCV;

    int nearThreshold;
    int farThreshold;


    ofxCvContourFinder contourFinder;

    ofPolyline              storedLine;

    msa::Interpolator2D     spline2D;

};

#endif /* AnalysisManager_hpp */
