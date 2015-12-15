//
//  AreasTableTableViewController.swift
//  
//
//  Created by Paolo Longato on 25/07/2015.
//
//

import UIKit
import CoreLocation

class AreasTableViewController: UITableViewController, BeaconMonitorDelegate {

    var areas = Areas()
    var labels:[String] = []
    var remoteBeacons = beaconDB()
    var selectedCell = -1
    var selectedCellIndexPath:NSIndexPath?
    var beacons: Reel<Beacon>?
    var monitor:BeaconMonitor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName("secondTabActive", object: nil, queue: nil) { (notif) in
            guard (self.monitor != nil) else {
                return }
            self.monitor!.stop()
        }
        self.areas.load()
        self.beacons = Reel(elements: self.remoteBeacons.beacons, limit: 5, nullValue: nullBeacon())
        if let m = BeaconMonitor(UUID: remoteBeacons.beacons.first!.uuid, authorisation: .Always){
            m.addDelegate(self)
            monitor = m
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
        NSNotificationCenter.defaultCenter().postNotificationName("firstTabActive", object: nil)
        monitor?.start()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("firstTabInactive", object: self.areas.makeCopy())
        super.viewDidDisappear(animated)
        // DEBUG PRINTS:
        //print(areas.data())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "secondTabActive", object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return areas.list.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            areas.list.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            print("Invalid editing style")
        }
    }

    @IBAction func addArea() {
        areas.addArea()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AreasCellView", forIndexPath: indexPath) as! AreasCellView
        // Configure the cell...
        cell.icon.image = areas.list[indexPath.row].picture
        cell.desc.text = areas.list[indexPath.row].name
        cell.editButton.tag = indexPath.row
        cell.tag = indexPath.row
        return cell
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    // MARK: - Unimplemented table view editing methods
    // At the moment the only supported tavle view editing is "swipe left" to delete a cell / area
        
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editArea" {
            let index = sender!.tag
            let VC = segue.destinationViewController as! EditAreaViewController
            VC.area = areas.list[index]
            VC.updateTable = reloadTable
        }
    }
    
    // MARK: - BEACON MONITOR DELEGATE METHODS
    
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        
        // Process ans store raw RSSI data:
        // CLBeacons are "translated" into pure Swift Beacon objects
        // Push beacons in the appropriate queues. If 4 or fewer a beacon readings are missing or their RSSI == 0 (Apple calculations gone wrong), then:
        // the latest available Beacon reading are used to fill such missing value.  Else:
        // a "null Beacon" placeholder is used.
        // Beacons data are then stored only if there is an area "label" associated to it (i.e. the user has selected a cell and is therefore "fingerprinting an area")
        
        guard (self.beacons != nil) else { return }
        let bcs = beacons.reduce([]) { $0 + [Beacon(beacon: $1)] }
        self.beacons = self.beacons!.pushMatchingElementsIn(bcs)
        let avgRssi: [Double] = Utility.filterRssi(self.beacons!.getItemsInAllQueues())
        var relativeRssi: [Double] = [] //= Histogram(data: avgRssi)?.distribution()
        if let rr = Histogram(data: avgRssi)?.distribution() {
            relativeRssi = rr
        }
        
        if selectedCell > -1 && relativeRssi.count > 0 {
            self.areas.list[selectedCell].data.append(relativeRssi)
        }

        // DEBUG PRINTS:
        //beacons.map({print($0.major)})
        //print(avgRssi)
        //print(relativeRssi)
        //print(selectedCell)
        
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
    
    // MARK: - TABLE VIEW DELEGATE METHODS
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // DEBUG PRINTS:
        //print("DESELECTED")
        selectedCell = -1
        selectedCellIndexPath = nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // DEBUG PRINTS:
        //print("DID SELECT")
        selectedCell = indexPath.row
        selectedCellIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // DEBUG PRINTS:
        //print("WILL DESELECT")
        return indexPath
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.selected == true {
            tableView.delegate?.tableView!(tableView, willDeselectRowAtIndexPath: indexPath)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            tableView.delegate?.tableView!(tableView, didDeselectRowAtIndexPath: indexPath)
            return nil
        }
        return indexPath
    }

}
