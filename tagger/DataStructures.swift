//
//  DataStructures.swift
//  tagger
//
//  Created by Paolo Longato on 27/11/2015.
//  Copyright © 2015 Paolo Longato. All rights reserved.
//

import Foundation

// MARK: Reel

struct Reel<T: WithEquivalence> {
    let limit: Int
    let items: [HomogeneousQueue<T>]
    let nullValue: T
    
    init?(elements e:[T], limit:Int, nullValue: T){
        if e.count > 0 && limit > 0 {
            self.limit = limit
            self.items = e.map({ HomogeneousQueue(elements: [$0], nullValue: nullValue, header: $0)! })
            self.nullValue = nullValue
        } else {
            return nil
        }
    }
    
    init?(items i:[HomogeneousQueue<T>], limit:Int, nullValue: T){
        if i.count > 0 && limit > 0 {
            let constant = i.first!.count
            if (i.map({ $0.count }).reduce(true) { $0 && $1 == constant }) {
                self.limit = limit
                self.items = i
                self.nullValue = nullValue
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func pushMatchingElementsIn(e: [T]) -> Reel? {
        if e.count > 0 {
            var count = self.items.first!.count + 1
            var itemsMutableCopy = self.items
            if count > self.limit {
                itemsMutableCopy = itemsMutableCopy.map({ $0.dequeue() })
                count = self.limit
            }
            let _ = e.map({ (candidate) in
                itemsMutableCopy.enumerate().map({ (index, _) in
                    if let positivePushResult = itemsMutableCopy[index].enqueue(candidate) {
                        itemsMutableCopy[index] = positivePushResult
                    }
                })
            })
            itemsMutableCopy = itemsMutableCopy.map({ (queue) in
                if queue.count < count {
                    return queue.enqueueNullValue()!
                } else {
                    return queue
                }
            })
            return Reel(items: itemsMutableCopy, limit: self.limit, nullValue: self.nullValue)
        } else {
            return nil
        }
    }
    
    func getItemsInQueueMatchingElement(e: T) -> [T]? {
        if let returnValue = self.items.map({ $0.getArray(forHeader: e) }).first {
            return returnValue
        } else {
            return nil
        }
    }
    
    func getItemsInAllQueues() -> [[T]] {
        return self.items.reduce([]) { $0 + [$1.items] }
    }
    
}

// MARK: Homegeneus Queue

struct HomogeneousQueue<T: WithEquivalence> {
    
    let items: [T]
    let header: T
    let nullValue: T
    var count: Int { get { return items.count } }
    
    init?(elements e: [T], nullValue: T, header: T) {
        if e.count > 0 {
            self.items = e
            self.nullValue = nullValue
            self.header = header
        } else {
            return nil
        }
    }
    
    func enqueue(item: T) -> HomogeneousQueue? {
        if item <=> self.header {
            let newItems = self.items + [item]
            return HomogeneousQueue(elements: newItems, nullValue: self.nullValue, header: self.header)!
        } else {
            return nil
        }
    }
    
    func enqueueNullValue() -> HomogeneousQueue? {
        let newItems = self.items + [self.nullValue]
        return HomogeneousQueue(elements: newItems, nullValue: self.nullValue, header: self.header)!
    }
    
    func dequeue() -> HomogeneousQueue {
        if self.items.count > 1 {
            var newItems = self.items
            newItems.removeAtIndex(0)
            return HomogeneousQueue(elements: newItems, nullValue: self.nullValue, header: self.header)!
        } else {
            return self
        }
        
    }
    
    func getArray(forHeader h: T) -> [T]? {
        if h <=> self.header {
            return self.items
        } else {
            return nil
        }
    }
    
}

// MARK: Weak container

class Weak<T: AnyObject> {
    weak var value:T?
    init(value: T) {
        self.value = value
    }
}

// MARK: Histogram

struct Histogram {
    
    private let elements: [Double]
    private var cumulative: [Double]?
    
    init?(data:[Double]) {
        guard data.count > 0 else { return nil }
        let tempElements = Histogram.normalize(Histogram.shift(data))
        guard tempElements.reduce(false, combine: { $0 || $1 > 0.0 }) else { return nil }
        self.elements = tempElements
    }
    
    // MARK: Helper functitons
    
    private static func normalize(histogram: [Double]) -> [Double] {
        let sum = histogram.reduce(0) { $0 + $1 }
        return histogram.map({ $0 / sum })
    }
    
    private static func normalizeWithIndices(histogram: [(label:Int, value:Double)]) -> [(label:Int, value:Double)] {
        let sum = histogram.reduce(0) { $0 + $1.value }
        return histogram.map({ ($0.label, $0.value / sum) })
    }
    
    private static func shift(histogram: [Double]) -> [Double] {
        return histogram.map({ $0 + 95.0 })
    }
    
    private func meanWithIndices(histogram: [(label:Int, value:Double)]) -> Double {
        return histogram.reduce(0.0) { $0 + $1.value * Double($1.label) }
    }
    
    // MARK: Public functions
    
    func max() -> Double {
        return self.elements.reduce(self.elements.first!) { if $1 > $0 { return $1 } else { return $0 } }
    }
    
    func argMax() -> Int {
        return self.elements.indexOf(self.max())!
    }
    
    func argMin() -> Int {
        return Histogram(data: self.elements.map { -$0 })!.argMax()
    }
    
    func mean() -> Double {
        return meanWithIndices(Array(self.elements.enumerate()))
    }
    
    func variance() -> Double {
        let m = self.mean()
        return self.elements.enumerate().reduce(0.0) { $0 + (Double($1.index) - m) * (Double($1.index) - m) * $1.element }
    }
    
    func stDev() -> Double {
        return sqrt(self.variance())
    }
    
    func cv() -> Double {
        return self.stDev() / self.mean()
    }
    
    func inverseCv() -> Double {
        return self.mean() / self.stDev()
    }
    
    func distribution() -> [Double] {
        return self.elements
    }
    
    mutating func cumulativeDistribution() -> [Double] {
        if let _ = self.cumulative {
            return self.cumulative!
        } else {
            var cumulative: [Double] = []
            var sum = 0.0
            for value in self.elements {
                sum += value
                cumulative.append(sum)
            }
            self.cumulative = cumulative
            return cumulative
        }
    }
    
    mutating func percentile(percentile: Double) -> Double {
        let high = self.cumulativeDistribution().enumerate().reduce((0, self.cumulativeDistribution().first!)) { if $1.element < percentile { return $1 } else { return $0 } }
        let low = self.cumulativeDistribution().enumerate().reverse().reduce((0, self.cumulativeDistribution().first!)) { if $1.element > percentile { return $1 } else { return $0 } }
        let p1 = self.elements[high.0]
        let p2 = self.elements[low.0]
        return (Double(high.0) * p1 + Double(low.0) * p2) / (p1 + p2)
    }
    
    mutating func percentiles() -> [(percentile: Double, value: Double)] {
        let labels = [0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95]
        return Array(zip(labels, labels.map({ self.percentile($0) })))
    }
    
}

// MARK: PROTOCOLS

protocol WithEquivalence {
    func <=>(lhs: Self, rhs: Self) -> Bool
}

protocol AreasSecondaryStorage {
    var areas:Areas { get }
    func updateAreas(notification:NSNotification)
}

// MARK: OPERATORS

infix operator <=> { associativity none precedence 130 }