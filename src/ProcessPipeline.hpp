//
//  ProcessPipeline.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#ifndef ProcessPipeline_hpp
#define ProcessPipeline_hpp

#include <stdio.h>
//#include "InputModel.h"
#include "ofxGui.h"

#include "PixelProc.hpp"


/*
  
  setup builds up the pipeline (ofPixels)
  
     -> depthImage -> nearFar -> blur -> mirror -> PointsPipeline(contourFinder*) -> syphonOut
                                                         |
                                                 * contourFinder is an image to geometry generator (ofPoints or ofPolyline)
                                                         |
                                                          -> smoother -> icp (sorter) -> oscSender -> midiSender
  
     PixelPipeline(const InputModel &im, const ofPixels &pixels)
         
         PixelProc
             process(const InputModel &im, const ofPixels &pixels) returns ofPixels
  
     
  
         Set<PixelProc>
             for each ( process )
             
  
     PointsPipeline(const InputModel &im, const ofPixels &pixels)
  
         PointsProc
             process(const InputModel &im, const ofPoints &points) returns ofPoints
         
         Set<PointsProc>
             for each ( process )

  
    PixelProc
    PointsProc
 
    
  
     

     NearFar_PixelProc : PixelProc
     Blur_PixelProc : PixelProc
     Mirror_PixelProc : PixelProc
     Points_PixelProc : PixelProc

         Smoother_PointsProc : PointsProc
         ICP_PointsProc : PointsProc
         OSCSender_PointsProc : PointsProc
  
 
    InputModel -> guiModel instead (not const)
 
    setup gets called once and builds
    after traversing tree, build the gui
 
    GUI
  */

class ProcessPipeline {
    
    std::vector<PixelProc*> processors;
    
public:

    void setup(const DepthModel &model, ofxPanel &gui);
    void draw(const DepthModel &model);
    void update(const DepthModel &model, const ofPixels &videoPixels, const ofPixels &depthPixels);
    

};

#endif /* ProcessPipeline_hpp */
