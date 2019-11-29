#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    ofSetFrameRate(30);
    ofSetVerticalSync(true);
    
    ofSetBackgroundColorHex(0x111111);
    
    analysisManager.setup(inputModel);
    inputManager.setup(inputModel);
    kinectManager.setup(inputModel);
    pixelRecorder.setup();
    
    pixelPlayer.setup("test2019-08-13-11-27-24-354.mov");

//    graph.setup(0, inputModel.kHeight, inputModel.kWidth, 50);
//    graph.setDx(1.0); // which means delta of time
//    graph.setColor(ofColor::white);  // ofColor(255,255,255)

}

//--------------------------------------------------------------
void ofApp::update(){
    
    kinectManager.update(inputModel);
    
    inputManager.update();

    if(inputModel.switches.get("Realtime").cast<bool>() == true){

        // update returns next frames pixels
        kinectManager.update([&](const ofPixels &pixels, const ofMesh &mesh){
            
            analysisManager.update(inputModel, pixels, mesh);
            pixelRecorder.update(pixels);
        });
    }else{

        // play loaded video
//        pixelPlayer.update([&](const ofPixels &pixels){
//            analysisManager.update(inputModel, pixels);
//        });
    }
//    graph.add(ofRandom(-1,1));

}

//--------------------------------------------------------------
void ofApp::draw(){

    kinectManager.draw(inputModel);
    
    analysisManager.draw(inputModel);
    
    // draw input gui on top of everything
    inputManager.draw();
    
    pixelRecorder.draw();

//    pixelPlayer.draw();
//    graph.draw();

}

//--------------------------------------------------------------
void ofApp::exit(){
    
    pixelRecorder.exit();
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
    if(key == 'r'){
        if(!pixelRecorder.isRecording()){
            pixelRecorder.start("test", kinectManager.kinect.width , kinectManager.kinect.height);
        }else{
            pixelRecorder.stop();
        }
    }
    
    if(key == OF_KEY_UP){
        
        inputModel.kinectAngle++;
        if(inputModel.kinectAngle > 30) inputModel.kinectAngle = 30;
        kinectManager.kinect.setCameraTiltAngle(inputModel.kinectAngle);
    }

    if(key == OF_KEY_DOWN){

        inputModel.kinectAngle--;
        if(inputModel.kinectAngle < -30) inputModel.kinectAngle = -30;
        kinectManager.kinect.setCameraTiltAngle(inputModel.kinectAngle);
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
