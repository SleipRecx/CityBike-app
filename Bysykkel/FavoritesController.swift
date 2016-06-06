//
//  FavoritesController.swift
//  Bysykkel
//
//  Created by Markus Andresen on 05/06/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit

class FavoritesController: UITableViewController {
    
    var places: [BikePlace] = []
    var currentFavorites: [BikePlace] = []
    var possibleFavorites: [BikePlace] = []
    var favoritesCountStart = 0
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var passDataBack: ((data: [BikePlace]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePossibleFavorites()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func populatePossibleFavorites(){
        possibleFavorites = places.filter {!currentFavorites.contains($0)}
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let sr = tableView.indexPathsForSelectedRows {
            if sr.count == possibleFavorites.count-1{
                let alertController = UIAlertController(title: "What?", message:
                    "Are you serious mate?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
                return nil
            }
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentFavorites.append(possibleFavorites[indexPath.row])
        let cell: CustomCell = self.tableView.cellForRowAtIndexPath(indexPath) as! CustomCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        enableDisableAddButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        currentFavorites = currentFavorites.filter() { $0 !== possibleFavorites[indexPath.row] }
        let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.None
        enableDisableAddButton()
    }
    
    func enableDisableAddButton(){
        if(currentFavorites.count > favoritesCountStart){
            addButton.enabled = true
        }
        else{
            addButton.enabled = false
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleFavorites.count
    }
    
    
    func getCellColor(place:BikePlace) -> UIColor{
        if(place.availableBikes == 0){
            return UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        }
        else if(place.availableSlots == 0){
            return UIColor.grayColor()
        }
        else if (place.availableBikes < 5){
            return UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
        }
        else{
            return UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
        }
    }
    
    func addExtraMarks(cell: CustomCell, place: BikePlace){
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        if hour < 6{
            cell.one.text = place.getDisplayString() + " [Stengt]"
        }
            
        else{
            cell.one.text = place.getDisplayString()
        }
        
        if(place.distance > 10000){
            cell.two.text = String(place.distance/1000) +
                " Kilometer"  + " - Stativer: " + String(place.availableSlots) +  " - Sykler: " + String(place.availableBikes)
        }
        else{
            cell.two.text = String(place.distance) +
                " Meter"  + " - Stativer: " + String(place.availableSlots) +  " - Sykler: " + String(place.availableBikes)
        }

    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.rowHeight = 51
        let cell:CustomCell = self.tableView.dequeueReusableCellWithIdentifier("myCell")! as! CustomCell
        let array: [BikePlace] = self.possibleFavorites
        cell.id = array[indexPath.row].id
        cell.img.backgroundColor = getCellColor(array[indexPath.row])
        cell.accessoryType = UITableViewCellAccessoryType.None
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        addExtraMarks(cell, place: array[indexPath.row])
        
        return cell

    }
    

    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        self.passDataBack?(data: currentFavorites)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}