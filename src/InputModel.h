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
    
    ofParameter<bool>   switchValues[10] = {
        ofParameter<bool>("Realtime",true),
        ofParameter<bool>("UseCvThreshold",true),
        ofParameter<bool>("DrawDepth",true),
        ofParameter<bool>("DrawGray",false),
        ofParameter<bool>("Blur",false),
        ofParameter<bool>("DrawContour",false),
        ofParameter<bool>("DrawBlob",false),
        ofParameter<bool>("DrawOutline",false),
        ofParameter<bool>("DrawFilter",false),
        ofParameter<bool>("DrawSpline",false),
    };

    
    ofParameter<int>   sliderValues[4] = {
        ofParameter<int>("near",0,50,127),
        ofParameter<int>("far",0,50,127),
        ofParameter<int>("blobCount",1,1,4),
        ofParameter<int>("divide",3,3,16),//[3,16,\lin,1,3].asSpec,
    };
    
    ofParameterGroup        sliders;
    ofParameterGroup        switches;

    
    InputModel() {

        switches.setName("switches");

        for(int i = 0; i < 10 ; i++){
            switches.add(switchValues[i]);
        }

        sliders.setName("sliders");

        for(int i = 0; i < 4 ; i++){
            sliders.add(sliderValues[i]);
        }
    }

};


#endif /* InputModel_h */
