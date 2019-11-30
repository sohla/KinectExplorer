//
//  PixelPlayer.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//


#include "PixelPlayer.h"



void PixelPlayer::setup(string fileName){
    
    player.load(fileName);
    
    inputImage.clear();
    grayImage.clear();
    inputImage.allocate(int(player.getWidth()), int(player.getHeight()));
    grayImage.allocate(int(player.getWidth()), int(player.getHeight()));
    
    player.setLoopState(OF_LOOP_NORMAL);
    player.play();
    
    std::cout << "playing : " << fileName << int(player.getPixelFormat()) << std::endl;

}

//void PixelPlayer::update(){
//    
//}

void PixelPlayer::draw(){
    //player.draw(0,0);
    grayImage.draw(0, 480);
}

void PixelPlayer::exit(){
    
}
