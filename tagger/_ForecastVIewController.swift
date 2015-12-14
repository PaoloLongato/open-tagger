//
//  SecondViewController.swift
//  tagger
//
//  Created by Paolo Longato on 25/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//
/*

import UIKit
import CoreLocation

class ForecastViewController: UIViewController, BeaconMonitorDelegate {

    var areas = Areas()
    var labels:[String] = []
    var remoteBeacons = beaconDB()
    var monitor:BeaconMonitor?
    var beacons: Reel<Beacon>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("firstTabActive", object: nil, queue: nil) { (notif) in
            guard (self.monitor != nil) else {
                return }
            self.monitor!.stop()
        }
        
        if let m = BeaconMonitor(UUID: remoteBeacons.beacons.first!.uuid, authorisation: .Always){
            monitor = m
            m.addDelegate(self)
            let e = m.statusErrors()
            if !e.isEmpty {
                for v in e {
                    if v == .AuthorizationNotAsked {
                        m.requireAuthorization()
                    }
                    print(v.description)
                }
            } else {
                monitor?.start()
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("secondTabActive", object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func train(){

    }
    


    @IBAction func onPressTrainButton() {
        
    }
    
    // BEACON MONITOR DELEGATE METHODS
    
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        //beacons.map({print($0.major)})
        guard (self.beacons != nil) else { return }
        let bcs = beacons.reduce([]) { $0 + [Beacon(beacon: $1)] }
        self.beacons = self.beacons!.pushMatchingElementsIn(bcs)
        let rssi: [[Double]] = self.beacons!.getItemsInAllQueues().reduce([]) { $0 + [$1.map({ Double($0.rssi) })] }.map( { Utility.entryFilter($0, threshold: 5) } )
        let avgRssi: [Double] = rssi.map( { Utility.average($0, ignoring: 0) } ).map({ if $0 == nil { return 0 } else { return $0! } })
        print(rssi)
        print(avgRssi)
        
        // Lookup code HERE
    }
    
    func beaconMonitor(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError){
        print(error)
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError]) {
        let _ = errors.map({print($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError]) {
        let _ = errors.map({print($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType) {
        print("Authorisation")
        monitor.start()
    }

    
}
*/
