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
    group.add(persistanceParam);
    group.add(distanceParam);
    gui.add(group);

    procImage.allocate(model.kinectWidth, model.kinectHeight);

    // setup up countour finding and tracking
    contourFinder.setMinAreaRadius(minRadiusParam.get());
    contourFinder.setMaxAreaRadius(maxRadiusParam.get());
    contourFinder.setThreshold(thresholdParam.get());

    contourFinder.getTracker().setPersistence(persistanceParam.get()); //in frames?
    contourFinder.getTracker().setMaximumDistance(distanceParam.get());



    //
    // build line pipeline
    //
    
    processors.push_back(new Smooth_LineProc());
//    processors.push_back(new Resample_LineProc());
    
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
        // dont think we need to draw the innput (procImage) here
        //        procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
        ofPushMatrix();
        ofScale(model.kinectScale, model.kinectScale);
        contourFinder.draw();
        ofPopMatrix();
    }

    // draw pipeline
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->draw(model);
    });
    
    // show tracker details
    ofxCv::RectTracker& tracker = contourFinder.getTracker();
    for(int i = 0; i < contourFinder.size(); i++) {
        unsigned int label = contourFinder.getLabel(i);
        // only draw a line if this is not a new label
        if(tracker.existsPrevious(label)) {
            // use the label to pick a random color
            ofSeedRandom(label << 24);
            ofSetColor(ofColor::fromHsb(ofRandom(255), 255, 255));
            // get the tracked object (cv::Rect) at current and previous position
            const cv::Rect& previous = tracker.getPrevious(label);
            const cv::Rect& current = tracker.getCurrent(label);
            // get the centers of the rectangles
            ofVec2f previousPosition(previous.x + previous.width / 2, previous.y + previous.height / 2);
            ofVec2f currentPosition(current.x + current.width / 2, current.y + current.height / 2);

            ofVec2f vel = ofVec2f(tracker.getVelocity(i)[0], tracker.getVelocity(i)[1]);
            
            ofPushMatrix();
            ofScale(model.kinectScale, model.kinectScale);
            ofDrawLine(previousPosition, currentPosition);

            ofSetColor(ofColor(255));
            ofDrawLine(currentPosition, currentPosition + (vel * 2.0));

            ofDrawBitmapString(to_string(label), currentPosition);
            ofPopMatrix();
       }
    }
    
    
}
//ofPixels LinePipeline::process(const DepthModel &model, const ofPixels &pixel){
//
//
//    procImage.setFromPixels(pixel);
//
//    if(onParam.get()){
//
//        contourFinder.findContours(procImage);
//
//        // clear out all lines....
//        for(int i=0; i< MAX_BLOBS; i++){
//            ofPolyline line;
//            line.addVertex(0,0,0);
//            for( auto &proc : processors ){
//                proc->process(i, line);
//            }
//        }
//
//
//    }
//
//    return procImage.getPixels();
//}

ofPixels LinePipeline::process(const DepthModel &model, const ofPixels &pixel){
    
    procImage.setFromPixels(pixel);
    if(onParam.get()){

        
        int min = 1;
        int max = (model.kinectWidth * model.kinectHeight) / 1;

//        contourFinder.findContours(procImage, min, max, blobsParam.get(), false);
        
        contourFinder.setThreshold(thresholdParam.get());
        contourFinder.setMinAreaRadius(minRadiusParam.get());
        contourFinder.setMaxAreaRadius(maxRadiusParam.get());

        contourFinder.findContours(procImage);
        
        
        ofxCv::RectTracker& tracker = contourFinder.getTracker();
        
        tracker.setPersistence(persistanceParam.get());
        tracker.setMaximumDistance(distanceParam.get());

        
        
        std::cout << tracker.getCurrentLabels().size() << std::endl;
        
        
        // point pipeline begins.....
        
        
        // hack for clearing out all lines fro all blobs for the whole processors.
        // let's use the tracker to check for current blobs
//        if(tracker.getCurrentLabels().size() == 0){
            for(int i=0; i< MAX_BLOBS; i++){
                BlobModel blob;
                blob.line.addVertex(0,0,0);
                blob.index = i;
                blob.label = i;
                for( auto &proc : processors ){
                    blob.line = proc->process(blob);
                }
            }
//        }
        
        
        //• all this needs to be fixed. need to check if each blob found is updated, else we don't need to
        //• do we need to track blobs? YES WE DO!@
  

        // itr through the blobs, pass i
//        int i = 0;
//        for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {
        
        if(contourFinder.size() < MAX_BLOBS){
            for(int i = 0; i < contourFinder.size(); i++) {

                BlobModel blob;
                blob.label = tracker.getLabelFromIndex(i); //contourFinder.getLabel(i);
                blob.index = i;
                
                
                ofPolyline line;
                
                std::vector<cv::Point> ch = contourFinder.getContour(i);
                
                for(auto &p : ch){
                    line.addVertex(ofPoint(p.x, p.y));
                }
                line.setClosed(true);
                
                blob.line = line;
//                line.addVertices();
                
//                ofPolyline line = contourFinder.getPolyline(i);
    //            line.addVertices(blob.pts);
    //            line.setClosed(true);
                


                if(tracker.existsPrevious(blob.label)){
                    const cv::Rect& previous = tracker.getPrevious(blob.label);
                    const cv::Rect& current = tracker.getCurrent(blob.label);
                    blob.previousPosition = ofVec2f(previous.x + previous.width / 2, previous.y + previous.height / 2);
                    blob.currentPosition = ofVec2f(current.x + current.width / 2, current.y + current.height / 2);
                }

                
                // itr through procs passing blob
                for( auto &proc : processors ){
                    blob.line = proc->process(blob);
                };
                
//                blob.debug();
    //            i++;
            };
        };
    }
    
    return procImage.getPixels();
}
