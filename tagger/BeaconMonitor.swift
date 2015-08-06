//
//  BeaconMonitor.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

enum BeaconMonitorError: String, Printable {
    case BluetoothOff = "BluetoothOff"
    case BluetoothUpdating = "Bluetooth state is currently updating and therefore temporairliy unavailable"
    case BluetoothUnauthorized = "The app is not authorized to use Bluetooth low energy"
    case AuthorizationDenied = "Authorisation Denied By User"
    case AuthorizationNotAsked = "Authorisation Not Asked"
    case AuthorizationRestricted = "Authorisation Restricted"
    case LocationServicesOff = "Location Services Off"
    var description : String {get {return self.rawValue}}
}

enum BeaconMonitorAuthorisationType {
    case Always
    case WhenInUse
}

import Foundation
import CoreLocation
import CoreBluetooth

class BeaconMonitor: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    let uuid: String
    let delegate: BeaconMonitorDelegate
    let requiredAuthorisation: BeaconMonitorAuthorisationType
    var isScanning: Bool
    private var uuidPrivate: NSUUID?
    private var beaconRegion: CLBeaconRegion?
    private let locationManager: CLLocationManager
    private var bluetoothManager: CBCentralManager
    
    init?(delegate: BeaconMonitorDelegate, UUID: String, authorisation: BeaconMonitorAuthorisationType) {
        locationManager = CLLocationManager()
        let options = [CBCentralManagerOptionShowPowerAlertKey: false]
        bluetoothManager = CBCentralManager()
        self.delegate = delegate
        isScanning = false
        requiredAuthorisation = authorisation
        uuid = UUID
        if let id = NSUUID(UUIDString: UUID) {
            uuidPrivate = id
            beaconRegion = CLBeaconRegion(proximityUUID: id, identifier: "com.contextmobile.tagger")
            beaconRegion!.notifyEntryStateOnDisplay = true
            super.init()
            bluetoothManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: options)
        } else {
            println("UUID string supplied is not valid!")
            super.init()
            bluetoothManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: options)
            return nil
        }
    }
    
    func statusErrors() -> [BeaconMonitorError] {
        var returnValue: [BeaconMonitorError] = []
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            returnValue.append(.AuthorizationNotAsked)
        }
        if CLLocationManager.authorizationStatus() == .Denied {
            returnValue.append(.AuthorizationDenied)
        }
        if !CLLocationManager.locationServicesEnabled() {
            returnValue.append(.LocationServicesOff)
        }
        if CLLocationManager.authorizationStatus() == .Restricted {
            returnValue.append(.AuthorizationRestricted)
        }
        return returnValue
    }
    
    func bleErrors() -> [BeaconMonitorError] {
        var returnValue: [BeaconMonitorError] = []
        if bluetoothManager.state == .PoweredOff {
            returnValue.append(.BluetoothOff)
            //println("OFF")
        }
        if bluetoothManager.state == .Resetting || bluetoothManager.state == .Unknown {
            returnValue.append(.BluetoothUpdating)
            //println("Unknown")
        }
        if bluetoothManager.state == .Unauthorized {
            returnValue.append(.BluetoothUnauthorized)
            //println("Unauthorized")
        }
        return returnValue
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            delegate.beaconMonitor(self, didReceiveAuthorisation: .WhenInUse)
        case .AuthorizedAlways:
            delegate.beaconMonitor(self, didReceiveAuthorisation: .Always)
        default: println(status)
        }
        println("STATUS CHANGE")
    }
    
    func requireAuthorization(){
        if requiredAuthorisation == .WhenInUse {
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
                //println("requiring when in use auth")
            }
        } else if requiredAuthorisation == .Always {
            if locationManager.respondsToSelector("requestAlwaysAuthorization") {
                locationManager.requestAlwaysAuthorization()
                //println("requiring always auth")
            }
        }
    }
    
    func stop() {
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        locationManager.stopMonitoringForRegion(beaconRegion)
    }
    
    func start() {
        self.locationManager.delegate = self
        let errors = statusErrors()
        if errors.isEmpty {startMonitoring()}
        
        // TESTING MODE?
        /*
        let testMode = false
        var testBeacons: [CLBeacon] = []
        
        let beacon1 = CLBeacon()
        testBeacons.append(beacon1)
        testBeacons[0].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[0].setValue(16985, forKey: "major")
        testBeacons[0].setValue(52643, forKey: "minor")
        testBeacons[0].setValue(0.5, forKey: "accuracy")
        
        let beacon2 = CLBeacon()
        testBeacons.append(beacon2)
        testBeacons[1].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[1].setValue(60667, forKey: "major")
        testBeacons[1].setValue(31043, forKey: "minor")
        testBeacons[1].setValue(1, forKey: "accuracy")
        
        let beacon3 = CLBeacon()
        testBeacons.append(beacon3)
        testBeacons[2].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[2].setValue(57085, forKey: "major")
        testBeacons[2].setValue(15711, forKey: "minor")
        testBeacons[2].setValue(1, forKey: "accuracy")
        
        let beacon4 = CLBeacon()
        testBeacons.append(beacon4)
        testBeacons[3].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[3].setValue(58898, forKey: "major")
        testBeacons[3].setValue(46563, forKey: "minor")
        testBeacons[3].setValue(1, forKey: "accuracy")
        
        let beacon5 = CLBeacon()
        testBeacons.append(beacon5)
        testBeacons[4].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[4].setValue(16155, forKey: "major")
        testBeacons[4].setValue(55724, forKey: "minor")
        testBeacons[4].setValue(1, forKey: "accuracy")
        
        if testMode {
        self.delegate.beaconMonitor(self, didFindCLBeacons: testBeacons)
        }
        */
    }
    
    private func startMonitoring() {
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        println("Region monitor starting \(beaconRegion)")
    }
    
    private func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        //locationManager.startRangingBeaconsInRegion(beaconRegion)
        println("Ranging beacons starting")
    }
    
    // When does this happen?
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError " + error.description)
    }
    
    // When does this happen?
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("monitoringDidFailForRegion " + error.description)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        let bcs = beacons as! [CLBeacon]
        if bcs.count > 0 {
            self.delegate.beaconMonitor(self, didFindCLBeacons: bcs)
        }
    }
    
    // BLUETOOTH CHANGE OF STATE
    internal func centralManagerDidUpdateState(central: CBCentralManager!) {
        //if central.state != .PoweredOn {
       //     delegate.beaconMonitor(self, didFindStatusErrors: statusErrors())
       // }
        delegate.beaconMonitor(self, didFindBLEErrors: bleErrors())
    }
    
}


// Neeed to change protocol to return BOTH [CMBBeacon] and [CLBeacon]
protocol BeaconMonitorDelegate {
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon])
    func beaconMonitor(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError)
    func beaconMonitor(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError])
    func beaconMonitor(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError])
    func beaconMonitor(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType)
}