//
//  Resample_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Resample_LineProc_hpp
#define Resample_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Resample_LineProc : public Base_LineProc {
    
    ofParameter<int> resampleParam = ofParameter<int>("resample",6,4,32);
    
    string title(){
        return "resample";
    }
    
    void setup(ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(resampleParam);
        gui.add(group);
        
        // default behaviour keeps group closed
        gui.getGroup(title()).minimize();
        
        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
    }
    
    ofPolyline process(const int &index, const ofPolyline &line){
        
        if(onParam.get()){
            procLines[index] = line.getResampledByCount(resampleParam.get());
        }else{
            procLines[index] = line;
        }
        return procLines[index];
    }
};
#endif /* Resample_LineProc_hpp */
