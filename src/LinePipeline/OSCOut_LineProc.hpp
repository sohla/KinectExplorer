//
//  OSCOut_LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef OSCOut_LineProc_hpp
#define OSCOut_LineProc_hpp

#include <stdio.h>
#include "Base_LineProc.hpp"
#include "ofxOscSender.h"

//------------------------------------------------------------
//
//------------------------------------------------------------

class OSCOut_LineProc : public Base_LineProc {

    ofParameter<int> resampleParam = ofParameter<int>("resample",32,4,512);
    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57120");

    ofxOscSender            sender;
    
    
    
    string title(){
        return "line osc out " + portParam.get();
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
        
    }
    
    ofPolyline process(const int &index, const ofPolyline &line){

        
        if(onParam.get() && line.size() > 1 ){

            string::size_type sz;
            int portInt = stoi( portParam.get(),&sz);

            sender.setup(ipParam.get(), portInt + index );
//            sender.setup(ipParam.get(), portInt);

            
            //            procLines[index] = line.getResampledByCount(resampleParam.get());
            
            // so grab points using percentages
            ofPolyline currLine;
            for(float i = 0.0; i < 100.0; i+= (100.0/ resampleParam.get() )){
                float pi = line.getIndexAtPercent(i/100.0);
                currLine.addVertex(line[floor(pi)]);
            }
            currLine.setClosed(true);

            procLines[index] = currLine;
            
            if( procLines[index].size() > 0){
                float area = ofMap(procLines[index].getArea(), 0, -130000, 0.0, 1.0);
                float perimeter = ofMap(procLines[index].getPerimeter(), 0, 3000, 0.0, 1.0);
                glm::vec2 center = procLines[index].getCentroid2D();
                ofRectangle bounds = procLines[index].getBoundingBox();

                // std::cout << i << " : " << procLines[index].size() << " : " << area << " : " << perimeter << center << " : " ;
                
                
                ofxOscMessage m;
                m.setAddress("/ke/line");
                
                m.addIntArg(index);//0

                m.addFloatArg(area);//1
                m.addFloatArg(perimeter);//2

                m.addFloatArg(ofMap(center.x, 0, 1000, 0.0, 1.0));//3
                m.addFloatArg(ofMap(center.y, 0, 1000, 0.0, 1.0));//4

                m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));//5
                m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));//6

                m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));//7
                m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));//8

                m.addInt32Arg(procLines[index].size());//9
                
                
                for( auto &vert :  procLines[index].getVertices()){//10..(//9)
                    m.addDoubleArg(vert.x);
                    m.addDoubleArg(vert.y);
                    //std::cout << vert.x << " , " << vert.y;
                }
//                std::cout << m << std::endl;
                
                sender.sendMessage(m, false);
            }else{
                procLines[index] = line;
            }
            
            // pass thru
            procLines[index] = line;
        }
        return procLines[index];
    }

    public:
        OSCOut_LineProc(string ip, string port){
        
            ipParam.set(ip);
            portParam.set(port);
            
        };

};

#endif /* OSCOut_LineProc_hpp */
