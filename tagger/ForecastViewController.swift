import UIKit
import CoreLocation

class ForecastViewController: UIViewController, BeaconMonitorDelegate {
    
    var areas = Areas()
    var labels:[String] = []
    var remoteBeacons = beaconDB()
    var monitor:BeaconMonitor?
    var beacons: Reel<Beacon>?
    var currentFingerprint: [Double] = []
    var currentForecast: Int?
    
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var area1: UILabel!
    @IBOutlet weak var area2: UILabel!
    @IBOutlet weak var area3: UILabel!
    
    @IBOutlet weak var dist1: UILabel!
    @IBOutlet weak var dist2: UILabel!
    @IBOutlet weak var dist3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName("firstTabActive", object: nil, queue: nil) { (notif) in
            guard (self.monitor != nil) else { return }
            self.monitor!.stop()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("firstTabInactive", object: nil, queue: nil) { (notif) in
            if let sender = notif.object as? Areas {
                self.areas = sender
            }
        }
        
        self.beacons = Reel(elements: self.remoteBeacons.beacons, limit: 5, nullValue: nullBeacon())
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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("secondTabActive", object: nil)
        monitor?.start()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "firstTabActive", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "firstTabInactive", object: nil)
    }
    
    
    // MARK: - BEACON MONITOR DELEGATE METHODS
    
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        
        // Process raw RSSI data:
        // CLBeacons are "translated" into pure Swift Beacon objects
        // Push beacons in the appropriate queues. If 4 or fewer a beacon readings are missing or their RSSI == 0 (Apple calculations gone wrong), then:
        // the latest available Beacon reading are used to fill such missing value.  Else:
        // a "null Beacon" placeholder is used.
        // Beacons data are then filtered.  5 seconds moving average is calculated. There needs to be at least 5 good Beacon readings (after missing values have been handled)
        // RSSI array is extracted and turned into a "probability" distribution (relative RSSI).  This should guarantee "device independency" to a reasonable level.
        // Such RSSI is compared with previously stored fingerprints and closest match extracted.  Nearest Neighbour approach.
       
        guard (self.beacons != nil) else { return }
        let bcs = beacons.reduce([]) { $0 + [Beacon(beacon: $1)] }
        self.beacons = self.beacons!.pushMatchingElementsIn(bcs)
        let avgRssi: [Double] = Utility.filterRssi(self.beacons!.getItemsInAllQueues())
        var relativeRssi: [Double] = []
        if let rr = Histogram(data: avgRssi)?.distribution() {
            relativeRssi = rr
            self.currentFingerprint = rr
        }
        
        let data = self.areas.data()
        let labels = data.1
        let fingerprints = data.0
        let rawForecasts = Utility.areaForecasts(relativeRssi, labels: labels, arraysDatabase: fingerprints)
        
        if let forecast = rawForecasts.first {
            self.currentForecast = forecast.0
            if let img = self.areas.area(forecast.0)?.picture {
                self.currentImage.image = img
            }
            self.area1.text = String(forecast.0)
            self.dist1.text = String(forecast.1)
        }
        
        if rawForecasts.count > 1 {
            self.area2.text = String(rawForecasts[1].0)
            self.dist2.text = String(rawForecasts[1].1)
        }
        
        if rawForecasts.count > 2 {
            self.area3.text = String(rawForecasts[2].0)
            self.dist3.text = String(rawForecasts[2].1)
        }
        
        // DEBUG PRINTS:
        //beacons.map({print($0.major)})
        //print(avgRssi)
        //print(relativeRssi)
        //print(data)
        //print(rawForecasts.first)
        
    }
    
    func beaconMonitor(monitor: BeaconMonitor, errorScanningBeacons error: BeaconMonitorError){
        // Unimplemented error handling
        // DEBUG PRINTS:
        print(error)
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindStatusErrors errors: [BeaconMonitorError]) {
        // Unimplemented error handling
        // DEBUG PRINTS:
        let _ = errors.map({print($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didFindBLEErrors errors: [BeaconMonitorError]) {
        // Unimplemented error handling
        // DEBUG PRINTS:
        let _ = errors.map({print($0)})
    }
    
    func beaconMonitor(monitor: BeaconMonitor, didReceiveAuthorisation authorisation: BeaconMonitorAuthorisationType) {
        // DEBUG PRINTS:
        //print("Authorisation received")
        monitor.start()
    }
    
    
}