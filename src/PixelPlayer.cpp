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

//    colorImage.allocate(int(player.getWidth()), int(player.getHeight()), OF_IMAGE_COLOR_ALPHA);
//    colorPixels.allocate(int(player.getWidth()), int(player.getHeight()), OF_IMAGE_COLOR_ALPHA);
    
    
    player.setLoopState(OF_LOOP_NORMAL);
//    player.setSpeed(0.125);
    player.play();
    
    std::cout << "playing : " << fileName << int(player.getPixelFormat()) << std::endl;

}

//void PixelPlayer::update(){
//    
//}

void PixelPlayer::draw(const DepthModel &model){
    
    grayImage.draw(0,0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
//    player.draw(0,0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
//    colorImage.draw(0,0, model.kinectWidth * model.kinectScale, model.kinectHeight * model.kinectScale);
}

void PixelPlayer::exit(){
    
}
