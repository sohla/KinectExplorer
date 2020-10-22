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

    procImage.allocate(model.kinectWidth, model.kinectHeight);

    // setup up countour finding and tracking
    contourFinder.setMinAreaRadius(minRadiusParam.get());
    contourFinder.setMaxAreaRadius(maxRadiusParam.get());
    contourFinder.setThreshold(thresholdParam.get());
//    contourFinder.setSortBySize(true);
    
    contourFinder.getTracker().setPersistence(0); //in frames?
    contourFinder.getTracker().setMaximumDistance(distanceParam.get());

    


    //
    // build line pipeline
    //
    
    processors.push_back(new Resample_LineProc());
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
            ofScale(model.kinectScale, model.kinectScale);

        contourFinder.draw();

            for(auto &blob: blobs){
                
                ofSetColor(ofColor::fromHsb(ofRandom(255), 255, 255));
                ofDrawLine(blob.second.previousPosition, blob.second.currentPosition);
                ofSetColor(ofColor(255));
                ofDrawLine(blob.second.currentPosition, blob.second.currentPosition + (blob.second.velocity * 2.0));
                ofDrawBitmapString(ofToString(blob.second.index) + ":" + ofToString(blob.second.label), blob.second.currentPosition);
            }

        ofPopMatrix();

    }


    // draw pipeline
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        for(auto &blob: blobs){
            pp->draw(model,blob.second);
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
        
        ofxCv::RectTracker& tracker = contourFinder.getTracker();
//        tracker.setPersistence(persistanceParam.get());
        tracker.setMaximumDistance(distanceParam.get());

        blobs.clear();
        
        // persistnace is 0, therefor dead can trigger a full clear of all blobs
        if(tracker.getDeadLabels().size() > 0){
            
            for(int i=0; i< MAX_BLOBS; i++){
                BlobModel blob;

                // wip thru procs with no lines
                blob.line.addVertex(0,0,0);
                blob.index = i;
                for( auto &proc : processors ){
                    proc->process(blob);
                };
            }
        }
        
        // first go through MAX_BLOBS and popultate blobs
        if(contourFinder.size() > 0){
        
            for(int i=0; i< MAX_BLOBS; i++){


                unsigned int label = tracker.getLabelFromIndex(i);
                
                if(tracker.existsCurrent(label)){

                    BlobModel blob;
                    blob.label = label;
                    blob.line = contourFinder.getPolyline(i);
                    
                    if(tracker.existsPrevious(blob.label)){
                        const cv::Rect& previous = tracker.getPrevious(blob.label);
                        const cv::Rect& current = tracker.getCurrent(blob.label);
                        blob.previousPosition = ofVec2f(previous.x + previous.width / 2, previous.y + previous.height / 2);
                        blob.currentPosition = ofVec2f(current.x + current.width / 2, current.y + current.height / 2);
                        blob.velocity = ofVec2f(tracker.getVelocity(i)[0], tracker.getVelocity(i)[1]);
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
 
    };
    
    return procImage.getPixels();
}
