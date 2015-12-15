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
        
        // List ALL of the beacons (associated to the area you want to map) here.
        // The proximity UUID string provided below corresponds to the standard Kontakt beacons that I have used for testing.
        // If you have other brands or you had your proximity UUID customized, change accordingly.
        // Majors and Minors are entirely dependent on the sepcific beacons you have and your beacons security settings (e.g. "temporary" major and minor values)
        // IMPORTANT: in a deployment sutuation, this list will be updated very frequently from your back end AND will match the beacons that you have actually deployed.
        // IMPORTANT: you can choose to list ALL of your beacons here, the algorithm should work regardless.
        // IMPORTANT: at the very least, list here all the beacons related to a specific deployment.  After that you cannot add or remove beacons without impacting performance.
        // IMPORTANT: you can modify a physical deployemnt with limited re-fingerprinting but that depends on the specific layout of the areas.
        
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