#include "ofMain.h"
#include "ofApp.h"
#include "ofxArgParser.h"
//========================================================================

int main(int argc, const char** argv){
    
    ofxArgParser::init(argc, argv);
    
    ofSetupOpenGL(1100,860,OF_WINDOW);

	ofRunApp(new ofApp());

}
    
