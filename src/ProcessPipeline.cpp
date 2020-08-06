//
//  ProcessPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#include "ProcessPipeline.hpp"

#include "NearFar_PixelProc.hpp"
#include "Base_PixelProc.hpp"

void ProcessPipeline::setup(const DepthModel &model, ofxPanel &gui) {
    
    processors.push_back( new NearFar_PixelProc());
    processors.push_back( new Blur_PixelProc());
    processors.push_back( new Erode_PixelProc());
    processors.push_back( new Dilate_PixelProc());

    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->setup(model, gui);
    });
             
}

void ProcessPipeline::draw(const DepthModel &model){

    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->draw(model);
    });

}

void ProcessPipeline::update(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels){

    ofPixels pixels = depthPixels;
    
    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pixels = pp->process(model, videoPixels, pixels);
    });

}

