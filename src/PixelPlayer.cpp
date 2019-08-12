//
//  PixelPlayer.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//


#include "PixelPlayer.h"



void PixelPlayer::setup(string fileName){
    
    player.load(fileName);
    
    grayImage.allocate(player.getWidth(), player.getHeight());

    player.setLoopState(OF_LOOP_NORMAL);
    player.play();
    
    std::cout << int(player.getPixelFormat()) << std::endl;

}

//void PixelPlayer::update(){
//    
//}

void PixelPlayer::draw(){
    
}

void PixelPlayer::exit(){
    
}
