#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    ofSetFrameRate(30);
    
    ofSetBackgroundColorHex(0x111111);
    
    inputManager.setup(inputModel);
    kinectManager.setup(inputModel);
    analysisManager.setup(inputModel);
    pixelRecorder.setup();
}

//--------------------------------------------------------------
void ofApp::update(){
    
    inputManager.update();

    // update returns next frames pixels
    kinectManager.update([&](const ofPixels &pixels){
        analysisManager.update(inputModel, pixels);
        pixelRecorder.update(pixels);
    });
}

//--------------------------------------------------------------
void ofApp::draw(){

    kinectManager.draw(inputModel);
    
    analysisManager.draw(inputModel);
    // draw input gui on top of everything
    inputManager.draw();
    
    pixelRecorder.draw();
}

//--------------------------------------------------------------
void ofApp::exit(){
    
    pixelRecorder.exit();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    if(key=='r'){
        if(!pixelRecorder.isRecording()){
            pixelRecorder.start("test", kinectManager.kinect.width , kinectManager.kinect.height);
        }else{
            pixelRecorder.stop();
        }
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
