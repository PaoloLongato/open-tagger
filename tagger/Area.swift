//
//  Area.swift
//  tagger
//
//  Created by Paolo Longato on 25/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class Area: NSObject {
    var name:String = "Please name this area"
    var des:String = "Please provide a description for this area"
    var picture:UIImage = makeDefaultPicture()
    let id:Int
    var fingerprints = Areas()
    var data:[[Double]] = []
    
    init(id:Int) {
        self.id = id
        super.init()
    }
    
    func fingerprintsAggregateData() -> [[Double]] {
        return fingerprints.list.reduce([]) { $0+$1.data }
    }
}

private func makeDefaultPicture() -> UIImage {
    let rectangle = CGRectMake(0, 0, 180, 180)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 180, height: 180), false, 0)
    let context = UIGraphicsGetCurrentContext()
    let R = CGFloat(arc4random_uniform(256)) / 256
    let G = CGFloat(arc4random_uniform(256)) / 256
    let B = CGFloat(arc4random_uniform(256)) / 256
    CGContextSetRGBFillColor(context, R, G, B, 1.0)
    CGContextSetRGBStrokeColor(context, R, G, B, 1.0)
    CGContextFillRect(context, rectangle)
    CGContextStrokeRect(context, rectangle)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}