//
//  BeaconMonitor.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

enum BeaconMonitorError: String, CustomStringConvertible {
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

protocol BeaconMonitorDelegate: class {
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon])
    func beaconMonitor(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError)
    func beaconMonitor(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError])
    func beaconMonitor(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError])
    func beaconMonitor(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType)
}

import Foundation
import CoreLocation
import CoreBluetooth

class BeaconMonitor: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    let uuid: String
    let requiredAuthorisation: BeaconMonitorAuthorisationType
    private var uuidPrivate: NSUUID?
    private var beaconRegion: CLBeaconRegion?
    private let locationManager: CLLocationManager
    private var bluetoothManager: CBCentralManager
    private var delegates: [Weak<AnyObject>] = []
    
    init?(UUID: String, authorisation: BeaconMonitorAuthorisationType) {
        self.locationManager = CLLocationManager()
        let options = [CBCentralManagerOptionShowPowerAlertKey: false]
        self.bluetoothManager = CBCentralManager()
        self.requiredAuthorisation = authorisation
        self.uuid = UUID
        if let id = NSUUID(UUIDString: UUID) {
            self.uuidPrivate = id
            self.beaconRegion = CLBeaconRegion(proximityUUID: id, identifier: "com.contextmobile.tagger")
            self.beaconRegion!.notifyEntryStateOnDisplay = true
            super.init()
            bluetoothManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: options)
        } else {
            print("UUID string supplied is not valid!")
            super.init()
            self.bluetoothManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue(), options: options)
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
            // DEBUG PRINTS:
            //println("OFF")
        }
        if bluetoothManager.state == .Resetting || bluetoothManager.state == .Unknown {
            returnValue.append(.BluetoothUpdating)
            // DEBUG PRINTS:
            //println("Unknown")
        }
        if bluetoothManager.state == .Unauthorized {
            returnValue.append(.BluetoothUnauthorized)
            // DEBUG PRINTS:
            //println("Unauthorized")
        }
        return returnValue
    }
    
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            self.callDelegates(self, didReceiveAuthorisation: .WhenInUse)
        case .AuthorizedAlways:
            self.callDelegates(self, didReceiveAuthorisation: .Always)
        default: print(status)
        }
        print("STATUS CHANGE")
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
        locationManager.stopRangingBeaconsInRegion(beaconRegion!)
        locationManager.stopMonitoringForRegion(beaconRegion!)
    }
    
    func start() {
        self.locationManager.delegate = self
        let errors = statusErrors()
        if errors.isEmpty {startMonitoring()}
        
        // TESTING MODE?  Use the following code as a template for generating CLBeacons if you need to test and do not have real beacons.  Copy and paste the code where relevant.
        /*
        let testMode = false
        var testBeacons: [CLBeacon] = []
        
        let beacon1 = CLBeacon()
        testBeacons.append(beacon1)
        testBeacons[0].setValue(NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e"), forKey: "proximityUUID")
        testBeacons[0].setValue(16985, forKey: "major")
        testBeacons[0].setValue(52643, forKey: "minor")
        testBeacons[0].setValue(0.5, forKey: "accuracy")
        
        if testMode {
            self.delegate.beaconMonitor(self, didFindCLBeacons: testBeacons)
        }
        */
    }
    
    func addDelegate(delegate: AnyObject) {
        self.delegates = self.delegates.filter({ $0.value != nil  })
        self.delegates.append(Weak(value: delegate))
    }
    
    private func callDelegates(monitor: BeaconMonitor, didFindBeacons beacons: [CLBeacon]) {
        let _ = self.delegates.map({ (delegate) in
            if let d = delegate.value as? BeaconMonitorDelegate {
                d.beaconMonitor(monitor, didFindCLBeacons: beacons)
            }
        })
    }
    
    private func callDelegates(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError) {
        let _ = self.delegates.map({ (delegate) in
            if let d = delegate.value as? BeaconMonitorDelegate {
                d.beaconMonitor(monitor, errorScanningBeacons: error)
            }
        })
    }
    
    private func callDelegates(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError]) {
        let _ = self.delegates.map({ (delegate) in
            if let d = delegate.value as? BeaconMonitorDelegate {
                d.beaconMonitor(monitor, didFindStatusErrors: errors)
            }
        })
    }
    
    private func callDelegates(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError]) {
        let _ = self.delegates.map({ (delegate) in
            if let d = delegate.value as? BeaconMonitorDelegate {
                d.beaconMonitor(monitor, didFindBLEErrors: errors)
            }
        })
    }
    
    private func callDelegates(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType) {
        let _ = self.delegates.map({ (delegate) in
            if let d = delegate.value as? BeaconMonitorDelegate {
                d.beaconMonitor(monitor, didReceiveAuthorisation: authorisation)
            }
        })
    }
    
    private func startMonitoring() {
        locationManager.startMonitoringForRegion(beaconRegion!)
        locationManager.startRangingBeaconsInRegion(beaconRegion!)
        print("Region monitor starting \(beaconRegion)")
    }
    
    // Unimplemented
    @objc func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Ranging beacons starting")
    }
    
    // Unimplemented
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError " + error.description)
    }
    
    // Unimplemented
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("monitoringDidFailForRegion " + error.description)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let bcs = beacons 
        if bcs.count > 0 {
            self.callDelegates(self, didFindBeacons: bcs)
        }
    }
    
    // BLUETOOTH CHANGE OF STATE
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        self.callDelegates(self, didFindBLEErrors: bleErrors())
    }
    
}

