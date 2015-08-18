//
//  BeaconMatrix.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation

class BeaconMatrix {
    var beacons: [[Beacon]] = []
    private var limit = 0
    private let maLimit = 10
    
    required init?(beacons b:[Beacon], limit:Int = -1){
        if b.count > 0 && limit > 0 {
            b.map({ self.beacons.append([$0]) })
            self.limit = limit
        } else {
            return nil
        }
    }
    
    func count() -> Int {
        return beacons.first!.count
    }
    
    func addBeacons(beacons: [Beacon]) {
        if count() == limit { prune() }
        beacons.map({self.addBeacon($0)})
        func addNullBeaconIfObservationIsMissing(B:[Beacon], maxCount: Int) -> [Beacon] {
            var output = B
            if B.count < maxCount {
                var nullBeacon = Beacon(uuid: NSUUID(UUIDString: B.first!.uuid)!, major: B.first!.major, minor: B.first!.minor)
                nullBeacon.rssi = 0
                nullBeacon.accuracy = -1
                output.append(nullBeacon)
            }
            return output
        }
        let mc = maxCount()
        self.beacons = self.beacons.map({ addNullBeaconIfObservationIsMissing($0, mc) })
        // DELETE ME!
        //self.beacons.map({println($0.last!.major)})
    }
    
    private func addBeacon(beacon: Beacon) {
        func addBeaconIfMatching(b:Beacon, B:[Beacon]) -> [Beacon] {
            var output = B
            if let firstB = B.first {
                if b == firstB {
                    output.append(b)
                }
            }
            return output
        }
        self.beacons = self.beacons.map({ addBeaconIfMatching(beacon, $0) })
    }
    
    func row(row:Int) -> [Beacon]? {
        if row <= self.count() {
            return beacons.map({$0[row]})
        } else {
            return nil
        }
    }
    
    func column(beacon:Beacon) -> [Beacon]? {
        var temp = beacons.filter({ $0.first == beacon })
        //beacons.map( { $0.first == beacon ? temp.append($0) } )
        if temp.count > 0 {
            return temp.first
        } else {
            return nil
        }
    }
    
    func avgRSSI(beacon b:Beacon) -> Double {
        let beacs = beacons.filter({ $0.first! == b })
        if let beac = beacs.first {
            if beac.count > maLimit {
                let beaRev = beac.reverse()
                let beaSlice = beaRev[0...maLimit-1]
                return Double(beaSlice.reduce(0) {$0 + $1.rssi!}) / Double(maLimit)
            } else {
                return Double(beac.reduce(0) {$0 + $1.rssi!}) / Double(count())
            }
        } else {
            return 0.0
        }
    }
    
    func avgRSSI(row: Int) -> [Double]? {
        if let bcs = self.row(row) {
            return bcs.map { self.avgRSSI(beacon: $0) }
        } else {
            return nil
        }
    }
    
    // Change the formulas
    func varRSSI(beacon b:Beacon) -> Double {
        let beacs = beacons.filter({ $0.first! == b })
        if let beac = beacs.first {
            if beac.count > maLimit {
                let beaRev = beac.reverse()
                let beaSlice = beaRev[0...maLimit-1]
                return Double(beaSlice.reduce(0) {$0 + $1.rssi!}) / Double(maLimit)
            } else {
                return Double(beac.reduce(0) {$0 + $1.rssi!}) / Double(count())
            }
        } else {
            return 0.0
        }
    }
    
    // Change the formulas
    func accuracy(beacon b:Beacon) -> Double {
        let beacs = beacons.filter({ $0.first! == b })
        if let beac = beacs.first {
            if beac.count > maLimit {
                let beaRev = beac.reverse()
                let beaSlice = beaRev[0...maLimit-1]
                return Double(beaSlice.reduce(0) {$0 + $1.rssi!}) / Double(maLimit)
            } else {
                return Double(beac.reduce(0) {$0 + $1.rssi!}) / Double(count())
            }
        } else {
            return 0.0
        }
    }
    
    private func prune() {
        func removeFirstElement(e:[Beacon]) -> [Beacon] {
            var output = e
            output.removeAtIndex(0)
            return output
        }
        self.beacons.map({ removeFirstElement($0) })
    }
    
    private func maxCount() -> Int {
        if beacons.count > 0 {
            var output = 0
            for row in beacons {
                if row.count > output { output = row.count }
            }
            return output
        } else {
            return 0
        }
    }
    
}
