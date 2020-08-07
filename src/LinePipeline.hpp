//
//  LinePipeline.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#ifndef LinePipeline_hpp
#define LinePipeline_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"
#include "LineProc.hpp"



class LinePipeline : public Base_PixelProc {
    
    string title(){return "pixel to point";};
    
    ofParameter<int> blobsParam = ofParameter<int>("blobs",1,0,MAX_BLOBS);

    vector<LineProc*> processors;

    void proc(){};
    
    
public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels);

protected:

    ofxCvContourFinder contourFinder;

};

#endif /* LinePipeline_hpp */
