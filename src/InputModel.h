//
//  InputModel.h
//  kinectExplorer
//
//  Created by Stephen OHara on 31/7/19.
//

#ifndef InputModel_h
#define InputModel_h

#include <stdio.h>
#include "ofMain.h"

using namespace std;

struct InputModel {

    int kWidth = 0;
    int kHeight = 0;
    int kinectAngle = -20;
    /*
     var names = [
     "near",
     "far",
     "blobCount",
     "divide"
     ];
     var specs = [
     [0,127,\lin,1].asSpec,
     [0,127,\lin,1].asSpec,
     [1,4,\lin,1,1].asSpec,
     [3,16,\lin,1,3].asSpec,
     ];
     
     */
    
    ofParameter<bool>   switchValues[9] = {
        ofParameter<bool>("Realtime",true),
        ofParameter<bool>("UseCvThreshold",true),
        ofParameter<bool>("DrawDepth",true),
        ofParameter<bool>("DrawGray",false),
        ofParameter<bool>("Blur",false),
        ofParameter<bool>("DrawContour",false),
        ofParameter<bool>("Smooth",false),
        ofParameter<bool>("Resample",false),
        ofParameter<bool>("ApplyFilter",false),
    };

    
    ofParameter<int>   sliderIntValues[7] = {
        ofParameter<int>("near",0,50,127),
        ofParameter<int>("far",0,50,127),
        ofParameter<int>("blobCount",1,1,4),
        ofParameter<int>("smooth",3,0,100),
        ofParameter<int>("blur",3,0,100),
        ofParameter<int>("resample",24,4,100),
        ofParameter<int>("circle",1,0,100),
    };

    ofParameter<float>   sliderFloatValues[3] = {
        ofParameter<float>("filter",0.1,0.001,1.0),
        ofParameter<float>("bgAlpha",0.1,0.01,1.0),
        ofParameter<float>("blobAlpha",0.1,0.01,1.0),
    };

    ofParameterGroup        sliders;
    ofParameterGroup        switches;

    
    InputModel() {

        switches.setName("switches");

        for(int i = 0; i < 9 ; i++){
            switches.add(switchValues[i]);
        }

        sliders.setName("sliders");

        for(int i = 0; i < 7 ; i++){
            sliders.add(sliderIntValues[i]);
        }
        for(int i = 0; i < 3 ; i++){
            sliders.add(sliderFloatValues[i]);
        }
    }

};


#endif /* InputModel_h */
