//
//  Utility.swift
//  tagger
//
//  Created by Paolo Longato on 21/08/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation

struct utility {

    func maFilter(observations: [Double], periods: Int) -> Double? {
        let count = observations.count
        if count >= periods {
            return observations.reduce(0) { $0 + $1 } / Double(count)
        } else {
            return nil
        }
    }
    
    func average(observations: [Double]) -> Double? {
        if observations.count > 0 {
            return observations.reduce(0) { $0 + $1 } / Double(observations.count)
        } else {
            return nil
        }
    }
    
    func stdev(observations: [Double]) -> Double? {
        if let avg = average(observations) {
            let squares = observations.map({ ($0 - avg) * ($0 - avg) })
            if let meanSquares = average(squares) {
                return sqrt(meanSquares)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func stdevFilter(observations: [Double], previousClean: Double, tolerance: Double) -> Double? {
        if observations.count > 1 {
            var obs = observations
            obs.removeAtIndex(obs.count - 1)
            if let std = stdev(obs),
                let avg = average(obs),
                let last = observations.last {
                    print(last < avg + tolerance * std)
                    print(last > avg - tolerance * std)
                    print(last < avg + tolerance * std && last > avg - tolerance * std)
                    print(last)
                    if last < avg + tolerance * std && last > avg - tolerance * std {
                        return observations.last
                    } else {
                        return previousClean
                    }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func fillMissingWithLast(observations: [Double]) -> [Double] {
        let count = observations.count
        if count > 0 {
            var obsLag = observations
            obsLag.removeLast()
            var obs = observations
            obs.removeAtIndex(0)
            let couples = Array(zip(obs, obsLag))
            let output = couples.reduce([]) {
                if $1.0 == 0 {
                    return Array($0) + [$1.1]
                } else {
                    return Array($0) + [$1.0]
                }
            }
            return [observations.first!] + (output as! [Double])
        } else {
            return observations
        }
    }
    
    
    
}