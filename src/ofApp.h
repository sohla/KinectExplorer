#pragma once

#include "ofMain.h"
#include "KinectDepthCamera.h"
#include "RealSenseDepthCamera.h"

#include "PixelPlayer.h"

#include "PixelPipeline.hpp"
#include "ofxGui.h"
#include "ofxOscParameterSync.h"
#include "OSCSender.hpp"

#define INPORT 57000
#define SCPORT 57120



class ofApp : public ofBaseApp{

        PixelSourceBase*   depthCamera;
    
    
        PixelPlayer     pixelPlayer;

        PixelPipeline pixelPipeline;
        ofxPanel                gui;
        ofxOscParameterSync     oscParamSync;

        ofParameter<bool> realtimeParam = ofParameter<bool>("realtime",true);
    
        DepthModel   model;
    
        OSCSender   oscSender;
    
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

        
        void updateOSC();
    
        static float scale;


};
