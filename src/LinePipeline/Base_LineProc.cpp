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
    
}

void Base_LineProc::draw(const DepthModel &model, const BlobModel &blob){
    
    if(drawParam.get()){
        ofPushMatrix();
        ofScale( model.depthCameraScale);
        ofSetColor(ofColor::fromHsb(blob.randomHue, 255 ,255));
        blob.line.draw();
        ofPopMatrix();
    }
}

void Base_LineProc::process(BlobModel &blob){

}

string Base_LineProc::title(){
    return "line base";
}

