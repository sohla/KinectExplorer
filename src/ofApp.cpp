#include "ofApp.h"




//--------------------------------------------------------------
void ofApp::setup(){

    ofSetFrameRate(60); // must be 30 for ffmpeg .mp4
    
    ofSetVerticalSync(true);
    ofSetBackgroundColorHex(0x111111);

//    depthCamera = new KinectDepthCamera();
    depthCamera = new RealSenseDepthCamera();
    depthCamera->setup(model);
    
    // load settings
    gui.setup("inputSettings", "inputSettings.json", 1060, 0);
    
    // setup for remote control via OSC
    oscParamSync.setup((ofParameterGroup&)gui.getParameter(), INPORT, "localhost", SCPORT);
    
    ofParameterGroup group;
    group.setName("realtime");
    group.add(realtimeParam);
    gui.add(group);
    
//    pixelPlayer.setup("ke_depth2022-06-08-22-27-28.mov");
    // pixelPlayer.setup("ke_depth2021-07-31-11-02-03.mov");
    pixelPlayer.setup("upDownLeftRight.mov");
//    pixelPlayer.setup("ke_depth2021-07-31-10-54-18.mov");
    
    pixelPipeline.setup(model, gui);

    gui.loadFromFile("inputSettings.json");
    
    ofxOscMessage oscMessage;
    oscMessage.setAddress("/ke/reset");
    oscSender.sendOSCMessage(oscMessage);

}

//--------------------------------------------------------------
void ofApp::update(){

    if(realtimeParam.get() == true){

        //• split up pipelines : videoPixel and depthPixel : procs can be used on either
        //• or is placed at the head of the pipeline
        //• or there is a source : depth, video or player!!!

        // update returns next frames pixels
        depthCamera->update([&](const ofPixels &pixels){
            pixelPipeline.update(model, pixels);
        });
    }else{

        // play loaded video
        pixelPlayer.update([&](const ofPixels &pixels){
            pixelPipeline.update(model, pixels);
        });
    }

    // OSC receiver
    oscParamSync.update();
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofColor c = ofColor::grey;
    c.setBrightness(25);
    ofBackground(c);
    
    gui.draw();

//    pixelPlayer.draw(model);
//    depthCamera->draw(model);
    
    pixelPipeline.draw(model);

}

//--------------------------------------------------------------
void ofApp::exit(){
    
    pixelPipeline.exit();
    depthCamera->exit();

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    
    if(key == 'o'){
        ofFileDialogResult result = ofSystemLoadDialog();
        
        if(result.bSuccess){
            std::cout << result.fileName << " : " << result.filePath << std::endl;
            pixelPlayer.setup(result.fileName);
        }
        
    }

    if(key == 'p'){
        pixelPlayer.switchPlayerState();
    }

    if(key == OF_KEY_LEFT){
        pixelPlayer.previousFrame();
    }
    
    if(key == OF_KEY_RIGHT){
        pixelPlayer.nextFrame();
    }
    
    
    
    
    //•• FIX
    // TODO move to kinect camera
    /*
    if(key == OF_KEY_UP){
        
        inputModel.kinectAngle++;
        if(inputModel.kinectAngle > 30) inputModel.kinectAngle = 30;
        depthCamera.kinect.setCameraTiltAngle(inputModel.kinectAngle);
        std::cout << "tilt angle" << " : " << inputModel.kinectAngle << std::endl;
    }

    if(key == OF_KEY_DOWN){

        inputModel.kinectAngle--;
        if(inputModel.kinectAngle < -30) inputModel.kinectAngle = -30;
        depthCamera.kinect.setCameraTiltAngle(inputModel.kinectAngle);
        std::cout << "tilt angle" << " : " << inputModel.kinectAngle << std::endl;
    }
     */
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
