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
#include "Base_LineProc.hpp"
#include <map>

class LinePipeline : public Base_PixelProc {
    
    string title(){return "pixel to point";};
    
    ofParameter<int> blobsParam = ofParameter<int>("blobs",1,0,MAX_BLOBS);
    ofParameter<int> thresholdParam = ofParameter<int>("threshold",127,0,255);
    ofParameter<int> minRadiusParam = ofParameter<int>("minRadius",30,0,255);
    ofParameter<int> maxRadiusParam = ofParameter<int>("maxRadius",160,0,255);
    ofParameter<int> persistanceParam = ofParameter<int>("persistance",15,0,300);
    ofParameter<int> distanceParam = ofParameter<int>("distance",32,0,255);

    vector<Base_LineProc*> processors;
    map<int, BlobModel> blobs;
    
    void proc(){};

    
    
public:
    
    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPixels process(const DepthModel &model, const ofPixels &pixel);

    
protected:

    ofxCv::ContourFinder contourFinder;
    ofxCv::RectTrackerFollower<BlobModel> trackerFollower;
    
};



#endif /* LinePipeline_hpp */
