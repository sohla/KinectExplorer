//
//  InputManager.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 30/7/19.
//

#ifndef InputManager_hpp
#define InputManager_hpp

#include <stdio.h>
#include "InputModel.h"

#include "ofxGui.h"
#include "ofxOscParameterSync.h"

class InputManager {
    
public:


    void setup(InputModel &m);
    void update();
    void draw();

    ofxPanel                gui;
    ofxOscParameterSync     sync;

};

#endif /* InputManager_hpp */
