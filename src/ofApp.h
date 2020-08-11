#pragma once

#include "ofMain.h"
#include "KinectDepthCamera.h"
#include "PixelRecorder.h"
#include "PixelPlayer.h"
#include "ofxOsc.h"

#include "PixelPipeline.hpp"
#include "ofxGui.h"
#include "ofxOscParameterSync.h"

#define INPORT 57000

class ofApp : public ofBaseApp{

        PixelSourceBase*   depthCamera;
        PixelRecorder   pixelRecorder;
//        PixelRecorder   irRecorder;
        PixelPlayer     pixelPlayer;

        ofxOscReceiver  receiver;
    
        PixelPipeline pipeline;
        ofxPanel                gui;
        ofxOscParameterSync     sync;

        ofParameter<bool> realtimeParam = ofParameter<bool>("realtime",true);
        DepthModel   model;
    
	public:
		void setup();
		void update();
		void draw();
        void exit();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

        void startRecording();
        void stopRecording();
        
        void updateOSC();
    
        static float scale;


};
