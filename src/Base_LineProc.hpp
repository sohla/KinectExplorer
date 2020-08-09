//
//  Base_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#ifndef Base_LineProc_hpp
#define Base_LineProc_hpp

#include <stdio.h>
#include "LineProc.hpp"

class Base_LineProc : public LineProc {
    
    virtual string title();

public:
    
    void setup(ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPolyline process(const int &index, const ofPolyline &line);

protected:

    ofParameter<bool> drawParam = ofParameter<bool>("draw",false);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);

    vector<ofPolyline> procLines;
    
};



class Smooth_LineProc : public Base_LineProc {

    ofParameter<int> smoothParam = ofParameter<int>("smooth",10,0,100);

    string title(){
        return "smooth";
    }

    void setup(ofxPanel &gui){

        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(smoothParam);
        gui.add(group);

        // default behaviour keeps group closed
        gui.getGroup(title()).minimize();

        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
    }
    
    ofPolyline process(const int &index, const ofPolyline &line){

        if(onParam.get()){
            procLines[index] = line.getSmoothed(smoothParam.get());
        }
        return procLines[index];
    }
};

//• add resampled line
//• ICP ordered line to previous line
//• filter time - basic, dynamic (per point) 
//• osc out line



#endif /* Base_LineProc_hpp */
