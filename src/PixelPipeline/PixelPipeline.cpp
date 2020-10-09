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
#include "NDIInput_PixelProc.hpp"
#include "NDIOutput_PixelProc.hpp"
#include "SyphonOutput_PixelProc.hpp"
#include "OSCOut_PixelProc.hpp"
#include "PixelRecorderProc.hpp"

#include "LinePipeline.hpp"

void PixelPipeline::setup(const DepthModel &model, ofxPanel &gui) {
    

//    processors.push_back( new NDIInput_PixelProc());

    processors.push_back( new NearFar_PixelProc());

//    processors.push_back( new SyphonOutput_PixelProc());
//    processors.push_back( new NDIOutput_PixelProc());

    processors.push_back( new Blur_PixelProc());

    processors.push_back( new Erode_PixelProc());

//    processors.push_back( new Dilate_PixelProc());


    
    // TODO something up woth this proc's pixels post processing 
//    processors.push_back( new OSCOut_PixelProc("127.0.0.1","57130"));


    
    processors.push_back( new LinePipeline());

    processors.push_back( new PixelRecorderProc());

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

