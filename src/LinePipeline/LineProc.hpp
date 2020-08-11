//
//  LineProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#ifndef LineProc_hpp
#define LineProc_hpp

#include <stdio.h>
#include "ofxGui.h"

#include "ofxOpenCv.h"
#include "ofxCv.h"

#include "PixelProc.hpp"

#define MAX_BLOBS 4

class LineProc {
    
public:
    
    virtual void setup(ofxPanel &gui) = 0;
    virtual void draw(const DepthModel &model) = 0;
    virtual ofPolyline process(const int &index, const ofPolyline &line) = 0;

};

#endif /* LineProc_hpp */
