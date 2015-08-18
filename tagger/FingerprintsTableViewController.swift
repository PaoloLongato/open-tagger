//
//  FingerprintsTableViewController.swift
//  tagger
//
//  Created by Paolo Longato on 28/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import UIKit
import CoreLocation

class FingerprintsTableViewController: UITableViewController, UITableViewDelegate, BeaconMonitorDelegate {

    var area:Area!
    var areas:Areas!
    var beacons:BeaconMatrix!
    var labels:[String] = []
    var remoteBeacons = beaconDB()
    var monitor:BeaconMonitor?
    var selectedCell = -1
    var selectedCellIndexPath:NSIndexPath?
    @IBOutlet weak var naviItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        beacons = BeaconMatrix(beacons: remoteBeacons.beacons, limit:30)
        labels.append("\(selectedCell)")
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        naviItem.prompt = area.name
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return area.fingerprints.list.count
    }

    @IBAction func addArea() {
        if selectedCell == -1 {
            area.fingerprints.addArea()
            area.fingerprints.list.last?.name = "\(area.id)_\(area.fingerprints.list.last!.id)"
            tableView.reloadData()
        }
    }
    
    @IBAction func dismissView() {
        monitor?.stop()
        // DEBUG
        //area.fingerprints.list.first.map { println($0.data) }
        NSNotificationCenter.defaultCenter().postNotificationName("updateAreas", object: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func resetData(sender:UIButton) {
        if selectedCell > -1 {
            area.fingerprints.list[sender.tag].data = []
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FingerprintsCellView", forIndexPath: indexPath) as! FingerprintsCellView
        // Configure the cell...
        cell.des.text = area.fingerprints.list[indexPath.row].name
        cell.resetButton.tag = indexPath.row
        cell.dataPointsNumber.text = "\(area.fingerprints.list[indexPath.row].data.count)"
        return cell
    }

    func reloadTable() {
        tableView.reloadData()
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // BEACON MONITOR DELEGATE METHODS
    func beaconMonitor(monitor: BeaconMonitor, didFindCLBeacons beacons: [CLBeacon]){
        //beacons.map({println($0.major)})
        var bcs:[Beacon] = []
        beacons.map({ bcs.append(Beacon(beacon: $0)) })
        self.beacons.addBeacons(bcs)
        if selectedCell > -1 {
            self.area.fingerprints.list[selectedCell].data.append( self.beacons.beacons.map({Double($0.last!.rssi!)}) )
            if let path = selectedCellIndexPath {
                let cell = tableView.cellForRowAtIndexPath(path) as! FingerprintsCellView
                cell.dataPointsNumber.text = "\(area.fingerprints.list[path.row].data.count)"
            }
        }
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
    
    // TABLE VIEW DELEGATE METHODS
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("DESELECTED")
        selectedCell = -1
        selectedCellIndexPath = nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("DID SELECT")
        selectedCell = indexPath.row
        selectedCellIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        println("WILL DESELECT")
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
