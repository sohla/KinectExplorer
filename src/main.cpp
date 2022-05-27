#include "ofMain.h"
#include "ofApp.h"
#include "ofxArgParser.h"
//========================================================================

int main(int argc, const char** argv){
    
    ofxArgParser::init(argc, argv);
    
    ofSetupOpenGL(1300,1000,OF_WINDOW);

	ofRunApp(new ofApp());

}
    
