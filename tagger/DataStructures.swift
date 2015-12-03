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

// MARK: PROTOCOLS
protocol WithEquivalence {
    func <=>(lhs: Self, rhs: Self) -> Bool
}

// MARK: OPERATORS
infix operator <=> { associativity none precedence 130 }