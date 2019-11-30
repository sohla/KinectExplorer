//
//  PixelRecorder.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#include "PixelRecorder.h"


void PixelRecorder::setup(){
    
    string ffmpegPath = ofFilePath::getUserHomeDir();
    ffmpegPath = ffmpegPath + "/../../usr/local/bin/ffmpeg";
    vidRecorder.setFfmpegLocation(ffmpegPath); // use this is you have ffmpeg installed in your data folder
    ofAddListener(vidRecorder.outputFileCompleteEvent, this, &PixelRecorder::recordingComplete);
}

void PixelRecorder::exit(){
    
    ofRemoveListener(vidRecorder.outputFileCompleteEvent, this, &PixelRecorder::recordingComplete);
    vidRecorder.close();
}

//--------------------------------------------------------------
void PixelRecorder::update(const ofPixels &pixels){
    
    if(vidRecorder.isRecording()){
        bool success = vidRecorder.addFrame(pixels);
        if (!success) {
            ofLogWarning("This frame was not added!");
        }

        // Check if the video recorder encountered any error while writing video frame or audio smaples.
        if (vidRecorder.hasVideoError()) {
            ofLogWarning("The video recorder failed to write some frames!");
        }
        
        if (vidRecorder.hasAudioError()) {
            ofLogWarning("The video recorder failed to write some audio samples!");
        }
    }
}

void PixelRecorder::draw(){
    
    if(vidRecorder.isRecording()){
        ofSetColor(255, 0, 0);
        ofDrawCircle(ofGetWidth() - 20, 20, 10);
    }
}
//--------------------------------------------------------------
void PixelRecorder::start(string fileName, int w, int h){
    
    string fileExt = ".mov"; // ffmpeg uses the extension to determine the container type. run 'ffmpeg -formats' to see supported formats

    if(!vidRecorder.isInitialized()) {
        //    vidRecorder.setVideoCodec("h263p");
        //
        //    vidRecorder.setOutputPixelFormat("gray");
        //     bool setup(string fname, int w, int h, float fps, int sampleRate=0, int channels=0, bool sysClockSync=false, bool silent=false);
        //          vidRecorder.setup(fileName+ofGetTimestampString()+fileExt, vidGrabber.getWidth(), vidGrabber.getHeight(), 30); // no audio
        //            vidRecorder.setup(fileName+ofGetTimestampString()+fileExt, 0,0,0, sampleRate, channels); // no video
        //          vidRecorder.setupCustomOutput(vidGrabber.getWidth(), vidGrabber.getHeight(), 30, sampleRate, channels, "-vcodec mpeg4 -b 1600k -acodec mp2 -ab 128k -f mpegts udp://localhost:1234"); // for custom ffmpeg output string (streaming, etc)

    /* https://openkinect.org/wiki/FAQ#What_is_the_frame_size.2Fbitrate_of_the_rgb.2Fdepth.2FIR_stream_contained_in_the_isochronous_usb_tranfers_etc..3F
     */
        //12672000 bytes/sec =
        vidRecorder.setVideoBitrate("1.2M");
        vidRecorder.setPixelFormat("gray");

        if(vidRecorder.setup(fileName + ofGetTimestampString() + fileExt, w, h, ofGetFrameRate())){
            vidRecorder.start();
        }
        
    }
}

void PixelRecorder::stop(){
    
    vidRecorder.close();
}


//--------------------------------------------------------------
void PixelRecorder::recordingComplete(ofxVideoRecorderOutputFileCompleteEventArgs& args){
    
    cout << "The recoded video file is now complete." << endl;
}
