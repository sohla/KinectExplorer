#include "ofApp.h"


float ofApp::scale{1.65};


//--------------------------------------------------------------
void ofApp::setup(){

    ofSetFrameRate(30);
    ofSetVerticalSync(true);
    
    ofSetBackgroundColorHex(0x111111);
    
    analysisManager.setup(inputModel);
    inputManager.setup(inputModel);
    kinectCamera.setup(inputModel);
    
    pixelRecorder.setup();
    irRecorder.setup();
    
    pixelPlayer.setup("test2019-12-01-18-47-56-139.mov");

    receiver.setup(INPORT);

}

//--------------------------------------------------------------
void ofApp::update(){
    
//    kinectManager.update(inputModel);
    
    inputManager.update();

    if(inputModel.switches.get("Realtime").cast<bool>() == true){

        // update returns next frames pixels
        kinectCamera.update([&](const ofPixels &videoPixels, const ofPixels &depthPixels){
            
            analysisManager.update(inputModel, depthPixels);
            
            // can grab images from kinect to record
           // ofPixels q = kinectCamera.kinect.getPixels();
            irRecorder.update(videoPixels);

            pixelRecorder.update(depthPixels);

        });
    }else{

        // play loaded video
        pixelPlayer.update([&](const ofPixels &pixels){
            analysisManager.update(inputModel, pixels);
        });
    }

    // OSC receiver
    updateOSC();
    
    
}

//--------------------------------------------------------------
void ofApp::draw(){

    kinectCamera.draw(inputModel);
    
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
    irRecorder.exit();
}

//--------------------------------------------------------------
void ofApp::startRecording(){

    pixelRecorder.start("ke_depth", kinectCamera.kinect.width , kinectCamera.kinect.height);
    irRecorder.start("ke_ir", kinectCamera.kinect.width , kinectCamera.kinect.height);
}
//--------------------------------------------------------------
void ofApp::stopRecording(){
    
    pixelRecorder.stop();
    irRecorder.stop();
}

//--------------------------------------------------------------
void ofApp::updateOSC(){

    // check for waiting messages
    while(receiver.hasWaitingMessages()){

        // get the next message
        ofxOscMessage m;
        receiver.getNextMessage(m);

        // check for mouse moved message
        if(m.getAddress() == "/ke/record"){

            int isOn = m.getArgAsInt32(0);
            
            if(isOn == 1){
                startRecording();
            }else{
                stopRecording();
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
    if(key == 'r'){
        if(!pixelRecorder.isRecording()){
            startRecording();
        }else{
            stopRecording();
        }
    }
    
    if(key == 'o'){
        ofFileDialogResult result = ofSystemLoadDialog();
        
        if(result.bSuccess){
            std::cout << result.fileName << " : " << result.filePath << std::endl;
            pixelPlayer.setup(result.fileName);
        }
        
    }
    if(key == OF_KEY_UP){
        
        inputModel.kinectAngle++;
        if(inputModel.kinectAngle > 30) inputModel.kinectAngle = 30;
        kinectCamera.kinect.setCameraTiltAngle(inputModel.kinectAngle);
        std::cout << "tilt angle" << " : " << inputModel.kinectAngle << std::endl;
    }

    if(key == OF_KEY_DOWN){

        inputModel.kinectAngle--;
        if(inputModel.kinectAngle < -30) inputModel.kinectAngle = -30;
        kinectCamera.kinect.setCameraTiltAngle(inputModel.kinectAngle);
        std::cout << "tilt angle" << " : " << inputModel.kinectAngle << std::endl;
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
