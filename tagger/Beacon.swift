//
//  Beacon.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation
import CoreLocation

class Beacon: NSObject, Equatable {
    let uuid:String
    let major:Int
    let minor:Int
    let timestamp:NSDate = NSDate()
    var rssi: Int?
    var accuracy: Double?
    
    required init(uuid: NSUUID, major:Int, minor:Int) {
        self.uuid = uuid.UUIDString
        self.major = major
        self.minor = minor
        self.rssi = 0
        self.accuracy = -1
        super.init()
    }
    
    required convenience init(beacon: CLBeacon) {
        self.init(uuid: beacon.proximityUUID, major: Int(beacon.major), minor: Int(beacon.minor))
        self.rssi = beacon.rssi
        self.accuracy = beacon.accuracy
    }
    
}

func ==(lhs: Beacon, rhs: Beacon) -> Bool{
    return lhs.uuid == rhs.uuid && lhs.minor == rhs.minor && lhs.major == rhs.major
}
