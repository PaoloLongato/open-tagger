//
//  SecondViewController.swift
//  tagger
//
//  Created by Paolo Longato on 25/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import UIKit
import CoreLocation

class SecondViewController: UIViewController, AreasSecondaryStorage, BeaconMonitorDelegate {

    internal var areas = Areas()
    private var SVMModel = testClass()
    var beacons:BeaconMatrix!
    var labels:[String] = []
    var remoteBeacons = beaconDB()
    var monitor:BeaconMonitor?

    @IBOutlet weak var predictedAreaLabel: UILabel!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAreas:", name: "updateAreas", object: nil)
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAreas:", name: "updateAreas", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        beacons = BeaconMatrix(beacons: remoteBeacons.beacons, limit:10)
        if let m = BeaconMonitor(delegate: self, UUID: remoteBeacons.beacons.first!.uuid, authorisation: .Always){
            monitor = m
            let e = m.statusErrors()
            if !e.isEmpty {
                for v in e {
                    if v == .AuthorizationNotAsked {
                        m.requireAuthorization()
                    }
                    println(v.description)
                }
            } else {
                monitor?.start()
            }
        }
    }
    
    internal func updateAreas(notification: NSNotification) {
        if let n = notification.object as? FingerprintsTableViewController {
            areas = n.areas
            // DEBUG
            //areas.list.first!.fingerprints.list.first.map { println($0.data) }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func train(){
        let (trainingSet, labels) = areas.data()
        trainingSet.map( { println($0) } )
        println(labels)
        SVMModel.trainSVM(trainingSet, withLabels: labels)
    }
    
    func predict(){
        if beacons.count() > 0 {
            if let ob = beacons.avgRSSI(beacons.count() - 1) {
                //println(ob)
                predictedAreaLabel.text = "\(SVMModel.forecastLabel(ob))"
            }
        }
    }
    
    func predict2(){
        if beacons.count() > 0 {
            if let ob = beacons.accuracy(beacons.count() - 1) {
                println(ob)
                predictedAreaLabel.text = "\(SVMModel.forecastLabel(ob))"
            }
        }
    }

    @IBAction func onPressTrainButton() {
        train()
    }
    
    // BEACON MONITOR DELEGATE METHODS
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        //beacons.map({println($0.major)})
        var bcs:[Beacon] = []
        beacons.map({ bcs.append(Beacon(beacon: $0)) })
        self.beacons.addBeacons(bcs)
        //predict()
        predict2()
    }
    
    func beaconMonitor(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError){
        println(error)
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError]) {
        errors.map({println($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError]) {
        errors.map({println($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType) {
        println("Authorisation")
        monitor.start()
    }

    
}

