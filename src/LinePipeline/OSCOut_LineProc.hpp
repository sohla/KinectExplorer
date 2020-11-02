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

    ofParameter<int> resampleParam = ofParameter<int>("resample",32,4,127);
    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57120");

    
    
    vector<ofxOscSender*>    senders;
    
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

        onParam.addListener(this, &OSCOut_LineProc::onOnParam);
    }
    
    
    void onOnParam(bool& val){

        string::size_type sz;
        int portInt = stoi( portParam.get(),&sz);

        if(val){
            for(int i = 0; i < MAX_BLOBS; i++){
                ofxOscSender *sender = new ofxOscSender();
                sender->setup(ipParam.get(), portInt + i);
                ofxOscMessage m;
                m.setAddress("/gyrosc/button");
                m.addFloatArg(1.0);
                sender->sendMessage(m, false);
                senders.push_back(sender);
            }
        }else{

            for(int i = 0; i < MAX_BLOBS; i++){
                ofxOscSender *sender = new ofxOscSender();
                sender->setup(ipParam.get(), portInt + i);
                ofxOscMessage m;
                m.setAddress("/gyrosc/button");
                m.addFloatArg(0.0);
                sender->sendMessage(m, false);
                senders.push_back(sender);
            }
            
            // now remove it all
            for(auto &s : senders){
                free(s);
            }
            senders.clear();
        }
    };

    void process(BlobModel &blob){

        
        if(onParam.get() && blob.line.size() > 0 ){

            string::size_type sz;
            int portInt = stoi( portParam.get(),&sz);

            // fast reduction
            ofPolyline currLine = blob.line.getResampledByCount(resampleParam.get());
            
            // USE currLine from now on. we are NOT changing blob.line
                        
            if( currLine.size() > 0){
//                float area = blob.line.getArea();
//                float perimeter = blob.line.getPerimeter();
                float area = ofMap(blob.line.getArea(), 0, -100000, 0.0, 1.0);
                float perimeter = ofMap(blob.line.getPerimeter(), 0, 5000, 0.0, 1.0);
                glm::vec2 center = blob.line.getCentroid2D();
                ofRectangle bounds = blob.line.getBoundingBox();

                // std::cout << i << " : " << blob.line.size() << " : " << area << " : " << perimeter << center << " : " ;
                
                
                ofxOscMessage m;
                m.setAddress("/gyrosc/line");
                
                m.addIntArg(blob.index);//0

                m.addFloatArg(area);//1
                m.addFloatArg(perimeter);//2

//                m.addFloatArg(center.x);//3
//                m.addFloatArg(center.y);//4
//
//                m.addFloatArg(bounds.x);//5
//                m.addFloatArg(bounds.y);//6
//
//                m.addFloatArg(bounds.width);//7
//                m.addFloatArg(bounds.height);//8

                m.addFloatArg(ofMap(center.x, 0, 1000, 0.0, 1.0));//3
                m.addFloatArg(ofMap(center.y, 0, 1000, 0.0, 1.0));//4

                m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));//5
                m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));//6

                m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));//7
                m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));//8

                m.addInt32Arg(blob.label);//9
                
                m.addInt32Arg(currLine.size());//10

                for( auto &vert :  currLine.getVertices()){//11..(//10)
                    m.addDoubleArg(vert.x);
                    m.addDoubleArg(vert.y);
                    //std::cout << vert.x << " , " << vert.y;
                }
                    
                senders[blob.index]->sendMessage(m, false);
            }
        }
    }

    public:
        OSCOut_LineProc(string ip, string port){
        
            ipParam.set(ip);
            portParam.set(port);
            
        };

    void exit(){
        
        onParam.removeListener(this, &OSCOut_LineProc::onOnParam);
    }

};

#endif /* OSCOut_LineProc_hpp */
