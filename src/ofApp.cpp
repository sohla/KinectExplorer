#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    ofSetBackgroundColorHex(0x111111);
    
    inputManager.setup(inputModel);
    kinectManager.setup(inputModel);
    pixelRecorder.setup();
}

//--------------------------------------------------------------
void ofApp::update(){
    
    inputManager.update();
    //kinectManager.update(inputModel);

    // record the raw pixels from kinect
//    pixelRecorder.update(kinectManager.kinect.getDepthPixels());
    
    kinectManager.updateTwo([&](const ofPixels &pixels){
        
        pixelRecorder.update(pixels);

    });
}

//--------------------------------------------------------------
void ofApp::draw(){

    kinectManager.draw(inputModel);
    
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
