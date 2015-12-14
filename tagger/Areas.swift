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

class Area: NSObject, NSCoding {
    var name:String = "Please name this area"
    var des:String = "Please provide a description for this area"
    var picture:UIImage = makeDefaultPicture()
    var id:Int
    var fingerprints:[[Double]] = []
    
    init(id:Int) {
        self.id = id
        super.init()
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init(id: 0)
        ///*
        self.name = decoder.decodeObjectForKey("name") as! String
        self.des = decoder.decodeObjectForKey("des") as! String
        self.picture = decoder.decodeObjectForKey("picture") as! UIImage
        self.id = decoder.decodeIntegerForKey("id")
        self.fingerprints = decoder.decodeObjectForKey("fingerprints") as! [[Double]]
        //*/
        print("Decode one area")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        ///*
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(des, forKey: "des")
        coder.encodeObject(picture, forKey: "picture")
        coder.encodeInteger(id, forKey: "id")
        coder.encodeObject(fingerprints, forKey: "fingerprints")
        //*/
        print("Encode one area")
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