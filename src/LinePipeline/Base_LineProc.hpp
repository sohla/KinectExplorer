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
        }
        return procLines[index];
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
            }
        }
        return procLines[index];
    }
};


//• ICP ordered line to previous line
//• filter time - basic, dynamic (per point) 

#endif /* Base_LineProc_hpp */
