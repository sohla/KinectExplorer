//
//  PointProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#ifndef PointProc_hpp
#define PointProc_hpp

#include <stdio.h>



//struct BlobModel {
//
//    int index = 0;
//    ofxCvBlob blob;
//
//};

class LineProc {
    
public:
    
    virtual void setup(const int &index, ofxPanel &gui) = 0;
    virtual void draw(const int &index) = 0;
    virtual ofPolyline process(const int &index, const ofPolyline &line) = 0;

};

#endif /* PointProc_hpp */
