//
//  InputManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 30/7/19.
//

#include "InputManager.h"



void InputManager::setup(InputModel &im){
    
//    group.add(needsFlow.set("needsFlow", true));
//    group.add(bDrawBuilding.set("bDrawBuilding", false));
//    group.add(dmxOffValue.set("dmxOffValue", 0, 0, 255));
    
    gui.setup("inputSettings", "inputSettings.json", 1020, 0);
    gui.add(im.switches);
    gui.add(im.sliders);
    gui.loadFromFile("inputSettings.json");

    sync.setup((ofParameterGroup&)gui.getParameter(),6667,"localhost",6666);
    
    /*
     send via SC :
     
         b = NetAddr("127.0.0.1", 6667);
         b.sendMsg("/inputSettings/group/threshold1", 12);
     
     listening with SC :
     
         o = OSCFunc({ arg msg, time, addr, recvPort;
            ([msg, time, addr, recvPort]).postln;
         }, '/inputSettings/group/threshold1', recvPort:6666);
         o.free;

     */

}

void InputManager::update(){
    
    sync.update();

}

void InputManager::draw(){
      gui.draw();
}

