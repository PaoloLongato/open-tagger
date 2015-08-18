//
//  BeaconDB.swift
//  tagger
//
//  Created by Paolo Longato on 29/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation

class beaconDB: NSObject {
    var beacons: [Beacon] = []

    override init(){
        
        let uuidString = "f7826da6-4fa2-4e98-8024-bc5b71e0893e"
        var major:[Int] = []; var minor:[Int] = []
        major.append(11254); minor.append(11380)
        major.append(12190); minor.append(21823)
        major.append(16985); minor.append(52643)
        major.append(23965); minor.append(61656)
        major.append(31725); minor.append(20567)
        major.append(60607); minor.append(51730)
        
        for (var i = 0; i < 6; i++){
            beacons.append(Beacon(uuid: NSUUID(UUIDString: uuidString)!, major: major[i], minor: minor[i]))
        }
        
        super.init()
    }
}