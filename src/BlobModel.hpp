//
//  BlobModel.h
//  KinectExplorer
//
//  Created by Stephen OHara on 22/4/21.
//

#ifndef BlobModel_h
#define BlobModel_h

// handy model for collecting data from tracker and procs
// gets passed to everything for each frame

struct BlobModel {

    ofPolyline line;
    
    unsigned int label;
    unsigned int index;

    ofVec2f previousPosition;
    ofVec2f currentPosition;
    ofVec2f velocity;
    int age;
    
    
    void debug(){
        std::cout << "label:" << ofToString(label) << " index:" << ofToString(index) << std::endl;
    }
    
};

#endif /* BlobModel_h */
