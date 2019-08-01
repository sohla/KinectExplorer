//
//  KinectManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef KinectManager_hpp
#define KinectManager_hpp

#include <stdio.h>
#include "Model.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
#include "MSAInterpolator.h"

class KinectManager {
    
public:

    void setup(InputModel &im);
    void update(InputModel &im);
    void draw(InputModel &im);
    
    ofxKinect kinect;
    
    ofxCvGrayscaleImage grayImage; // grayscale depth image
    ofxCvGrayscaleImage grayThreshNear; // the near thresholded image
    ofxCvGrayscaleImage grayThreshFar; // the far thresholded image

    bool bThreshWithOpenCV;
    
    int nearThreshold;
    int farThreshold;
    
    int angle;

    ofxCvContourFinder contourFinder;

    ofPolyline              storedLine;
    
    msa::Interpolator2D     spline2D;

};


#endif /* KinectManager_hpp */


