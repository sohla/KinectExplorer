#pragma once

#include "ofMain.h"
#include "InputModel.h"
#include "InputManager.h"
#include "KinectManager.h"
#include "AnalysisManager.h"
#include "PixelRecorder.h"
#include "PixelPlayer.h"
#include "ofxOsc.h"

#define PORT 57000

class ofApp : public ofBaseApp{

    
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
    
    
        InputModel      inputModel;

        InputManager    inputManager;
        KinectManager   kinectManager;
        AnalysisManager analysisManager;
        PixelRecorder   pixelRecorder;
        PixelRecorder   irRecorder;
        PixelPlayer     pixelPlayer;

        ofxOscReceiver  receiver;
    
        static float scale;

};
