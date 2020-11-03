//
//  Ordered_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Ordered_LineProc_hpp
#define Ordered_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Ordered_LineProc : public Base_LineProc {
    
    
    //••• TODO :NEEDS WORK
    //••• ONLY FOR 1 BLOB!!!!
    
    
    ofParameter<float> filterParam = ofParameter<float>("f",0.1,0.01,0.5);

    const int ppSize = 128;
    
    ofPolyline previousLine;
    ofPolyline ordered;
    ofPolyline filtered;

    string title(){
        return "ordered";
    }
    
    void setup(ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(filterParam);
        gui.add(group);
        
        // default behaviour keeps group closed
        gui.getGroup(title()).maximize();
        
        for(int i=0; i< ppSize; i++){
            filtered.addVertex(0,0);
        }

    }
    
    ofDefaultVec2 closestPoint(ofPolyline line, ofDefaultVec2 p) {

        float rd = 10000000.0;
        ofDefaultVec2 op;
        
        for( auto lp : line) {
            
            ofDefaultVec2 delta = lp - p;
            float distance = sqrt(delta.x * delta.x + delta.y * delta.y);
            
            if(distance < rd){
                rd = distance;
                op = lp;
            }
        }
        
        return op;

    }
    
    
    void process(BlobModel &blob){
        
        if(onParam.get()){
            
            previousLine = blob.line;
            
            // new line
            blob.line = blob.line.getResampledByCount(ppSize);
            
            // order by finding closest of each point point from previos line
            ordered.clear();
            float f = filterParam.get();
//÷??            ofDefaultVec2 op = closestPoint(previousLine, blob.line);
     //       ordered.addVertex(op.x, op.y);

            // filter
            for (unsigned i = 0; i < ordered.size(); ++i){
                    filtered[i].x = (f * ordered[i].x + ((1.0 - f) * filtered[i].x));
                    filtered[i].y = (f * ordered[i].y + ((1.0 - f) * filtered[i].y));
            }

        }
    }
    
    void draw(const DepthModel &model, const BlobModel &blob){
        
        if(drawParam.get()){
            ofPushMatrix();
            ofScale( model.depthCameraScale);
            
            blob.line.draw();

            ofDrawCircle(blob.line[0].x, blob.line[0].y, 3);

//            ofSetColor(99, 0, 0);
//            previousLine.draw();
//            for (unsigned i = 0; i < previousLine.size(); ++i){
//                ofDrawBitmapStringHighlight(to_string(i), previousLine[i].x, previousLine[i].y, ofColor::black, ofColor::red);
//            }


            ofSetColor(0, 255, 0);
            filtered.draw();
//            for (unsigned i = 0; i < filtered.size(); ++i){
//                ofDrawBitmapStringHighlight(to_string(i), filtered[i].x, filtered[i].y, ofColor::black, ofColor::green);
//            }
            
            ofDrawCircle(filtered[0].x, filtered[0].y, 3);

            ofPopMatrix();
        }
    }

};

#endif /* Ordered_LineProc_hpp */
