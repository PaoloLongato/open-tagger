//
//  BeaconMatrix.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

/*
import Foundation

class BeaconMatrix {
    var beacons: [[Beacon]] = []
    private var limit = 6
    private let maLimit = 5
    
    required init?(beacons b:[Beacon], limit:Int){
        if b.count > 0 && limit > maLimit {
            _ = b.map({ self.beacons.append([$0]) })
            self.limit = limit
        } else {
            return nil
        }
    }
    
    func count() -> Int {
        return beacons.first!.count
    }
    
    // MARK: - Add beacons to matrix
    
    // Public API
    func addBeacons(beacons: [Beacon]) {
        if count() == limit { prune() }
        _ = beacons.map({self.addOneBeacon($0)})
        func addNullBeaconIfObservationIsMissing(B:[Beacon], maxCount: Int) -> [Beacon] {
            var output = B
            if B.count < maxCount && B.count > 0 {
                let nullBeacon = Beacon(uuid: NSUUID(UUIDString: B.first!.uuid)!, major: B.first!.major, minor: B.first!.minor)
                nullBeacon.rssi = 0
                nullBeacon.accuracy = -1
                output.append(nullBeacon)
            }
            return output
        }
        let mc = maxCount()
        self.beacons = self.beacons.map({ addNullBeaconIfObservationIsMissing($0, maxCount: mc) })
    }
    
    // Add a single beacon to the matrix.  After this operation you will have size mismatch in the columns.
    private func addOneBeacon(beacon: Beacon) {
        func addBeaconIfMatching(b:Beacon, to B:[Beacon]) -> [Beacon] {
            var output = B
            if let firstB = B.first {
                if b == firstB {
                    output.append(b)
                }
            }
            return output
        }
        self.beacons = self.beacons.map({ addBeaconIfMatching(beacon, to: $0) })
    }
    
    // Reduces the size of the matrix.  Should be used temporairily while adding beacons.
    private func prune() {
        func removeFirstElement(e:[Beacon]) -> [Beacon] {
            var output = e
            output.removeAtIndex(0)
            return output
        }
        _ = beacons.map({ removeFirstElement($0) })
    }
    
    // maxCount is used after parttial Beacon insertion. This is used to check if a colums is too short and therefore requires a null beacon element
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

    
    // MARK: Extract information from matrix
    
    // Extract single row = all beacons info logged at the same time
    func row(row:Int) -> [Beacon]? {
        if row <= self.count() && row > -1 {
            return beacons.map({$0[row]})
        } else {
            return nil
        }
    }

    // Extract a single column = history of a beacon.  This function assumes that there are no duplicates.
    func column(beacon:Beacon) -> [Beacon]? {
        if self.count() > 0 {
        let temp = beacons.filter({ $0.first == beacon })
            if temp.count > 0 {
                return temp.first
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func countMissingsInColumn(beacon: Beacon) -> Int? {
        return column(beacon)?.reduce(0, combine: { (acc, new) in return acc! + new.rssi } )
    }
    
    func lagColumn(beacon: Beacon) -> [Beacon]? {
        var col = column(beacon)
        _ = col?.removeAtIndex(0)
        return col
    }
    
    private func fillMissingsInColumn(beacon: Beacon) -> [Beacon]? {
        var lagCol = lagColumn(beacon)?.reverse()
        var col = column(beacon)?.reverse()
        var output = zip(lagCol, col)
        return column(beacon)?.map { if $0.isNull { r } else {return $0} }
    }
    
    // Very dirty way to get rid of accuracy missing values
    func accuracy(row:Int) -> [Double]? {
        if let bcs = self.row(row) {
            let acc = bcs.map({$0.accuracy})
            let output = acc.map( { (accuracy) -> Double in
                if let a = accuracy {
                    return a
                } else {
                    return 20.0
                }})
            return output
        } else {
            return nil
        }
    }
    
    func avgRSSI(beacon b:Beacon) -> Double {
        let beacs = beacons.filter({ $0.first! == b })
        if let beac = beacs.first {
            if beac.count > maLimit {
                let beaRev = Array(beac.reverse())
                let beaSlice = beaRev[0...maLimit-1]
                return Double(beaSlice.reduce(0) {$0 + $1.rssi}) / Double(maLimit)
            } else {
                return Double(beac.reduce(0) {$0 + $1.rssi}) / Double(count())
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
    
    // Change the formulas!!!
    func varRSSI(beacon b:Beacon) -> Double {
        let beacs = beacons.filter({ $0.first! == b })
        if let beac = beacs.first {
            if beac.count > maLimit {
                let beaRev = Array(beac.reverse())
                let beaSlice = beaRev[0...maLimit-1]
                return Double(beaSlice.reduce(0) {$0 + $1.rssi}) / Double(maLimit)
            } else {
                return Double(beac.reduce(0) {$0 + $1.rssi}) / Double(count())
            }
        } else {
            return 0.0
        }
    }
    
    
}

*/
