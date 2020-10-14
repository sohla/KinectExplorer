#include "ofApp.h"


float ofApp::scale{1.65};


//--------------------------------------------------------------
void ofApp::setup(){

    ofSetFrameRate(30); // must be 30 for ffmpeg .mp4
    
    ofSetVerticalSync(true);
    ofSetBackgroundColorHex(0x111111);

    depthCamera = new KinectDepthCamera();
    depthCamera->setup(model);
    
    gui.setup("inputSettings", "inputSettings.json", 1070, 0);
    
    // gui with OSC
    // can send msgs remotely (eg. from sc)
    // b = NetAddr("127.0.0.1",57000);
    // b.sendMsg("/inputSettings/blur/blur", 5);
    // msg path: /inputSettings/xxGROUPxx/xxPARAMNAMExx
    oscParamSync.setup((ofParameterGroup&)gui.getParameter(), INPORT, "localhost", SCPORT);

    
    ofParameterGroup group;
    group.setName("realtime");
    group.add(realtimeParam);
    gui.add(group);
    
    pixelPlayer.setup("test2019-12-01-18-47-56-139.mov");
    
    pixelPipeline.setup(model, gui);

    gui.loadFromFile("inputSettings.json");

}

//--------------------------------------------------------------
void ofApp::update(){
    
//    pixelPlayer.update([&](const ofPixels &pixels){
//        pixelPipeline.update(model, pixels);
//    });

//    depthCamera->update([&](const ofPixels &pixels){
//        pixelPipeline.update(model, pixels);
//    });

    

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
//    updateOSC();
    
    oscParamSync.update();
    
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofColor c = ofColor::fromHsb( ofGetFrameNum() % 255 , 55, 55);
    ofBackground(c);
    
    gui.draw();

//    pixelPlayer.draw(model);
    
    pixelPipeline.draw(model);

}

//--------------------------------------------------------------
void ofApp::exit(){
    pixelPipeline.exit();
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
