//
//  AreasModel.swift
//  tagger
//
//  Created by Paolo Longato on 25/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import Foundation

class Areas: NSObject {
    var list:[Area] = []
    
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
}