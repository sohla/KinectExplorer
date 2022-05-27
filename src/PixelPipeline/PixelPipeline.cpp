//
//  ProcessPipeline.cpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#include "PixelPipeline.hpp"

#include "Dilate_PixelProc.hpp"
#include "Erode_PixelProc.hpp"
#include "Blur_PixelProc.hpp"
#include "NearFar_PixelProc.hpp"
#include "NearFarColor_PixelProc.hpp"
#include "OSCOut_PixelProc.hpp"
#include "PixelRecorderProc.hpp"
#include "Clear_PixelProc.hpp"
#include "Generator_PixelProc.hpp"

#include "LinePipeline.hpp"

void PixelPipeline::setup(const DepthModel &model, ofxPanel &gui) {
    


    //------------------------------------------

    processors.push_back( new Generator_PixelProc());
    processors.push_back( new Clear_PixelProc());
    processors.push_back( new PixelRecorderProc());
    processors.push_back( new NearFar_PixelProc());
    processors.push_back( new Blur_PixelProc());
    //processors.push_back( new OSCOut_PixelProc("127.0.0.1","57120"));
    //••generator
    processors.push_back( new LinePipeline());

    //------------------------------------------
    
    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->setup(model, gui);
    });
             
}

void PixelPipeline::draw(const DepthModel &model){

    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->draw(model);
    });

}

void PixelPipeline::exit(){
    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        pp->exit();
    });
}

void PixelPipeline::update(const DepthModel &model, const ofPixels &pixels){

    ofPixels lp = pixels;
    
    for_each(processors.begin(), processors.end(), [&](PixelProc* pp) {
        lp = pp->process(model, lp);
    });

}

