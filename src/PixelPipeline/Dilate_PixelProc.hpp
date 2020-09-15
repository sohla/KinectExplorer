//
//  Dilate_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef Dilate_PixelProc_hpp
#define Dilate_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class Dilate_PixelProc : public Base_PixelProc {
    
    void proc(){procImage.dilate();}
    string title(){return "dilate";};
};


#endif /* Dilate_PixelProc_hpp */
