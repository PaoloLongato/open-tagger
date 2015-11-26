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
    var foo : NSString = "test"
    
    override init() {
        println("INIT")
        super.init()
    }
    
    required convenience init(coder decoder: NSCoder) {
        println("INIT WITH CODER")
        self.init()
        if let l = decoder.decodeObjectForKey("list") as? [Area] {
            self.list = l
            //for index in 0..<list.count {
            //    if let obj = decoder.decodeObjectForKey(String(index)) as? Area {
            //        list[index] = obj
            //    }
            //}
        }
        //self.foo = decoder.decodeObjectForKey("foo") as! NSString
    }
    
    func encodeWithCoder(coder: NSCoder) {
        println("ENCODE LIST")
        coder.encodeObject(self.list, forKey: "list")
        //coder.encodeObject(foo, forKey: "foo")
       // for index in 0..<list.count {
       //     coder.encodeObject(list[index], forKey: String(index))
       // }
    }
    
    func save() -> Bool {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        var docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docDir = docDirs.first! as! String
        var path = docDir.stringByAppendingPathComponent("archive")
        println(path)
        //let foo =  NSKeyedArchiver.archiveRootObject(self.foo, toFile: path)
        //println(foo)
        //return foo
        let success = NSKeyedArchiver.archiveRootObject(list, toFile: path)
        println(success)
        return success
    }
    
    func load() {
        println("LOAD")
        var docDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docDir = docDirs.first! as! String
        var path = docDir.stringByAppendingPathComponent("archive")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "save", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        if let l = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [Area] {
            println("ARCHIVE FETCHED")
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
    
    func removeArea(id:Int) {
        list = list.filter {$0.id != id}
    }
    
    func data() -> ([[Double]], [Int]){
        var labels:[Int] = []
        var data:[[Double]] = []
        var output = list.reduce( ([[Double]](), [Int]()) )
        {
            (acc, new) in
            var out = (acc.0,acc.1)
            let newFPData = new.fingerprintsAggregateData()
            out.0 = out.0 + newFPData
            out.1 = out.1 + Array(count: newFPData.count, repeatedValue: new.id)
            return out
        }
        return output
    }
}