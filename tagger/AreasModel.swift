//
//  AreasModel.swift
//  tagger
//
//  Created by Paolo Longato on 25/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation
import UIKit

class Areas: NSObject, NSCoding {
    var list:[Area] = []
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        if let l = decoder.decodeObjectForKey("list") as? [Area] {
            self.list = l
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.list, forKey: "list")
    }
    
    func save() -> Bool {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = docDirs.first! 
        let path = (docDir as NSString).stringByAppendingPathComponent("archive")
        let success = NSKeyedArchiver.archiveRootObject(list, toFile: path)
        return success
    }
    
    func load() {
        let docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = docDirs.first! 
        let path = (docDir as NSString).stringByAppendingPathComponent("archive")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "save", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        if let l = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [Area] {
            list = l
        }
    }
    
    func addArea() {
        var id = 1
        if list.count > 0 {
            id = list.last!.id + 1
        }
        list.append(Area(id: id))
    }
    
    func makeCopy() -> Areas {
        let copy = Areas()
        copy.list = self.list.map({ $0.makeCopy() })
        return copy
    }
    
    func safeSwapPositions(firstAreaPosition: Int, secondAreaPosition: Int) {
        if firstAreaPosition > 0 &&
            secondAreaPosition > 0 &&
            firstAreaPosition < self.list.count &&
            secondAreaPosition < self.list.count {
                let temp = self.list[secondAreaPosition]
                self.list[secondAreaPosition] = self.list[firstAreaPosition]
                self.list[firstAreaPosition] = temp
        }
    }
    
    func removeArea(id:Int) {
        list = list.filter {$0.id != id}
    }
    
    func area(id: Int) -> Area? {
        return list.filter {$0.id == id}.first
    }
    
    func data() -> ([[Double]], [Int]){
        let output = list.reduce( ([[Double]](), [Int]()) )
        {
            (acc, new) in
            var out = (acc.0,acc.1)
            out.0 = out.0 + new.data
            out.1 = out.1 + Array(count: new.data.count, repeatedValue: new.id)
            return out
        }
        return output
    }
}