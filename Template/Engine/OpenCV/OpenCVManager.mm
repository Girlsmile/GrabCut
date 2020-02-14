//
//  OpenCVManager.m
//  GrabCut
//
//  Created by Endless Summer on 2019/12/30.
//  Copyright © 2019 flow. All rights reserved.
//

/// 忽略编译警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#pragma clang pop

#import "OpenCVManager.h"

@implementation OpenCVManager

cv::Mat mask; // segmentation (4 possible values)
cv::Mat bgModel,fgModel; // the models (internally used)
cv::Mat sourceMat;

//修正rgb通道
-(cv::Mat) changeTORGB:(cv::Mat)cvMat {
    
    cv::Mat imageDst = cv::Mat::zeros(cvMat.size(), CV_8UC3);
    
    for ( size_t y=0; y<imageDst.rows; y++ )
    {
        for ( size_t x=0; x<imageDst.cols; x++ )
        {
            // 访问位于 x,y 处的像素
            // 用cv::Mat::ptr获得图像的行指针
            unsigned char* row_ptr = imageDst.ptr<unsigned char> ( y );  // row_ptr是第y行的头指针
            unsigned char* data_ptr = &row_ptr[ x*imageDst.channels() ]; // data_ptr 指向待访问的像素数据
            unsigned char* row_ptr1 = cvMat.ptr<unsigned char> ( y );
            unsigned char* data_ptr1 = &row_ptr1[ x*cvMat.channels() ];
            
            unsigned char* row_ptr2 = cvMat.ptr<unsigned char> ( y );
            unsigned char* data_ptr2 = &row_ptr2[ x*cvMat.channels() ];
            
            // 输出该像素的每个通道,如果是灰度图就只有一个通道
            for ( int c = 0; c != imageDst.channels(); c++ )
            {
                if(c==0)
                    data_ptr[c] = data_ptr1[2];        //B
                else if(c==1)
                    data_ptr[c] = data_ptr2[1];       //G
                else if(c==2)
                    data_ptr[c] = data_ptr1[0];    //R
            }
        }
    }
    
    return imageDst;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    
  
    cvMat = [self changeTORGB: cvMat];
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage =  [UIImage imageWithCGImage: imageRef]; // [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
//    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(finalImage.CGImage);
//    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
//
//    float width = finalImage.size.width;
//    float height = finalImage.size.height;
//
//    // Get source image data
//    uint8_t *imageData = (uint8_t *) malloc(width * height * 4);
//
//    CGContextRef imageContext = CGBitmapContextCreate(imageData,
//            width, height,
//            8, static_cast<size_t>(width * 4),
//            colorRef, alphaInfo);
//
//    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), finalImage.CGImage);
//    CGContextRelease(imageContext);
//    CGColorSpaceRelease(colorRef);
    
    return finalImage;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGBitmapByteOrder32Host |
                                                    kCGImageAlphaPremultipliedFirst |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat1b)cvMatMaskerFromUIImage:(UIImage *)image{
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    cv::Mat1b markers((int)height, (int)width);
    markers.setTo(cv::GC_PR_BGD);
//    cv::Mat1b markers = mask;
    uchar* data = markers.data;
    
    int countFGD=0, countBGD=0, countRem = 0;
    
    for(int x = 0; x < width; x++){
        for( int y = 0; y < height; y++){
            NSUInteger byteIndex = ((image.size.width  * y) + x ) * 4;
            UInt8 red   = rawData[byteIndex];
            UInt8 green = rawData[byteIndex + 1];
            UInt8 blue  = rawData[byteIndex + 2];
            UInt8 alpha = rawData[byteIndex + 3];
            
            if (red == 255 && green == 255 && blue == 255 && alpha == 255){
                data[width*y + x] = cv::GC_FGD;
                countFGD++;
            }
            else if (red == 0 && green == 0 && blue == 0 && alpha == 255){
                data[width*y + x] = cv::GC_BGD;
                countBGD++;
            }
            else {
                countRem++;
            }
        }
    }
    
    free(rawData);
    
    #if DEBUG
    NSLog(@"Count %d %d %d sum : %d width*height : %lu", countFGD, countBGD, countRem, countFGD+countBGD + countRem, width*height);
    #endif
    
    return markers;
}

-(UIImage*)doGrabCut:(UIImage*)sourceImage foregroundRect:(CGRect)rect iterationCount:(int)iterationCount {
    //将UIImage转换为Mat
    sourceMat = [self cvMatFromUIImage:sourceImage];
//    UIImageToMat(sourceImage, sourceMat);
    //RGBA > BGR
    //COLOR_BGRA2BGR
    cv::cvtColor(sourceMat , sourceMat , cv::COLOR_BGRA2BGR);
    
    //转换CGRect成Rect
    cv::Rect rectangle(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    //GrabCut
    //bgModel, fgMolde: 处理中使用的数组
    //iterationCount: 重复该过程的次数
    
    cv::grabCut(sourceMat, mask, rectangle, bgModel, fgModel, iterationCount, cv::GC_INIT_WITH_RECT);
    
    
    //从结果中提取前景（GC_PR_FGD）区域并二值化
       
    UIImage *resultImage = [self changeBackground: cv::Scalar(254,255,255)];
    return resultImage;
}

-(UIImage *)changeColor:(int)r g:(int)g b:(int)b {
    UIImage *image = [self changeBackground:cv::Scalar(r,g,b)];
    return image;
}


- (UIImage *)changeBackground:(cv::Scalar)colorVector {
    cv::Mat1b fgMask;
    cv::compare(mask, cv::GC_PR_FGD, fgMask, cv::CMP_EQ);
    
    // Generate output image
    cv::Mat foreground(sourceMat.size(),CV_8UC3,
                       colorVector);
    
    
    fgMask=fgMask&1;
    sourceMat.copyTo(foreground, fgMask);
    
    UIImage *resultImage=[self UIImageFromCVMat:foreground];
    
    return resultImage;
    
}


//- (UIImage *)doGrabCutWithMask:(UIImage *)sourceImage maskImage:(UIImage *)maskImage iterationCount:(int) iterCount {
//
//    mask.setTo(cv::GC_PR_BGD);
//    bgModel.setTo(0);
//    fgModel.setTo(0);
//
//    cv::Mat img=[self cvMatFromUIImage:sourceImage];
//    cv::cvtColor(img , img , cv::COLOR_RGBA2RGB);
//
//    cv::Rect rectangle(0, 0, sourceImage.size.width, sourceImage.size.height);
////    cv::grabCut(img, mask, rectangle, bgModel, fgModel, iterCount, cv::GC_INIT_WITH_MASK);
//
//    cv::Mat1b markers=[self cvMatMaskerFromUIImage:maskImage];
////    cv::Rect rectangle(0,0,0,0);
//    cv::grabCut(img, markers, rectangle, bgModel, fgModel, iterCount, cv::GC_INIT_WITH_MASK);
//
//    cv::Mat tempMask;
//    cv::compare(mask,cv::GC_PR_FGD,tempMask,cv::CMP_EQ);
//    // Generate output image
//    cv::Mat foreground(img.size(),CV_8UC3,
//                       cv::Scalar(254,255,255));
//
//    tempMask=tempMask&1;
//    img.copyTo(foreground, tempMask);
//
//    UIImage *resultImage = MatToUIImage(foreground);
////    UIImage *resultImage=[self UIImageFromCVMat:foreground];
//
//
//    return resultImage;
//}


@end
