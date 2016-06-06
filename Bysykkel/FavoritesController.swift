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
    
    let textCellIdentifier = "TextCell"
    
    var passDataBack: ((data: [BikePlace]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePossibleFavorites()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.setEditing(true, animated: true)
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func populatePossibleFavorites(){
        possibleFavorites = places.filter {!currentFavorites.contains($0)}
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentFavorites.append(possibleFavorites[indexPath.row])
        enableDisableAddButton()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        currentFavorites = currentFavorites.filter() { $0 !== possibleFavorites[indexPath.row] }
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
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)

        cell.textLabel?.text = possibleFavorites[indexPath.row].adress
        cell.detailTextLabel?.text = String(possibleFavorites[indexPath.row].distance) +
            " Meter"  + " - Stativer: " + String(possibleFavorites[indexPath.row].availableSlots) +  " - Sykler: " + String(possibleFavorites[indexPath.row].availableBikes)
      
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