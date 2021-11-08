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
//    group.add(persistanceParam);
    group.add(distanceParam);
    gui.add(group);

    procImage.allocate(model.depthCameraWidth, model.depthCameraHeight);

    // setup up countour finding and tracking
    contourFinder.setMinAreaRadius(minRadiusParam.get());
    contourFinder.setMaxAreaRadius(maxRadiusParam.get());
    contourFinder.setThreshold(thresholdParam.get());
//    contourFinder.setSortBySize(true);
    
//    contourFinder.getTracker().setPersistence(0); //in frames. 0 = deadFrames used as a trigger
//    contourFinder.getTracker().setMaximumDistance(distanceParam.get());

    


    //
    // build line pipeline
    //
    
//    processors.push_back(new Resample_LineProc());
    processors.push_back(new Smooth_LineProc());

//
//    processors.push_back(new Reorder_LineProc());
//    processors.push_back(new Ordered_LineProc());

    processors.push_back(new OSCOut_LineProc("127.0.0.1","57120"));
    processors.push_back(new OSCOut_LineProc("127.0.0.1","57130"));

    // TODO LineRecorderProc : render line into pixels for saving
    //
    //
    //
    
    
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->setup(gui);
    });

    
}

void LinePipeline::draw(const DepthModel &model){

    if(drawParam.get()){

        ofPushMatrix();

        ofNoFill();
        ofScale(model.depthCameraScale, model.depthCameraScale);

        // custom draeing below for debug colors
        //contourFinder.draw();
        
        vector<BlobModel>& followers = trackerFollower.getFollowers();

        for(int i = 0; i < followers.size(); i++) {

            if(followers[i].state == updateState){
                ofSetColor(ofColor::fromHsb(followers[i].randomHue, 255 ,255));
                ofDrawRectangle(followers[i].line.getBoundingBox());
                
                ofDrawLine(followers[i].previousPosition, followers[i].currentPosition);
                ofDrawLine(followers[i].currentPosition, followers[i].currentPosition + (followers[i].velocity * 2.0));
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
        
        trackerFollower.setPersistence(15);
        trackerFollower.setMaximumDistance(distanceParam.get());

        ofxCv::RectTracker& contourTracker = contourFinder.getTracker();
        trackerFollower.track(contourFinder.getBoundingRects());
        
            
        vector<BlobModel>& followers = trackerFollower.getFollowers();
        
        for(int i = 0; i < followers.size(); i++) {
            
            unsigned int label = followers[i].getLabel();
            
            // contourTracker has the polyline : so need to get it via this tracker
            int index = contourTracker.getIndexFromLabel(label);

            if(index >= 0){

                followers[i].line = contourFinder.getPolyline(index);
                followers[i].index = index;
                
                // but all the other details are in extended tracker with out Blob Model
                if(trackerFollower.existsPrevious(label)){
                    const cv::Rect& previous = trackerFollower.getPrevious(label);
                    const cv::Rect& current = trackerFollower.getCurrent(label);
                    followers[i].previousPosition = ofVec2f(previous.x + previous.width / 2, previous.y + previous.height / 2);
                    followers[i].currentPosition = ofVec2f(current.x + current.width / 2, current.y + current.height / 2);
                    followers[i].velocity = followers[i].currentPosition - followers[i].previousPosition;
                }

                for( auto &proc : processors ){
                    proc->process(followers[i]);
                };

            }

        }

        
        
        
        /*

        blobs.clear();
        
        //• feels like a HACK!
        //• use TrackerFollower to manage Blob model.....
        //• YEP this is all wrong
        //• what we need
        //• track each blob, and its state, born, living, died
        //• how do we descirbe this in OSC
        
        //• TODO :
        //• read tracker imp. and do some testing
        //• refactor blob model
        //• fix everything else
        //• test
        //• think about life/death of a blob and triggering states
        
        // persistnace is 0, therefor dead can trigger a full clear of all blobs
        
        
        if(tracker.getDeadLabels().size() > 0){
            
            for(int i=0; i< MAX_BLOBS; i++){
                BlobModel blob;

                // wip thru procs with no lines
                blob.line.addVertex(0,0,0);
                blob.index = i;
                for( auto &proc : processors ){
                    proc->process(blob);//• send pixels as well? 
                };
            }
        }
        
        // only itr the number of blobs we have this frame
        int num = tracker.getCurrentLabels().size();
        if(num >= MAX_BLOBS) num = MAX_BLOBS;
        
        
        // first go through MAX_BLOBS and populate blobs
        if(contourFinder.size() > 0){
        
            for(int i=0; i< num; i++){

                unsigned int label = tracker.getLabelFromIndex(i);
                
                if(tracker.existsCurrent(label)){

                    BlobModel blob;
                    blob.label = label;
                    blob.line = contourFinder.getPolyline(i);
                    blob.index = i;
                    
                    if(tracker.existsPrevious(blob.label)){
                        const cv::Rect& previous = tracker.getPrevious(blob.label);
                        const cv::Rect& current = tracker.getCurrent(blob.label);
                        blob.previousPosition = ofVec2f(previous.x + previous.width / 2, previous.y + previous.height / 2);
                        blob.currentPosition = ofVec2f(current.x + current.width / 2, current.y + current.height / 2);
                        blob.velocity = blob.currentPosition - blob.previousPosition;
                    }

                    blobs.insert(std::make_pair(label, blob));
                }
            }
        }


        // blobs now filled with current blobs, ordered according to label
        // now we can assign an index
        // nb: index will change when a blob disappears
        int i = 0;
        
        for(auto &blob: blobs){
            blob.second.index = i;
            i++;
            for( auto &proc : processors ){
                proc->process(blob.second);
            };
        }
         */
    };
    
    return procImage.getPixels();
}
