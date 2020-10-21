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
    
    ofParameter<int> resampleParam = ofParameter<int>("resample",6,4,100);
    
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
        
    }
    
    void process(BlobModel &blob){
        
        if(onParam.get()){
//            blob.line = blob.line.getResampledByCount(resampleParam.get());//• by oercentage!!>!?
            
            // so grab points using percentages
            ofPolyline currLine;
            for(float i = 0.0; i < 100.0; i+= (100.0/ resampleParam.get() )){
                float pi = blob.line.getIndexAtPercent(i/100.0);
                currLine.addVertex(blob.line[floor(pi)]);
            }
            currLine.setClosed(true);
            blob.line = currLine;
        }
    }
};
#endif /* Resample_LineProc_hpp */
