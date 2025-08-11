//
//  PixelRecorderProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 9/10/20.
//

#ifndef PixelRecorderProc_hpp
#define PixelRecorderProc_hpp

#include <stdio.h>

#include <stdio.h>
#include "Base_PixelProc.hpp"
#include "ofxVideoRecorder.h"

//------------------------------------------------------------
//
//------------------------------------------------------------

class PixelRecorderProc : public Base_PixelProc {

    ofxVideoRecorder    vidRecorder;
    ofParameter<bool> recordingParam = ofParameter<bool>("recording",false);

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        group.add(recordingParam);
        gui.add(group);
        
        
        recordingParam.addListener(this, &PixelRecorderProc::onRecordingParam);
        ofAddListener(ofEvents().keyPressed, this, &PixelRecorderProc::onKeyPressed);
        
        // ffmpeg
        string ffmpegPath = ofFilePath::getUserHomeDir();
        
        #ifdef TARGET_OSX
        ffmpegPath = ffmpegPath + "/../../usr/local/bin/ffmpeg";
        #elif defined(TARGET_LINUX)
        ffmpegPath = ffmpegPath + "/../../usr/bin/ffmpeg";
        #endif

        vidRecorder.setFfmpegLocation(ffmpegPath); // use this is you have ffmpeg installed in your data folder
    }

    void proc(){
        //procImage has image
        //procImage.getPixels().setImageType(OF_IMAGE_GRAYSCALE);
        if(vidRecorder.isRecording()){
            bool success = vidRecorder.addFrame(procImage.getPixels());
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
        
    };
    
    void draw(const DepthModel &model){
        if(vidRecorder.isRecording()){
            ofSetColor(255, 0, 0);
            ofDrawRectangle(0, 480 * model.depthCameraScale, 640 * model.depthCameraScale, 10);
        }else{
            ofSetColor(0, 0, 0);
            ofDrawRectangle(0, 480 * model.depthCameraScale, 640 * model.depthCameraScale, 10);
        }
        ofSetColor(255, 255, 255);
    }

    string title(){return "pixelrecorder";};
    
    
    void exit(){
        
        recordingParam.removeListener(this, &PixelRecorderProc::onRecordingParam);
        ofRemoveListener(ofEvents().keyPressed, this, &PixelRecorderProc::onKeyPressed);

        std::cout << "recorder exit" << std::endl;
        ofRemoveListener(vidRecorder.outputFileCompleteEvent, this, &PixelRecorderProc::recordingComplete);
        vidRecorder.close();
    }
private:
    
    void start(string fileName, int w, int h){
        
        string fileExt = ".mov"; // ffmpeg uses the extension to determine the container type. run 'ffmpeg -formats' to see supported formats

        // image is 640 x 480
        // format : gray
        
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
//            vidRecorder.setVideoBitrate("1.2M");
           vidRecorder.setPixelFormat("gray");
           vidRecorder.setOutputPixelFormat("gray16le");

            string timeFormat = "%Y-%m-%d-%H-%M-%S";
            string timeString = ofGetTimestampString(timeFormat);
            
            if(vidRecorder.setup(fileName + timeString + fileExt, w, h, ofGetFrameRate())){
                vidRecorder.start();
            }
            
        }
    }
    
    void stop(){
        
        vidRecorder.close();
    }

    void recordingComplete(ofxVideoRecorderOutputFileCompleteEventArgs& args){
        std::cout << "The recoded video file " << args.fileName << " is now complete." << std::endl;
    };

    
    void onRecordingParam(bool& val){
        if(val){
            std::cout << "========= start recording =========" << std::endl;
            start("ke_depth", procImage.width , procImage.height);
        }else{
            std::cout << "========= stop recording =========" << std::endl;
            stop();
        }
    };

    void onKeyPressed(ofKeyEventArgs& eventArgs){
        if(eventArgs.key == 'r'){
            recordingParam.set(!recordingParam.get());
        }
        
    }

};


#endif /* PixelRecorderProc_hpp */
