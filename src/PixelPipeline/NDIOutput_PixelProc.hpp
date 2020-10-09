//
//  NDIOutput_PixelProc.hpp
//  KinectExplorer
//
//  Created by Stephen OHara on 15/9/20.
//

#ifndef NDIOutput_PixelProc_hpp
#define NDIOutput_PixelProc_hpp

#include <stdio.h>
#include "Base_PixelProc.hpp"

//------------------------------------------------------------
//
//------------------------------------------------------------

class NDIOutput_PixelProc : public Base_PixelProc {

    ofxNDISender sender;
    ofxNDISendVideo video;

    void setup(const DepthModel &model, ofxPanel &gui){
        
        ofParameterGroup group;
        
        group.setName(title());
        gui.add(group);
        
        if(sender.setup("keNDIOutput")) {
            video.setup(sender);
            video.setAsync(true);
        }

        auto pixelFormat = OF_PIXELS_BGRA;

        
        
    }

    void proc(){
        ofPixels p;
        ofGetGLRenderer()->saveFullViewport(p);
        video.send(p);
    };
    
    
    string title(){return "ndi sender";};
};


#endif /* NDIOutput_PixelProc_hpp */
