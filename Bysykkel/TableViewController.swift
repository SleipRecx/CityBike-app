//
//  TableViewController.swift
//  Bysykkel
//  Created by Markus Andresen on 02/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Foundation

class TableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate  {
    
    var searchController : UISearchController!
    var refreshController = UIRefreshControl()
    var resultController = UITableViewController()
    
    var places: [BikePlace] = []
    var filteredPlaces: [BikePlace] = []

    let locationManager = CLLocationManager()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.delegate = self
        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.refreshControl = self.refreshController
        self.searchController.dimsBackgroundDuringPresentation = false
        self.refreshController.addTarget(self, action: #selector(TableViewController.refreshTable), forControlEvents: .ValueChanged)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.barTintColor = UIColor(red: 165/255, green: 30/255, blue: 34/255, alpha: 1.0)
        definesPresentationContext = true
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                locationManager.requestWhenInUseAuthorization()
            default:
               fetchJSON()
            }
        }
        self.tableView.setContentOffset(CGPointZero, animated:true)
    
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredPlaces =  self.places.filter {place -> Bool in
            if place.getDisplayString().lowercaseString.containsString(self.searchController.searchBar.text!.lowercaseString){
                return true
            }
            else{
                return false
            }
        }
        self.resultController.tableView.reloadData();
    }
    
       func fetchJSON(){
        let API_URL: String = "http://map.webservice.sharebike.com:8888/json/MapService/LiveStationData?APIKey=" +
        "3EFC0CF3-4E99-40E2-9E42-B95C2EDE6C3C&SystemID=citytrondheim"
        
        let myLocation = locationManager.location!
   
        Alamofire.request(.GET, API_URL).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let array = json["result"]["LiveStationData"].arrayValue
                    for place in array{
                        let online:Bool =  place["Online"].boolValue
                        let longitude: Double = place["Longitude"].doubleValue
                        let latitude: Double = place["Latitude"].doubleValue
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = Int((myLocation.distanceFromLocation(location)))
                        let object = BikePlace(availableBikes: place["AvailableBikeCount"].intValue,availableSlots: place["AvailableSlotCount"].intValue,adress: place["Address"].stringValue,online: online,location: location, distance: distance)
                        self.places.append(object)
                    }
                    self.places.sortInPlace({$0.distance < $1.distance})
                    self.tableView.reloadData()
                }
            case
            .Failure(let error):
                print(error)
            }
        }
        
    }
    
    
   
    
    func refreshTable(){
        self.refreshControl?.beginRefreshing()
        self.places.removeAll()
        self.filteredPlaces.removeAll()
        fetchJSON()
        self.tableView.reloadData()
        self.refreshController.endRefreshing()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return self.places.count
        }
        else{
            return self.filteredPlaces.count
        }
        
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CustomCell = self.tableView.dequeueReusableCellWithIdentifier("myCell")! as! CustomCell
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        tableView.rowHeight = 51
        if tableView == self.tableView{
            cell.one.text = self.places[indexPath.row].getDisplayString()
            if hour < 6{
                cell.one.text = self.places[indexPath.row].getDisplayString() + " [Stengt]"

            }
            cell.two.text = String(self.places[indexPath.row].distance) +
                " Meter"  + " - Stativer: " + String(self.places[indexPath.row].availableSlots) +  " - Sykler: " + String(self.places[indexPath.row].availableBikes)
            if(self.places[indexPath.row].distance > 10000){
                cell.two.text = String(self.places[indexPath.row].distance/1000) +
                    " Kilometer"  + " - Stativer: " + String(self.places[indexPath.row].availableSlots) +  " - Sykler: " + String(self.places[indexPath.row].availableBikes)
            }
            if(self.places[indexPath.row].availableBikes == 0){
                cell.img.backgroundColor =  UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
            }
            else if(self.places[indexPath.row].availableSlots == 0){
                cell.img.backgroundColor =  UIColor.grayColor()
            }
            else if (self.places[indexPath.row].availableBikes < 5){
                cell.img.backgroundColor =  UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
            }
            else{
                cell.img.backgroundColor =  UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
            }
            cell.displayString = self.places[indexPath.row].getDisplayString()
        }
        else{
            
            cell.one.text = self.filteredPlaces[indexPath.row].getDisplayString()
            if hour < 6{
                cell.one.text = self.filteredPlaces[indexPath.row].getDisplayString() + " [Stengt]"
                
            }
            cell.two.text = String(self.filteredPlaces[indexPath.row].distance) +
                " Meter" + " - Stativer: " + String(self.filteredPlaces[indexPath.row].availableSlots) + " - Sykler: " + String(self.filteredPlaces[indexPath.row].availableBikes)
            if(self.filteredPlaces[indexPath.row].distance > 10000){
                cell.two.text = String(self.filteredPlaces[indexPath.row].distance/1000) +
                    " Kilometer" + " - Stativer: " + String(self.filteredPlaces[indexPath.row].availableSlots) + " - Sykler: " + String(self.filteredPlaces[indexPath.row].availableBikes)
            }

            if(self.filteredPlaces[indexPath.row].availableBikes == 0){
                cell.img.backgroundColor =  UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
            }
            else if(self.filteredPlaces[indexPath.row].availableSlots == 0){
                cell.img.backgroundColor =  UIColor.grayColor()
            }
            else if (self.filteredPlaces[indexPath.row].availableBikes < 5){
                cell.img.backgroundColor =  UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
            }
            else{
                cell.img.backgroundColor =  UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
                
            }
    
             cell.displayString = self.filteredPlaces[indexPath.row].getDisplayString()
            
        }

        return cell
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        if self.tableView.tableHeaderView == self.searchController.searchBar{
            self.tableView.tableHeaderView = nil
        }
        else{
            self.presentViewController(searchController, animated: true, completion: nil)
        }
        
    }
        
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    // TODO - refactor for performance and scalability
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if let cell = sender as? CustomCell {
            let secondViewController = segue.destinationViewController as! ViewController
            for place in places{
                if(place.getDisplayString() == cell.displayString){
                    secondViewController.places = self.places
                    secondViewController.currentPlace.append(place)
                    break
                }
            }
            
        }
        else{
            let secondViewController = segue.destinationViewController as! MapViewController
            secondViewController.places = self.places
        }
    }
    
    
    /*
     
     func updateDistanceInBackground(){
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
     print("he")
     for place in self.places{
     place.distance = Int((self.locationManager.location?.distanceFromLocation(place.location))!)
     }
     self.places.sortInPlace({$0.distance < $1.distance})
     dispatch_async(dispatch_get_main_queue(),{
     self.tableView.reloadData()
     });
     });
     }
     
     */
    
    /*
     func calculateDistanceIn2d(long1: Double, lat1: Double, long2: Double, lat2: Double) -> Int{
     let long1meter = long1 * 49897
     let lat1meter = lat1 * 111469
     let long2meter = long2 * 49897
     let lat2meter = lat2 * 111469
     let x = pow(long2meter - long1meter , 2)
     let y = pow(lat2meter - lat1meter , 2)
     let dist = sqrt(x + y)
     return Int(dist)
     }
     */


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
