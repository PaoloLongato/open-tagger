//
//  AreasTableTableViewController.swift
//  
//
//  Created by Paolo Longato on 25/07/2015.
//
//

import UIKit

class AreasTableViewController: UITableViewController {

    var areas = Areas()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return areas.list.count
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "editArea" {
            let index = sender!.tag
            let VC = segue.destinationViewController as! EditAreaViewController
            VC.area = areas.list[index]
            VC.updateTable = reloadTable
        } else if segue.identifier == "fingerprints" {
            let index = sender!.tag
            let VC = segue.destinationViewController as! FingerprintsTableViewController
            VC.area = areas.list[index]            
            /*
            VC.name.text = areas.list[tableView.indexPathForSelectedRow()!.row].name
            VC.des.text = areas.list[tableView.indexPathForSelectedRow()!.row].des
            VC.picture.image = areas.list[tableView.indexPathForSelectedRow()!.row].picture
            */
        }
    }

}
