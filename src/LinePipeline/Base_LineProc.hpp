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
#include "ofxOscSender.h"
#include "ofxICP.h"


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

        // default behaviour keeps group closed
        gui.getGroup(title()).minimize();

        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
    }
    
    ofPolyline process(const int &index, const ofPolyline &line){

        if(onParam.get()){
            procLines[index] = line.getSmoothed(smoothParam.get());
        }else{
            procLines[index] = line;
        }
        return procLines[index];
    }
};
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
//------------------------------------------------------------
//
//------------------------------------------------------------
class Reorder_LineProc : public Base_LineProc {
    
    //••• ONLY FOR 1 BLOB!!!!
    
    ofPolyline previousLine;
    ofDefaultVec3 closestPnt;
    ofPolyline filtered;
    const int ppSize = 32;
    
    
    string title(){
        return "reorder";
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
            ofPolyline pl;
            pl.addVertex(ofDefaultVec3(0,0,0));
            procLines.push_back(pl);
        }
        
        for(int i=0; i< ppSize; i++){
            filtered.addVertex(0,0);
        }
        previousLine.addVertex(ofDefaultVec3(0,0,0));

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
        
        if(onParam.get()){
            
            previousLine = procLines[index];
            
            // find closest point in new line to start of prev line
            ofDefaultVec3 prevPnt = previousLine[0];
            ofPolyline currLine = line.getResampledByCount(ppSize);
            
            closestPnt = currLine.getClosestPoint(prevPnt);
            auto it = find(currLine.begin(), currLine.end(), closestPnt);
            unsigned int ci = std::distance(currLine.begin(), it);
            
            ofPolyline rol;
            // copy from ci to end
            for(auto itr = currLine.begin() + ci; itr < currLine.end(); itr++){
                ofDefaultVec3 p = ofDefaultVec3( itr->x , itr->y, 0);
                rol.addVertex(p);
            }
            // copy from begin to ci
            for(auto itr = currLine.begin(); itr < currLine.begin() + ci; itr++){
                ofDefaultVec3 p = ofDefaultVec3( itr->x , itr->y, 0);
                rol.addVertex(p);
            }

            // rol is now index aligned with previousLine
            float f = 0.1;
            for (unsigned i = 0; i < rol.size(); ++i){
                    filtered[i].x = (f * rol[i].x + ((1.0 - f) * filtered[i].x));
                    filtered[i].y = (f * rol[i].y + ((1.0 - f) * filtered[i].y));
            }


            procLines[index] = rol;
            

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

            
            ofDefaultVec2 prevPnt = previousLine[0];
            ofDefaultVec2 currPnt = procLines[0][0];
            
            
            

            ofSetColor(250, 0, 0);
            ofDrawCircle(currPnt.x, currPnt.y, 3);

            ofSetColor(0, 250, 0);
            ofDrawCircle(closestPnt.x, closestPnt.y, 3);

            ofSetColor(0, 0, 150);
            ofDrawLine(closestPnt.x, closestPnt.y, currPnt.x, currPnt.y);

            ofSetColor(0, 250, 0);
            filtered.draw();
            
            ofPopMatrix();
        }
    }

};

//------------------------------------------------------------
//
//------------------------------------------------------------
class Ordered_LineProc : public Base_LineProc {
    
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
        
        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
        
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
    
    
    ofPolyline process(const int &index, const ofPolyline &line){
        
        if(onParam.get()){
            
            previousLine = procLines[index];
            
            // new line
            procLines[index] = line.getResampledByCount(ppSize);
            
            // order by finding closest of each point point from previos line
            ordered.clear();
            float f = filterParam.get();
            for( auto p : procLines[index]) {
                ofDefaultVec2 op = closestPoint(previousLine, p);
                ordered.addVertex(op.x, op.y);
            }
            
            // filter
            for (unsigned i = 0; i < ordered.size(); ++i){
                    filtered[i].x = (f * ordered[i].x + ((1.0 - f) * filtered[i].x));
                    filtered[i].y = (f * ordered[i].y + ((1.0 - f) * filtered[i].y));
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
//                for (unsigned i = 0; i < line.size(); ++i){
//                    ofDrawBitmapStringHighlight(to_string(i), line[i].x, line[i].y, ofColor::black, ofColor::white);
//                }
            };

            ofDrawCircle(procLines[0][0].x, procLines[0][0].y, 3);

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

//------------------------------------------------------------
//
//------------------------------------------------------------
class OSCOut_LineProc : public Base_LineProc {

    ofParameter<int> resampleParam = ofParameter<int>("resample",32,4,512);
    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57120");

    ofxOscSender            sender;
    
    
    
    string title(){
        return "osc out";
    }

    void setup(ofxPanel &gui){

        ofParameterGroup group;

        group.setName(title());
        group.add(onParam);
        group.add(ipParam);
        group.add(portParam);
        group.add(resampleParam);
        gui.add(group);

        // default behaviour keeps group closed
        gui.getGroup(title()).minimize();

        for(int i=0; i< MAX_BLOBS; i++){
            procLines.push_back(ofPolyline());
        }
        
        string::size_type sz;
        int portInt = stoi( portParam.get(),&sz);
        sender.setup(ipParam.get(), portInt );
    }
    
    ofPolyline process(const int &index, const ofPolyline &line){

        if(onParam.get()){
            procLines[index] = line.getResampledByCount(resampleParam.get());
            
            if( procLines[index].size() > 0){
                float area = ofMap(procLines[index].getArea(), 0, -130000, 0.0, 1.0);
                float perimeter = ofMap(procLines[index].getPerimeter(), 0, 3000, 0.0, 1.0);
                glm::vec2 center = procLines[index].getCentroid2D();
                ofRectangle bounds = procLines[index].getBoundingBox();

                // std::cout << i << " : " << procLines[index].size() << " : " << area << " : " << perimeter << center << " : " ;
                
                /*
                Notes on OSC data
                
                0 /blobi
                1 number of blobs
                2 area
                3 perimeter
                4 center.x
                5 center.y
                6 rect.x
                7 rect.y
                8 rect.h
                9 rect.w
                10 size of line points (max = line 220)
                11...n n=size of line points, data is interleaved (x0,y0,x1,y1...)
                */
                
                ofxOscMessage m;
                m.setAddress("/ke");
                
                m.addIntArg(index);//0

                m.addFloatArg(area);//1
                m.addFloatArg(perimeter);

                m.addFloatArg(ofMap(center.x, 0, 1000, 0.0, 1.0));
                m.addFloatArg(ofMap(center.y, 0, 1000, 0.0, 1.0));

                m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));
                m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));

                m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));
                m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));

                m.addInt32Arg(procLines[index].size());
                
                
                for( auto &vert :  procLines[index].getVertices()){
                    m.addDoubleArg(vert.x);
                    m.addDoubleArg(vert.y);
                    //std::cout << vert.x << " , " << vert.y;
                }
              //  std::cout << m << std::endl;
                
                sender.sendMessage(m, false);
            }else{
                procLines[index] = line;
            }
        }
        return procLines[index];
    }

    public:
        OSCOut_LineProc(string ip, string port){
        
            ipParam.set(ip);
            portParam.set(port);
            
        };

};


//• ICP ordered line to previous line
//• filter time - basic, dynamic (per point) 

#endif /* Base_LineProc_hpp */
