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

}

void AnalysisManager::update(InputModel &im, const ofPixels &pixels, const ofMesh &inMesh){

    // get from input model
    int blobCount = im.sliders.get("blobCount").cast<int>();
    int nearThreshold = im.sliders.get("near").cast<int>() * 2;
    int farThreshold = im.sliders.get("far").cast<int>() * 2;
    bool bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();
    int smooth = im.sliders.get("smooth").cast<int>();

    int min = 1;
    int max = (im.kWidth * im.kHeight) / 3;

    
    // basic ofxCv working in the pipeline
    // need to hook it all up to input model (gui)
    int t1 = im.sliders.get("t1").cast<int>();
    int t2 = im.sliders.get("t2").cast<int>();
    
    // load gray image from source
    depthImage.setFromPixels(pixels);

    //ofxCv::Canny(depthImage, edge, t1, t2, 3);
    ofxCv::Sobel(depthImage, edge);
    edge.update();
    
    
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

    //---------------------------------------------------------------------------
    // ANALYSIS START
    //---------------------------------------------------------------------------

    // openCV contour
    contourFinder.findContours(depthImage, min, max, blobCount, false);
    
    int count = 0;
    for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {

        ofPolyline line;
        line.addVertices(blob.pts);
        line.setClosed(true);
        line = line.getSmoothed(smooth);
        
        // OUTPUT ANALYSIS DATA
        //float area = ofMap(blob.area, 20000, 100000, 0.1, 4.0);
        float area = ofMap(line.getArea(), 0, -130000, 0.0, 1.0);
        float perimeter = ofMap(line.getPerimeter(), 0, 3000, 0.0, 1.0);
        glm::vec2 center = line.getCentroid2D();
        ofRectangle bounds = line.getBoundingBox();
        
//        std::cout << count << " : " << line.size() << " : " << area << " : " << perimeter << center << bounds << std::endl;
        ofxOscMessage m;
        m.setAddress("/blobi");
        
        m.addIntArg(count);
        
        m.addFloatArg(area);
        m.addFloatArg(perimeter);

        m.addFloatArg(ofMap(center.x, 0, 1000, 0.0, 1.0));
        m.addFloatArg(ofMap(center.y, 0, 1000, 0.0, 1.0));

        m.addFloatArg(ofMap(bounds.x, 0, 1000, 0.0, 1.0));
        m.addFloatArg(ofMap(bounds.y, 0, 1000, 0.0, 1.0));

        m.addFloatArg(ofMap(bounds.width, 0, 1000, 0.0, 1.0));
        m.addFloatArg(ofMap(bounds.height, 0, 1000, 0.0, 1.0));


        sender.sendMessage(m, false);

        
//        float rocArea = (area - oldArea);
//        filterLowPass.setFc(0.03);
//        filterLowPass.update(abs(rocArea));
//        float score = abs(filterLowPass.value()) * 5.0;
//        float ms = ofMap(score, 0.0, 1.0, 0.1, 4.0);

        // move to oscTransmitterManager :
//        ofxOscMessage m;
//        m.setAddress("/gyrosc/rrate");
//        m.addFloatArg(ms);
//        m.addFloatArg(ms);
//        m.addFloatArg(ms);
//        sender.sendMessage(m, false);
        
//        oldArea = area;

        count++;
    });
    
}

void AnalysisManager::draw(InputModel &im){
   
    int width = im.kWidth;
    int height = im.kHeight;
    int smooth = im.sliders.get("smooth").cast<int>();

 /*
//    cam.begin();
    glPointSize(2);
    glLineWidth(1);
    ofPushMatrix();
    // the projected points are 'upside down' and 'backwards'
    ofScale(1, 1, -1);
    ofTranslate(0, 0, -1000); // center the points a bit
    ofEnableDepthTest();
    mesh.drawVertices();
    ofDisableDepthTest();
    ofPopMatrix();
//    cam.end();
*/
    if(im.switches.get("DrawGray").cast<bool>()){
        
        ofSetHexColor(0xFFFFFF);
        depthImage.draw(0, 0, width, height);
    }

    if(im.switches.get("DrawContour").cast<bool>()){
        
        ofSetHexColor(0x00FFFF);
        contourFinder.draw(0, 0, width, height);
    }
    
    int nb = contourFinder.nBlobs;
    
    for_each(contourFinder.blobs.begin(), contourFinder.blobs.end(), [&](ofxCvBlob blob) {
        
        if(im.switches.get("Stored").cast<bool>()){

            ofSetHexColor(0x0000FF);
//            storedLine.draw();
            
            ofPolyline line;
            line.addVertices(blob.pts);
            line.setClosed(true);
            line.draw();
        }

        if(im.switches.get("Smoothed").cast<bool>()){
            
            ofSetHexColor(0xFFFF00);
            //smoothedLine.draw();
            ofPolyline line;
            line.addVertices(blob.pts);
            line.setClosed(true);
            line = line.getSmoothed(smooth);

            ofPolyline dl;
            dl = line.getResampledByCount(24);
            
            ofSetHexColor(0x0FFF0F);
            dl.draw();
            
            ofSetHexColor(0xF00F00);
            ofFill();
            
            ofBeginShape();
            for( int i = 0; i < line.getVertices().size(); i++) {
                ofVertex(line.getVertices().at(i).x, line.getVertices().at(i).y);
            }
            ofEndShape();
            
        }

        if(im.switches.get("DrawFinder").cast<bool>()){
            ofSetHexColor(0xFFFFFF);
            edge.draw(0,0,width,height);
        };


    });

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
