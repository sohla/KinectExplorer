//
//  Base_LineProc.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#include "Base_LineProc.hpp"

void Base_LineProc::setup(ofxPanel &gui){

    ofParameterGroup group;

    group.setName(title());
    group.add(onParam);
    group.add(drawParam);
    gui.add(group);

    // default behaviour keeps group closed
    gui.getGroup(title()).minimize();
    
    for(int i=0; i< MAX_BLOBS; i++){
        procLines.push_back(ofPolyline());
    }

}

void Base_LineProc::draw(const DepthModel &model){
    
    if(drawParam.get()){
        ofPushMatrix();
        ofScale( model.kinectScale);
        
        for( auto &line : procLines ){
            line.draw();
        };

        ofPopMatrix();
    }
}

ofPolyline Base_LineProc::process(const int &index, const ofPolyline &line){

    if(onParam.get()){
        procLines[index] = line;
    }
    return procLines[index];
}

string Base_LineProc::title(){
    return "line base";
}

