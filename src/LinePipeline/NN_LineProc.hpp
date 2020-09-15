//
//  NN_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef NN_LineProc_hpp
#define NN_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class NN_LineProc : public Base_LineProc {
    
    //••• ONLY FOR 1 BLOB!!!!
    
    vector<ofPoint> target;

    const int ppSize = 8;
    
    ofxNearestNeighbour3D nn;
    vector<NNIndex> indices;

    
    string title(){
        return "nn";
    }
    
    void setup(ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(onParam);
        group.add(drawParam);
        gui.add(group);
        
        // default behaviour keeps group closed
        gui.getGroup(title()).maximize();
        
        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }

    }
    
    ofPolyline process(const int &index, const ofPolyline &line){
        
        if(onParam.get()){
            
            
            procLines[index] = line.getResampledByCount(ppSize);
            
            // urgh! hand convert glm::vec3 to ofPoint!
            vector<ofDefaultVec3> proLineVert = procLines[index].getVertices();
            target.clear();
            
            for(auto vert : proLineVert){
                ofPoint lp = ofPoint(vert.x, vert.y, vert.z);
                target.push_back(lp);
            }

            vector<float> distsSq;
            
            nn.buildIndex(target);
            nn.findNClosestPoints(target[0], ppSize, indices, distsSq);

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

            ofSetColor(0, 255, 0);
            
            for (unsigned i = 0; i < indices.size(); ++i)
            {
                ofSetColor(ofColor::fromHsb((255.0 / indices.size()) * i, 255, 255));
                ofDrawCircle(target[indices[i]], 3);
                
                ofDrawBitmapString(to_string(i), target[indices[i]].x, target[indices[i]].y);
            }


            ofPopMatrix();
        }
    }

};
#endif /* NN_LineProc_hpp */
