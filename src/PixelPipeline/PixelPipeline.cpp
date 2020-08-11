//
//  ProcessPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#include "PixelPipeline.hpp"

#include "Base_PixelProc.hpp"
#include "LinePipeline.hpp"

void PixelPipeline::setup(const DepthModel &model, ofxPanel &gui) {
    
    processors.push_back( new NearFar_PixelProc());
    processors.push_back( new Blur_PixelProc());
    processors.push_back( new Erode_PixelProc());
    processors.push_back( new Dilate_PixelProc());
    processors.push_back( new LinePipeline());
    processors.push_back( new Syphon_PixelProc());

    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->setup(model, gui);
    });
             
}

void PixelPipeline::draw(const DepthModel &model){

    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->draw(model);
    });

}

void PixelPipeline::update(const DepthModel &model, const ofPixels &pixels){

    ofPixels lp = pixels;
    
    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        lp = pp->process(model, lp);
    });

}

