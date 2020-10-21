//
//  Smooth_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Smooth_LineProc_hpp
#define Smooth_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

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

        gui.getGroup(title()).maximize();

        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
    }
    
    ofPolyline process(const BlobModel &blob){

        if(onParam.get()){
            procLines[blob.index] = blob.line.getSmoothed(smoothParam.get());
        }else{
            procLines[blob.index] = blob.line;
        }
        return procLines[blob.index];
    }
};
#endif /* Smooth_LineProc_hpp */
