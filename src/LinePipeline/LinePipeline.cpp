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
    gui.add(group);

    procImage.allocate(model.kinectWidth, model.kinectHeight);

    // setup up countour finding and tracking
    // •• PLAY Around with these settings
    contourFinder.setMinAreaRadius(30);
    contourFinder.setMaxAreaRadius(160);
    contourFinder.setThreshold(thresholdParam.get());
    // wait for half a second before forgetting something
    contourFinder.getTracker().setPersistence(15);
    // an object can move up to 32 pixels per frame
    contourFinder.getTracker().setMaximumDistance(32);



    //
    // build line pipeline
    //
    
    processors.push_back(new Smooth_LineProc());
    processors.push_back(new Resample_LineProc());
    
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
        
        contourFinder.findContours(procImage);
        
        
        // point pipeline begins.....

        
        // hack for clearing out all lines fro all blobs for the whole processors. expensive
        for(int i=0; i< MAX_BLOBS; i++){
            ofPolyline line;
            line.addVertex(0,0,0);
            for( auto &proc : processors ){
                proc->process(i, line);
            }
        }
        //• all this needs to be fixed. need to check if each blob found is updated, else we don't need to
        //• do we need to track blobs? YES WE DO!@
  
//        std::cout << contourFinder.size() << std::endl;

        // itr through the blobs, pass i
//        int i = 0;
//        for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {
        for(int i = 0; i < contourFinder.size(); i++) {
            // generate a polyline from blob points
            ofPolyline line = contourFinder.getPolyline(i);
//            line.addVertices(blob.pts);
//            line.setClosed(true);

            // itr through procs passing polyline
            for( auto &proc : processors ){
                line = proc->process(i, line);
            };

//            i++;
        };
 
    }
    
    return procImage.getPixels();
}
