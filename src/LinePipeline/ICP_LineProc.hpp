//
//  ICP_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef ICP_LineProc_hpp
#define ICP_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class ICP_LineProc : public Base_LineProc {
    
    //••• ONLY FOR 1 BLOB!!!!
    

    const int ppSize = 8;
    
    vector<ofPoint> initial;
    vector<ofPoint> target;
    vector<ofPoint> output;
    
    double error;
    int iterations;
    
    ofxIcp icp;

    string title(){
        return "icp";
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

        icp.setClosestPointPairs(ppSize);
        icp.setErrorThreshold(0.9);
        icp.setMaxIterations(3);

    }
    
    ofPolyline process(const int &index, const ofPolyline &line){
        
        if(onParam.get()){
            
            //•• change to percent!!!!
            
            procLines[index] = line.getResampledByCount(ppSize);
            
            // urgh! hand convert glm::vec3 to ofPoint!
            vector<ofDefaultVec3> proLineVert = procLines[index].getVertices();
            target.clear();
            
            for(auto vert : proLineVert){
                ofPoint lp = ofPoint(vert.x, vert.y, vert.z);
                target.push_back(lp);
            }

            if(initial.size() == 0 ){
                initial = target;
                cout << "1st time" << endl;
            }else{
                initial = output;
            }
            
            output.clear();

            ofMatrix4x4 transformation;
            
            //•• somethign happening with memory!!!! ca
            //•• should be able to feed in target as inital
            icp.compute(initial, target, output, transformation, error, iterations);

            procLines[index].clear();
            for(auto lp : output){
                procLines[index].addVertex(lp);
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

#endif /* ICP_LineProc_hpp */
