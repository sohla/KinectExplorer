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

class PixelPlayer {
    
public:
    
    void setup(string fileName);
    //void update();
    void draw();
    void exit();
    
    template<typename F>
    void update(F next){

        if(player.isLoaded()){
            
            player.update();
            inputImage.setFromPixels(player.getPixels());
            grayImage = inputImage;
            next(grayImage.getPixels());
        }else{
            //next(nothing);
        }
    }

private:
    
    ofVideoPlayer         player;
    ofxCvColorImage     inputImage;
    ofxCvGrayscaleImage grayImage;
};

#endif /* PixelPlayer_hpp */
