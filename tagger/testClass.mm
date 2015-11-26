//
//  Example2.m
//  tagger
//
//  Created by Paolo Longato on 10/08/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "testClass.h"

#include <opencv2/core/core.hpp>
#include <opencv2/ml/ml.hpp>

using namespace cv;

@interface testClass ()
{
   Ptr<ml::SVM> model;
}
@property (nonatomic) Ptr<ml::SVM> model;
@end

@implementation testClass
@synthesize model;

- (void)trainSVM:(NSArray *)trainingSet withLabels:(NSArray *)labelsSet
{
    // Setting up inputs as C++ style arrays

    NSInteger obsCount = labelsSet.count;
    NSArray *firstObject = (NSArray *)trainingSet.firstObject;
    NSInteger featuresCount = firstObject.count;
    
    int labels[obsCount];  // Needs deallocating
    float trainingData[obsCount][featuresCount];  // Needs deallocating

    for (int i = 0; i < obsCount; i++) {
        labels[i] = [[labelsSet objectAtIndex:i] intValue];
    }
    for (int i = 0; i < obsCount; i++) {
        for (int j = 0; j < featuresCount; j++) {
            NSArray *ob = [trainingSet objectAtIndex:i];
            //NSLog(@"**** i = %d, j = %d", i, j);
            trainingData[i][j] = [[ob objectAtIndex:j] floatValue];
        }
    }

    // Setting up C++ inputs as OpenCV Mat types

    Mat trainingDataMat((int)obsCount, (int)featuresCount, CV_32FC1, trainingData);
    Mat labelsMat((int)obsCount, 1, CV_32SC1, labels);
     
    // Train the SVM
    
    self.model = ml::SVM::create();
    self.model->setType(ml::SVM::C_SVC);
    self.model->setKernel(ml::SVM::POLY);
    self.model->setDegree(2);
    self.model->setTermCriteria(TermCriteria(TermCriteria::MAX_ITER, 100, 1e-6));
    self.model->train(trainingDataMat, ml::ROW_SAMPLE, labelsMat);

    // Show support vectors
    
    /*
    Mat svv = self.model->getSupportVectors();
    NSLog(@"%d", svv.rows);
    for (int i = 0; i < svv.rows; ++i)
    {
        const float* v = svv.ptr<float>(i);
        NSLog(@"Vector!!! = %f, %f", v[0], v[1]);
    }
    */
}

- (void)dealloc
{
    delete [] self.model;
}

- (float)forecastLabel:(NSArray *)observation
{
    if (self.model != nil) {
        NSInteger featuresCount = [observation count];
        float dataArray[featuresCount];
        for (int i = 0; i < featuresCount; i++) {
            dataArray[i] = [[observation objectAtIndex:i] floatValue];
        }
        Mat data(1, featuresCount, CV_32FC1, dataArray);
        float output = self.model->predict(data);
        return output;
    } else {
        return 666.0;
    }
}

@end