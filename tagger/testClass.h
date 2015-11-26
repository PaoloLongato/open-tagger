//
//  Example2.h
//  tagger
//
//  Created by Paolo Longato on 10/08/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

#ifndef tagger_Example2_h
#define tagger_Example2_h

#endif

#import <Foundation/Foundation.h>

@interface testClass: NSObject

- (void)trainSVM:(NSArray *)trainingSet withLabels:(NSArray *)labelsSet;
- (float)forecastLabel: (NSArray *)observation;

@end