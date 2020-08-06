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

    ofxPanel                gui;
    ofxOscParameterSync     sync;

public:


    void setup(InputModel &m);
    void update();
    void draw();


};

#endif /* InputManager_hpp */
