//
//  PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 5/8/20.
//

#ifndef PixelProc_hpp
#define PixelProc_hpp

#include <stdio.h>


class PixelProc {
    
    
public:
    
    virtual void setup(InputModel &im){};
    virtual void draw(InputModel &im){};
    virtual ofPixels process(const InputModel &im, const ofPixels &depthPixels){};
};
#endif /* PixelProc_hpp */
