//
//  AnalysisManager.cpp
//  kinectExplorer
//
//  Created by Stephen OHara on 12/8/19.
//

#include "AnalysisManager.h"

void pSetHSV( float h, float s, float v, float a );

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
        prevLines.push_back(ofPolyline());
    }
//    post.init(width, height);
//    post.createPass<BloomPass>()->setEnabled(true);
//    light.setPosition(1000, 1000, 2000);
    
    ofSetBackgroundAuto(false);
}

void AnalysisManager::update(InputModel &im, const ofPixels &pixels){

    // get from input model
    int width = im.kWidth;
    int height = im.kHeight;

    int blobCount = im.sliders.get("blobCount").cast<int>();
    int nearThreshold = im.sliders.get("near").cast<int>() * 2;
    int farThreshold = im.sliders.get("far").cast<int>() * 2;
    bool bThreshWithOpenCV = im.switches.get("UseCvThreshold").cast<bool>();
    int smooth = im.sliders.get("smooth").cast<int>();
    int resample = im.sliders.get("resample").cast<int>();
    int blur = im.sliders.get("blur").cast<int>();
    
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


/*
    cv::Mat depthMat = ofxCv::toCv(depthImage);
    cv::Mat depthf = cv::Mat(height, width, CV_8UC1);
    
    depthMat.convertTo(depthf, CV_8UC1, 255.0/2048.0);
    
    const unsigned char noDepth = 0; // change to 255, if values no depth uses max value
    cv::Mat temp, temp2;
    
    // 1 step - downsize for performance, use a smaller version of depth image
    cv::Mat small_depthf;
    cv::resize(depthf, small_depthf, cv::Size(), 0.2, 0.2);
    
    // 2 step - inpaint only the masked "unknown" pixels
    cv::inpaint(small_depthf, (small_depthf == noDepth), temp, 5.0, cv::INPAINT_TELEA);
    
    // 3 step - upscale to original size and replace inpainted regions in original depth image
    resize(temp, temp2, depthf.size());
    temp2.copyTo(depthf, (depthf == noDepth)); // add to the original signal
    
    
    // convert mat to image
    ofPixels & pix = depthImage.getPixels();
    ofxCv::toOf(depthf, pix);
    //depthImage.setFromPixels(p);
*/
    
    
    
    if(im.switches.get("Blur").cast<bool>()){
        
//        depthImage.blurHeavily();
        depthImage.blurGaussian(blur);
        //depthImage.erode();
    }

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
        

        // how to filter ?
        // local new list
        // empty new resampled
        // itr thru previous list,
        //      find closest in new list
        //      add found to resampled
        //      remove found from local list
        if(im.switches.get("ApplyFilter").cast<bool>()){
            
            ofPolyline reline = smoothLines[i];
            ofPolyline newLine;
           // resampledLines[i].clear();
            int j = 0;
            float f = im.sliders.get("filter").cast<float>();


            for( auto &v : reline.getVertices()){

                float dist = 1000000;
                glm::vec3 fv;
                for( auto &nv :prevLines[i].getVertices()){

                    float td = glm::distance(nv, v);

                    if( td < dist){
                        fv = nv;
                        dist = td;
                    }
                }

                std::vector<glm::vec3>::iterator pos = std::find(reline.getVertices().begin(), reline.getVertices().end(), fv);
                if( pos != reline.getVertices().end()){
                    reline.getVertices().erase(pos);
                }

                fv.x = (f * v.x + ((1.0 - f) * fv.x));
                fv.y = (f * v.y + ((1.0 - f) * fv.y));

                newLine.addVertex(fv);

                //find nearest in reline to (v.x, v.y) return nv
                //add nv to resampledLines
                //remove nv from reline
            }
            
            prevLines[i] = newLine;
            smoothLines[i] = newLine;
            if( i == 0){
                prevLines[i] = smoothLines[i];
            }
        }
        
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

            ofBeginShape();

            int size = line.size();
            float a = ofGetFrameNum() % 360;
            for( auto &vert :  line.getVertices()){
                auto x = vert.x;
                auto y = vert.y;
                pSetHSV( a,1.0,1.0,im.sliders.get("blobAlpha").cast<float>());
                ofVertex(x, y);
            }
            ofEndShape();
       }
    }
    ofBeginShape();
        glColor4f(0,0,0,im.sliders.get("bgAlpha").cast<float>());
        ofVertex(0,0);
        ofVertex(0,height);
        ofVertex(width,height);
        ofVertex(width, 0);
    ofEndShape();

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
void pSetHSV( float h, float s, float v, float a ) {
    // H [0, 360] S, V and A [0.0, 1.0].
    int i = (int)floor(h/60.0f) % 6;
    float f = h/60.0f - floor(h/60.0f);
    float p = v * (float)(1 - s);
    float q = v * (float)(1 - s * f);
    float t = v * (float)(1 - (1 - f) * s);
    
    switch (i) {
        case 0: glColor4f(v, t, p, a);
            break;
        case 1: glColor4f(q, v, p, a);
            break;
        case 2: glColor4f(p, v, t, a);
            break;
        case 3: glColor4f(p, q, v, a);
            break;
        case 4: glColor4f(t, p, v, a);
            break;
        case 5: glColor4f(v, p, q, a);
    }
}
