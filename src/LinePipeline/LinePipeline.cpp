//
//  PointPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#include "LinePipeline.hpp"
#include "Base_LineProc.hpp"

void LinePipeline::setup(const DepthModel &model, ofxPanel &gui){

    ofParameterGroup group;

    group.setName(title());
    group.add(onParam);
    group.add(drawParam);
    group.add(blobsParam);
    gui.add(group);

    procImage.allocate(model.kinectWidth, model.kinectHeight);

    //
    // build line pipeline
    //
    
    processors.push_back(new Smooth_LineProc());
    processors.push_back(new Resample_LineProc());
    
    //
    //
    //
    
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->setup(gui);
    });

    
}
void LinePipeline::draw(const DepthModel &model){

    if(drawParam.get()){
        procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
        contourFinder.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
    }

    // draw pipeline
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->draw(model);
    });
    
}


ofPixels LinePipeline::process(const DepthModel &model, const ofPixels &pixel){
    
    procImage.setFromPixels(pixel);
    if(onParam.get()){

        int min = 1;
        int max = (model.kinectWidth * model.kinectHeight) / 1;

        contourFinder.findContours(procImage, min, max, blobsParam.get(), true);

        // point pipeline begins.....
        
        // itr through the blobs, pass i
        int i = 0;
        for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {

            // generate a polyline from blob points
            ofPolyline line;
            line.addVertices(blob.pts);
            line.setClosed(true);

            // itr through procs passing polyline
            for( auto &proc : processors ){
                line = proc->process(i, line);
            };

            i++;
        });
        

    }
    
    return procImage.getPixels();
}
