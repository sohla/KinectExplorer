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
        player.update();
        //grayImage.setFromPixels(player.getPixels());
        next(player.getPixels());
    }

private:
    
    ofVideoPlayer         player;
    ofxCvGrayscaleImage   grayImage;
};

#endif /* PixelPlayer_hpp */
