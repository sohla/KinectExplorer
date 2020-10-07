//
//  PixelRecorder.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#ifndef PixelRecorder_hpp
#define PixelRecorder_hpp

#include <stdio.h>

#include "ofMain.h"
#include "ofxVideoRecorder.h"

#include "opencv2/opencv.hpp"


class PixelRecorder {
    
public:

    void setup();
    void draw();

    void update(const ofPixels &pixels);
    void exit();
    
    void start(string fileName, int width, int height);
    void stop();
    
    bool isRecording() { return vidRecorder.isRecording(); };
    
private:
    
    void recordingComplete(ofxVideoRecorderOutputFileCompleteEventArgs& args);

    ofxVideoRecorder    vidRecorder;

    cv::VideoCapture vc;
    
};

#endif /* PixelRecorder_hpp */
