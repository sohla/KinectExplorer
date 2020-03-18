#pragma once

#include "ofMain.h"
#include "InputModel.h"
#include "InputManager.h"
#include "KinectManager.h"
#include "AnalysisManager.h"
#include "PixelRecorder.h"
#include "PixelPlayer.h"

//#include "ofxGraph.h"

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

        InputModel      inputModel;

        InputManager    inputManager;
        KinectManager   kinectManager;
        AnalysisManager analysisManager;
        PixelRecorder   pixelRecorder;
        PixelRecorder   irRecorder;
        PixelPlayer     pixelPlayer;

        static float scale;

//    ofxGraph graph;
};
