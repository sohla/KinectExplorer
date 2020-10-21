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


class Base_LineProc : public LineProc {
    
    virtual string title();

public:
    
    void setup(ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPolyline process(const BlobModel &blob);

protected:

    ofParameter<bool> drawParam = ofParameter<bool>("draw",false);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);

    vector<ofPolyline> procLines;
    
};









//• ICP ordered line to previous line
//• filter time - basic, dynamic (per point) 

#endif /* Base_LineProc_hpp */
