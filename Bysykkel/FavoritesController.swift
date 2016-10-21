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
    
    var passDataBack: ((_ data: [BikePlace]) -> ())?
    
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let sr = tableView.indexPathsForSelectedRows {
            if sr.count == possibleFavorites.count-1{
                let alertController = UIAlertController(title: "What?", message:
                    "That's just stupid", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                }))
                self.present(alertController, animated: true, completion: nil)
                return nil
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentFavorites.append(possibleFavorites[(indexPath as NSIndexPath).row])
        let cell: CustomCell = self.tableView.cellForRow(at: indexPath) as! CustomCell
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        enableDisableAddButton()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        currentFavorites = currentFavorites.filter() { $0 !== possibleFavorites[(indexPath as NSIndexPath).row] }
        let cell: UITableViewCell = self.tableView.cellForRow(at: indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.none
        enableDisableAddButton()
    }
    
    func enableDisableAddButton(){
        if(currentFavorites.count > favoritesCountStart){
            addButton.isEnabled = true
        }
        else{
            addButton.isEnabled = false
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleFavorites.count
    }
    
    
    func getCellColor(_ place:BikePlace) -> UIColor{
        if(place.availableBikes == 0){
            return UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        }
        else if(place.availableSlots == 0){
            return UIColor.gray
        }
        else if (place.availableBikes < 5){
            return UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
        }
        else{
            return UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
        }
    }
    
    
    func addExtraMarks(_ cell: CustomCell, place: BikePlace){
        let hour = (Calendar.current as NSCalendar).component(.hour, from: Date())
        if hour < 6{
            cell.one.text = place.getDisplayString()  // stengt
        }
            
        else{
            cell.one.text = place.getDisplayString()
        }
        
        if(place.distance > 10000){
            cell.two.text = String(place.distance/1000) + " Kilometer"
        }
        else{
            cell.two.text = String(place.distance) +
            " Meter"
        }
        cell.three.text =   String(place.availableBikes)
        cell.four.text! =  String(place.availableSlots)
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 51
        let cell:CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "myCell")! as! CustomCell
        let array: [BikePlace] = self.possibleFavorites
        cell.id = array[(indexPath as NSIndexPath).row].id
        cell.img.backgroundColor = getCellColor(array[(indexPath as NSIndexPath).row])
        cell.accessoryType = UITableViewCellAccessoryType.none
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        addExtraMarks(cell, place: array[(indexPath as NSIndexPath).row])
        
        return cell

    }
    

    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        self.passDataBack?(currentFavorites)
        self.dismiss(animated: true, completion: nil)
    }
    

}
