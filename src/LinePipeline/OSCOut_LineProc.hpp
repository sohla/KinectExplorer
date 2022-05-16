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

    ofParameter<int> resampleParam = ofParameter<int>("resample",32,4,255);
    ofParameter<string> ipParam = ofParameter<string>("ip","127.0.0.1");
    ofParameter<string> portParam = ofParameter<string>("port","57120");

    int numBlobs = 0;
    
//    vector<ofxOscSender*>    senders;
    ofxOscSender sender;
    
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
        
//        //•• fix for new blob model sending data
//        string::size_type sz;
//        int portInt = stoi( portParam.get(),&sz);
//
//        if(val){
//            for(int i = 0; i < MAX_BLOBS; i++){
//                ofxOscSender *sender = new ofxOscSender();
//                sender->setup(ipParam.get(), portInt + i);
//                ofxOscMessage m;
//                m.setAddress("/gyrosc/button");
//                m.addFloatArg(1.0);
//                sender->sendMessage(m, false);
//                senders.push_back(sender);
//            }
//        }else{
//
//            for(int i = 0; i < MAX_BLOBS; i++){
//                ofxOscSender *sender = new ofxOscSender();
//                sender->setup(ipParam.get(), portInt + i);
//                ofxOscMessage m;
//                m.setAddress("/gyrosc/button");
//                m.addFloatArg(0.0);
//                sender->sendMessage(m, false);
//                senders.push_back(sender);
//            }
//
//            // now remove it all
//            for(auto &s : senders){
//                free(s);
//            }
//            senders.clear();
//        }
    };

    void process(BlobModel &blob){
        
        
        // blob model is now sending osc data!
 
//        if(onParam.get()){
//
//            string::size_type sz;
//            int portInt = stoi( portParam.get(),&sz);
//            sender.setup(ipParam.get(), portInt);
//            sender.sendMessage(blob.getOSCMessage(), false);
//        };
//        
        /*
        if(onParam.get()){
            
            string::size_type sz;
            int portInt = stoi( portParam.get(),&sz);

            // fast reduction : using percentage was to expensive
            ofPolyline currLine = blob.line.getResampledByCount(resampleParam.get());
            
            // USE currLine from now on. we are NOT changing blob.line
                        
            
//            if( currLine.size() > 0){

                // all values have been adjusted to give normals for each
                // this does not mean values are mapped from 0..1, but within 0..1
                
                float area = ofMap(blob.line.getArea(), 0, -100000, 0.0, 1.0); // range is approx
                float perimeter = ofMap(blob.line.getPerimeter(), 0, 5000, 0.0, 1.0); // range is approx

                glm::vec2 center = blob.line.getCentroid2D(); // range 0..640:0..480 (pixels of cam)
                ofRectangle bounds = blob.line.getBoundingBox();  // range 0..640:0..480 (pixels of cam)

                 std::cout << " : " << blob.line.size() << " : " << area << " : " << perimeter << center << " : " ;
                
                
                ofxOscMessage m;
                m.setAddress("/gyrosc/line");
                
                m.addIntArg(blob.index);//0
                m.addIntArg(blob.state);//1
                std::cout << blob.state << std::endl;
                m.addFloatArg(area);//2
                m.addFloatArg(perimeter);//3

                m.addFloatArg(ofMap(center.x, 0, 640, 0.0, 1.0));//4
                m.addFloatArg(ofMap(center.y, 0, 480, 0.0, 1.0));//5

                m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));//6
                m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));//7

                m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));//8
                m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));//9

                m.addInt32Arg(blob.getLabel());//10
                
                m.addInt32Arg(blob.velocity.x);//11
                m.addInt32Arg(blob.velocity.y);//12

                m.addInt32Arg(currLine.size());//13

                for( auto &vert :  currLine.getVertices()){//14..( size = //10)
                    m.addDoubleArg(vert.x);
                    m.addDoubleArg(vert.y);
                    //std::cout << vert.x << " , " << vert.y;
                }
                    
                senders[blob.index]->sendMessage(m, false);
//            }
        }
*/
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
