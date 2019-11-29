//
//  AnalysisManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#include "AnalysisManager.h"


void AnalysisManager::setup(InputModel &im){

    int width = im.kWidth;
    int height = im.kHeight;

    depthImage.allocate(width, height);
    grayThreshNear.allocate(width, height);
    grayThreshFar.allocate(width, height);
    edge.allocate(width, height, OF_IMAGE_COLOR);
    
    
    sender.setup(HOST, PORT);

    ofxOscMessage m;
    m.setAddress("/gyrosc/button");
    m.addFloatArg(1.0);
    sender.sendMessage(m, false);
    
    
    
    for(int i = 0; i < MAX_BLOBS; i++){
        smoothLines.push_back(ofPolyline());
        resampledLines.push_back(ofPolyline());
    }
//    post.init(width, height);
//    post.createPass<BloomPass>()->setEnabled(true);
//    light.setPosition(1000, 1000, 2000);
}

void AnalysisManager::update(InputModel &im, const ofPixels &pixels, const ofMesh &inMesh){

    // get from input model
    int blobCount = im.sliders.get("blobCount").cast<int>();
    int nearThreshold = im.sliders.get("near").cast<int>() * 2;
    int farThreshold = im.sliders.get("far").cast<int>() * 2;
    bool bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();
    int smooth = im.sliders.get("smooth").cast<int>();
    int resample = im.sliders.get("resample").cast<int>();

    int min = 1;
    int max = (im.kWidth * im.kHeight) / 3;

    
    depthImage.setFromPixels(pixels);

    // basic ofxCv working in the pipeline
    // not using as yet
    // load gray image from source
    //ofxCv::Canny(depthImage, edge, t1, t2, 3);
//    ofxCv::Sobel(depthImage, edge);
//    edge.update();
    
    
    //---------------------------------------------------------------------------
    // PROCESS pipeline START
    //---------------------------------------------------------------------------

    if(im.switches.get("Blur").cast<bool>()){
        depthImage.blurHeavily();
    }

    // we do two thresholds - one for the far plane and one for the near plane
    // we then do a cvAnd to get the pixels which are a union of the two thresholds
    if(bThreshWithOpenCV) {
        grayThreshNear = depthImage;
        grayThreshFar = depthImage;
        grayThreshNear.threshold(nearThreshold, true);
        grayThreshFar.threshold(farThreshold);
        cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), depthImage.getCvImage(), NULL);
    } else {
        // or we do it ourselves - show people how they can work with the pixels
        ofPixels & pix = depthImage.getPixels();
        unsigned long numPixels = pix.size();
        for(int i = 0; i < numPixels; i++) {
            if(pix[i] < nearThreshold && pix[i] > farThreshold) {
                pix[i] = 255;
            } else {
                pix[i] = 0;
            }
        }
    }
    
    //depthImage.dilate();
    
    depthImage.mirror(false, true);
    depthImage.flagImageChanged();
    
    // openCV contour
    contourFinder.findContours(depthImage, min, max, blobCount, false);

    

    //---------------------------------------------------------------------------
    // ANALYSIS START
    //---------------------------------------------------------------------------

    for( auto &line : smoothLines ){line.clear();};
    for( auto &line : resampledLines ){line.clear();};
    
    int i = 0;
    for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {

        ofPolyline line;
        line.addVertices(blob.pts);
        line.setClosed(true);
        line = line.getSmoothed(smooth);
        
        smoothLines[i].addVertices(blob.pts);
        smoothLines[i].setClosed(true);
        smoothLines[i] = smoothLines[i].getSmoothed(smooth);
        
        resampledLines[i] = smoothLines[i].getResampledByCount(resample);
        resampledLines[i].setClosed(true);
        i++;
    });

    
 
    // OUTPUT ANALYSIS DATA
    i = 0;
    for( auto &line : resampledLines ){

        // only send data if the line has data
        if( line.size() > 0){
            float area = ofMap(line.getArea(), 0, -130000, 0.0, 1.0);
            float perimeter = ofMap(line.getPerimeter(), 0, 3000, 0.0, 1.0);
            glm::vec2 center = line.getCentroid2D();
            ofRectangle bounds = line.getBoundingBox();

           // std::cout << i << " : " << line.size() << " : " << area << " : " << perimeter << center << " : " ;
            ofxOscMessage m;
            m.setAddress("/blobi");
            
            m.addIntArg(i);
            m.addIntArg(line.size());

            m.addFloatArg(area);
            m.addFloatArg(perimeter);

            m.addFloatArg(ofMap(center.x, 0, 1000, 0.0, 1.0));
            m.addFloatArg(ofMap(center.y, 0, 1000, 0.0, 1.0));

            m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));
            m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));

            m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));
            m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));

            for( auto &vert :  line.getVertices()){
                m.addDoubleArg(vert.x);
                m.addDoubleArg(vert.y);
                //std::cout << vert.x << " , " << vert.y;
            }
            //std::cout << std::endl;
            
            sender.sendMessage(m, false);
        }
        i++;
    }
}

void AnalysisManager::draw(InputModel &im){
   
    int width = im.kWidth;
    int height = im.kHeight;
    int smooth = im.sliders.get("smooth").cast<int>();

    if(im.switches.get("DrawGray").cast<bool>()){
        
        ofSetHexColor(0xFFFFFF);
        depthImage.draw(0, 0, width, height);
    }

    if(im.switches.get("DrawContour").cast<bool>()){
        
        ofSetHexColor(0x00FFFF);
        contourFinder.draw(0, 0, width, height);
    }
    
    float xa = im.sliders.get("Xamp").cast<float>();
    float xf = im.sliders.get("Xfrq").cast<float>();
    float ya = im.sliders.get("Yamp").cast<float>();
    float yf = im.sliders.get("Yfrq").cast<float>();
    

    if(im.switches.get("Smooth").cast<bool>()){

        ofSetHexColor(0x0000FF);

        int i;
        for( auto & line : smoothLines){
            line.draw();
        }
    }

    if(im.switches.get("Resample").cast<bool>()){
        
        ofSetHexColor(0xFF0000);
        
        for( auto &line : resampledLines ){
//            std::cout << "::" << line.size() << std::endl;
            
            line.draw();

            // fill resample line
            ofSetColor(200,10,20);
            ofBeginShape();

            int i;
            for( auto &vert :  line.getVertices()){
                auto x = vert.x + (sin(xf * (ofGetFrameNum() + i)) * xa);
                auto y = vert.y + (sin(yf * (ofGetFrameNum() + i)) * ya);
                ofVertex(x, y);
            i++;
            }
            ofEndShape();
            
        }
    }
 }

void AnalysisManager::exit(){
    
}
double polygon_area(int actual_size, double x[], double y[])
{
    printf("In polygon.area\n");
    
    double area = 0.0;
    
    for (int i = 0; i < actual_size; ++i)
    {
        int j = (i + 1)%actual_size;
        area += 0.5 * (x[i]*y[j] -  x[j]*y[i]);
    }
    
    printf("The area of the polygon is %lf  \n", area);
    
    return (area);
}
