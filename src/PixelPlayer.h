//
//  PixelPlayer.hpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#ifndef PixelPlayer_hpp
#define PixelPlayer_hpp

#include <stdio.h>

#include "ofMain.h"
#include "ofxOpenCv.h"

#include "PixelProc.hpp"


class PixelPlayer {
    
public:
    
    void setup(string fileName);
    //void update();
    void draw(const DepthModel &model);
    void exit();
    
    template<typename F>
    void update(F next){

        if(player.isLoaded()){
            
            player.update();
            
            // example of converting greyscale to color
            // adding alpha channel and output
 /*
            ofPixels & pix = player.getPixels();
                
            unsigned long w = colorPixels.getWidth();
            unsigned long h = colorPixels.getHeight();
        
            for(int i = 0; i < w; i++) {
                for(int j = 0; j < h; j++) {

                    ofColor pixCol = pix.getColor(i,j);
                    
                    if(pixCol.getBrightness() > 130){
                        ofColor newCol = ofColor(255, 255);
                        colorPixels.setColor(i, j, newCol);
                    }else{
                        ofColor newCol = ofColor(pixCol, 0);
                        colorPixels.setColor(i, j, newCol);

                    }
                }
            }

            colorImage.setFromPixels(colorPixels);
*/
            ofPixels & pix = player.getPixels();
            inputImage.setFromPixels(pix);

            grayImage = inputImage;
            next(grayImage.getPixels());
        }else{
            //next(nothing);
        }
    };

    void switchPlayerState() {
        
        if(player.isPlaying()){
            player.setPaused(true);
        }else{
            player.setPaused(false);
        }
    };

    void nextFrame() {
        
        if(player.isPaused()){
            player.nextFrame();
        }
    }

    void previousFrame() {
        
        if(player.isPaused()){
            player.previousFrame();
        }
    }

private:
    
    ofVideoPlayer         player;
    ofxCvColorImage     inputImage;
    ofxCvGrayscaleImage grayImage;
    
//    ofImage colorImage;
//    ofPixels colorPixels;
};

#endif /* PixelPlayer_hpp */
