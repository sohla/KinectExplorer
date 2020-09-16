//
//  Reorder_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Reorder_LineProc_hpp
#define Reorder_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Reorder_LineProc : public Base_LineProc {
    
//    const int ppSize = 256;
    
    ofParameter<float> filterParam = ofParameter<float>("lag",0.1,0.01,0.9);
    ofParameter<int> reduceParam = ofParameter<int>("reduce",256,4,512);

    
    string title(){
        return "reorder";
    }
    
    void setup(ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        group.add(filterParam);
        group.add(reduceParam);
        gui.add(group);
        
        // default behaviour keeps group closed
        gui.getGroup(title()).maximize();
        
        for(int i=0; i< MAX_BLOBS; i++){
            ofPolyline pl;
            pl.resize(reduceParam.get()+1);
            procLines.push_back(pl);
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

    ofPolyline process(const int &index, const ofPolyline &line){
        
        // check if we need to resize storage
        if(reduceParam.get() != procLines[index].size()+1){
            procLines[index].resize(reduceParam.get()+1);
        }
        
        if(onParam.get()){
            
            // find closest point in new line to start of prev line
            //ofDefaultVec3 prevPnt(ofGetMouseX(), ofGetMouseY(), 0.0);
            ofDefaultVec3 previousPnt = procLines[index][0];
            
            // getResampledByCount can not gaurentee it will always return a line with ppSize
            // ofPolyline currLine = line.getResampledByCount(ppSize);
            
            // so grab points using percentages
            ofPolyline currLine;
            for(float i = 0.0; i < 100.0; i+= (100.0/ reduceParam.get() )){
                float pi = line.getIndexAtPercent(i/100.0);
                currLine.addVertex(line[floor(pi)]);
            }
            currLine.setClosed(true);
            
            // now get the index of the closest point to the first point (previousPnt) from previousLine
            unsigned int ni = 0;
            currLine.getClosestPoint(previousPnt, &ni);

            ofPolyline rol;
            // copy from ci to end
            for(auto itr = currLine.begin() + ni; itr < currLine.end(); itr++){
                ofDefaultVec3 p = ofDefaultVec3( itr->x , itr->y, 0);
                rol.addVertex(p);
            }
            // copy from begin to ci
            for(auto itr = currLine.begin(); itr < currLine.begin() + ni; itr++){
                ofDefaultVec3 p = ofDefaultVec3( itr->x , itr->y, 0);
                rol.addVertex(p);
            }
            rol.addVertex(*rol.begin());
            rol.setClosed(true);

            // rol is now index aligned with previousLine
            float f = filterParam.get();
            for (unsigned i = 0; i < rol.size(); ++i){
                    procLines[index][i].x = (f * rol[i].x + ((1.0 - f) * procLines[index][i].x));
                    procLines[index][i].y = (f * rol[i].y + ((1.0 - f) * procLines[index][i].y));
            }

        }else{
            procLines[index] = line;
        }
        return procLines[index];
    }
    
    void draw(const DepthModel &model){
        
        if(drawParam.get()){
            ofPushMatrix();
            ofScale( model.kinectScale);
            
            for( auto &line : procLines ){
                line.draw();
            };
            
            ofPopMatrix();
        }
    }

};
#endif /* Reorder_LineProc_hpp */