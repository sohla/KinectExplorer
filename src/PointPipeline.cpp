//
//  PointPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 7/8/20.
//

#include "LinePipeline.hpp"

void LinePipeline::setup(const DepthModel &model, ofxPanel &gui){

    ofParameterGroup group;

    group.setName(title());
    group.add(onParam);
    group.add(drawParam);
    group.add(blobsParam);
    gui.add(group);

    procImage.allocate(model.kinectWidth, model.kinectHeight);

    // build point pipeline (point/polyline)
}
void LinePipeline::draw(const DepthModel &model){

    if(drawParam.get()){
        procImage.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectWidth * model.kinectScale);
        contourFinder.draw(0, 0, model.kinectWidth * model.kinectScale, model.kinectWidth * model.kinectScale);
    }
    
    int i = 0;
    for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
        pp->draw(i);
        i++;
    });

}


ofPixels LinePipeline::process(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels){
    
    procImage.setFromPixels(depthPixels);
    if(onParam.get()){

        int min = 1;
        int max = (model.kinectWidth * model.kinectHeight) / 3;

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
            for_each(processors.begin(), processors.end(), [&](LineProc* pp) {
                line = pp->process(i, line);
            });

            i++;
        });
        

    }
    
    return procImage.getPixels();
}
