//
//  PointPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#include "LinePipeline.hpp"

#include "Smooth_LineProc.hpp"
#include "Resample_LineProc.hpp"
#include "Reorder_LineProc.hpp"
#include "Ordered_LineProc.hpp"
#include "OSCOut_LineProc.hpp"


//------------------------------------------------------------------------
//
//------------------------------------------------------------------------


void LinePipeline::setup(const DepthModel &model, ofxPanel &gui){

    ofParameterGroup group;

    
    group.setName(title());
    group.add(onParam);
    group.add(drawParam);
    group.add(blobsParam);
    group.add(thresholdParam);
    group.add(minRadiusParam);
    group.add(maxRadiusParam);
    group.add(persistanceParam);
    group.add(distanceParam);
    

    gui.add(group);

    procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);

    // setup up countour finding and tracking
    contourFinder.setMinAreaRadius(minRadiusParam.get());
    contourFinder.setMaxAreaRadius(maxRadiusParam.get());
    contourFinder.setThreshold(thresholdParam.get());
    

    //
    // build line pipeline
    //
    
//    processors.push_back(new Resample_LineProc());
    processors.push_back(new Smooth_LineProc());

//
//    processors.push_back(new Reorder_LineProc());
//    processors.push_back(new Ordered_LineProc());

//    processors.push_back(new OSCOut_LineProc("127.0.0.1","57120"));
//    processors.push_back(new OSCOut_LineProc("127.0.0.1","57130"));

    // TODO LineRecorderProc : render line into pixels for saving
    //
    //
    //
    
    
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->setup(gui);
    });

    
}

void LinePipeline::draw(const DepthModel &model){

    //•• not drawing line into procImage....
    //••        procImage.draw(0, 0, model.depthCameraWidth * model.depthCameraScale, model.depthCameraHeight * model.depthCameraScale);
    //•• drawing to screen
    
    if(drawParam.get()){

        ofPushMatrix();

        ofNoFill();
        ofScale(model.depthCameraScale, model.depthCameraScale);

        // custom drawing below for debug colors
        //contourFinder.draw();
        
        vector<BlobModel>& followers = trackerFollower.getFollowers();

        for(int i = 0; i < followers.size(); i++) {

            if(followers[i].state == updateState){
                ofSetColor(ofColor::fromHsb(followers[i].randomHue, 255 ,255));
                ofDrawRectangle(followers[i].currentRect.x, followers[i].currentRect.y, followers[i].currentRect.width, followers[i].currentRect.height);
                
                ofDrawLine(followers[i].previousPosition, followers[i].currentPosition);
                ofDrawLine(followers[i].currentPosition, followers[i].currentPosition + (followers[i].currentVelocity * 2.0));
                ofDrawBitmapString(ofToString(followers[i].getLabel()), followers[i].currentPosition);
            }
        }

        ofFill();
        ofPopMatrix();

    }

    // draw pipeline
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        
        vector<BlobModel>& followers = trackerFollower.getFollowers();

        for(int i = 0; i < followers.size(); i++) {
            pp->draw(model,followers[i]);
        }
    });
}


ofPixels LinePipeline::process(const DepthModel &model, const ofPixels &pixel){
    
    procImage.setFromPixels(pixel);

    if(onParam.get()){

        contourFinder.setThreshold(thresholdParam.get());
        contourFinder.setMinAreaRadius(minRadiusParam.get());
        contourFinder.setMaxAreaRadius(maxRadiusParam.get());
        
        contourFinder.findContours(procImage);
        
        trackerFollower.setPersistence(persistanceParam.get());//15
        trackerFollower.setMaximumDistance(distanceParam.get());

        ofxCv::RectTracker& contourTracker = contourFinder.getTracker();
        trackerFollower.track(contourFinder.getBoundingRects());
        
        // get our lovely custom follower
        vector<BlobModel>& followers = trackerFollower.getFollowers();
        
        for(int i = 0; i < followers.size(); i++) {
            
            unsigned int label = followers[i].getLabel();
            
            // ok so contourTracker and trackerFollower persist different 'blobs'
            // BUT they may contain the same RECTS, so look for them....
            
            const cv::Rect& current = trackerFollower.getCurrent(label);

            for(int j=0; j < contourFinder.getBoundingRects().size(); j++){
                const cv::Rect& c = contourFinder.getBoundingRects()[j];
                if(current == c){
                    // so we found a rect that is in the list
                    // assuming index also points to the corresponding polyline
                    followers[i].line = contourFinder.getPolyline(j);
                }
            }

            // let's populate the blobModel (followers) with some extra data (velocity, curr/prev position etc.)
            followers[i].index = i;
            followers[i].currentRect = current;
            followers[i].currentPosition = ofVec2f(current.x + (current.width / 2.0), current.y + (current.height / 2.0));
            followers[i].depthCameraWidth = model.depthCameraWidth;
            followers[i].depthCameraHeight = model.depthCameraHeight;
        
            // only calculating x
            followers[i].velocityRate = (followers[i].currentPosition.x - followers[i].previousPosition.x);
            // / (followers[i].currentPosition.y - followers[i].previousPosition.y);
        
            if(trackerFollower.existsPrevious(label)){
            
                const cv::Rect& previous = trackerFollower.getPrevious(label);
                followers[i].previousPosition = ofVec2f(previous.x + (previous.width / 2.0), previous.y + (previous.height / 2.0));

                followers[i].currentVelocity = followers[i].currentPosition - followers[i].previousPosition;

                followers[i].acceleration = followers[i].currentVelocity - followers[i].previousVelocity;
                // only calculating x
                followers[i].accelerationRate = (followers[i].currentVelocity.x - followers[i].previousVelocity.x);
                // / (followers[i].currentVelocity.y - followers[i].previousVelocity.y);

            }else{
                followers[i].currentVelocity = ofVec2f(0,0);
            }
        
            followers[i].previousVelocity = followers[i].currentVelocity;
            
            //•• for each follower[i] pass DepthModel?
            
            for( auto &proc : processors ){
                proc->process(followers[i]);
            };
        };
    };
    
    return procImage.getPixels();
}
