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
//    virtual void proc();

public:
    
    void setup(ofxPanel &gui);
    void draw(const DepthModel &model);
    ofPolyline process(const int &index, const ofPolyline &line);

protected:

    ofParameter<bool> drawParam = ofParameter<bool>("draw",false);
    ofParameter<bool> onParam = ofParameter<bool>("on",true);

    ofPolyline procLine;

    vector<ofPolyline> procLines;
    
};
#endif /* Base_LineProc_hpp */
