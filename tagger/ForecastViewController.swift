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
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("firstTabActive", object: nil, queue: nil) { (notif) in
            guard (self.monitor != nil) else { return }
            self.monitor!.stop()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("firstTabInactive", object: nil, queue: nil) { (notif) in
            print("********")
            print(notif.object)
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
    
    
    // BEACON MONITOR DELEGATE METHODS
    
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        //beacons.map({print($0.major)})
        guard (self.beacons != nil) else { return }
        let bcs = beacons.reduce([]) { $0 + [Beacon(beacon: $1)] }
        self.beacons = self.beacons!.pushMatchingElementsIn(bcs)
        //let rssi: [[Double]] = self.beacons!.getItemsInAllQueues().reduce([]) { $0 + [$1.map({ Double($0.rssi) })] }.map( { Utility.entryFilter($0, threshold: 5) } )
        //let avgRssi: [Double] = rssi.map( { Utility.average($0, ignoring: 0) } ).map({ if $0 == nil { return -95 } else { return $0! } })
        //let maxRssi: Double = avgRssi.maxElement()!  // check here!!!
        //let relativeRssi: [Double] = avgRssi.map({ $0 / maxRssi })
        let avgRssi: [Double] = Utility.filterRssi(self.beacons!.getItemsInAllQueues())
        var relativeRssi: [Double] = [] //= Histogram(data: avgRssi)?.distribution()
        if let rr = Histogram(data: avgRssi)?.distribution() {
            relativeRssi = rr
            self.currentFingerprint = rr
        }
        //print(rssi)
        //print(avgRssi)
        //print(relativeRssi)
        
        // Lookup code HERE
        let data = self.areas.data()
        print(data)
        let labels = data.1
        let fingerprints = data.0
        let rawForecasts = Utility.areaForecasts(relativeRssi, labels: labels, arraysDatabase: fingerprints)
        print(rawForecasts.first)
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