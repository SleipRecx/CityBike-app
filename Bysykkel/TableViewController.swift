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
import CoreData

class TableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate  {
    
    var searchController : UISearchController!
    var refreshController = UIRefreshControl()
    var resultController = UITableViewController()
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIBarButtonItem!
   
    var places: [BikePlace] = []
    var filteredPlaces: [BikePlace] = []
    var favorites: [BikePlace] = []
    var favoritesID: [Int] = []
    var listItems = [NSManagedObject]()

    
    override func viewDidLoad(){
        super.viewDidLoad()
        fetchFavoritesFromCoreData()
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
    
     func fetchFavoritesFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Favorite")
        do{
            let results = try managedContext.executeFetchRequest(fetchRequest)
            listItems = results as! [NSManagedObject]
        }
        catch{
            print("error")
        }
        for item in listItems{
            self.favoritesID.append(item.valueForKey("id") as! Int)
        }
    }
    
    
    
    func saveFavorites(itemToSave: Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
       
        
        let entity = NSEntityDescription.entityForName("Favorite", inManagedObjectContext: managedContext)
        
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(itemToSave, forKey: "id")
        
        do{
            try managedContext.save()
            listItems.append(item)
        
        }
        catch{
            print("error")
        }
        
        
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
                        if(self.favoritesID.contains(Int(place["Address"].stringValue.componentsSeparatedByString("-")[0])!)){
                            self.favorites.append(object)
                        }

                    }
                    self.places.sortInPlace({$0.distance < $1.distance})
                    self.favorites.sortInPlace({$0.distance < $1.distance})
                    self.tableView.reloadData()
                }
            case
            .Failure(let error):
                print(error)
            }
        }
        
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        if self.tableView.tableHeaderView == self.searchController.searchBar{
            self.tableView.tableHeaderView = nil
        }
        else{
            self.presentViewController(searchController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func mySegmentedControlPressed(sender: AnyObject) {
        if(mySegmentedControl.selectedSegmentIndex == 1){
            self.searchButton.enabled = false
            self.searchButton.tintColor = UIColor.clearColor()
        }
        else{
            self.searchButton.enabled = true
            self.searchButton.tintColor = UIColor.whiteColor()
        }
        self.tableView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? CustomCell {
            
            let secondViewController = segue.destinationViewController as! ViewController
            let index = self.places.indexOf({$0.id == cell.id})!  //This line is important to remember
            secondViewController.places = self.places
            secondViewController.currentPlace.append(self.places[index])
            
        }
        else{
            let secondViewController = segue.destinationViewController as! MapViewController
            secondViewController.places = self.places
        }
    }
    
   
    
    func refreshTable(){
        self.refreshControl?.beginRefreshing()
        self.places.removeAll()
        self.filteredPlaces.removeAll()
        self.favorites.removeAll()
        fetchJSON()
        self.tableView.reloadData()
        self.refreshController.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if (self.favoritesID.contains(self.places[indexPath.row].id)){
            let fav = UITableViewRowAction(style: .Normal, title: "Unfavorite"){(
                action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
                self.favoritesID.removeAtIndex(self.favoritesID.indexOf(self.places[indexPath.row].id)!)
                self.favorites.removeAtIndex(self.favorites.indexOf(self.places[indexPath.row])!)
                self.favorites.sortInPlace({$0.distance < $1.distance})
                self.tableView.reloadData()
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDel.managedObjectContext
                context.deleteObject(self.listItems[self.listItems.indexOf({$0.valueForKey("id")as! Int == self.places[indexPath.row].id})!] as NSManagedObject)
                self.listItems.removeAtIndex(self.listItems.indexOf({$0.valueForKey("id")as! Int == self.places[indexPath.row].id})!)
                do{
                    try context.save()
                }
                catch{
                    
                }
                
            }
            fav.backgroundColor = UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
            return [fav]
        }
            
        else{
            let fav = UITableViewRowAction(style: .Normal, title: "Favorite"){(
                action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
                self.favoritesID.append(self.places[indexPath.row].id)
                self.favorites.append(self.places[indexPath.row])
                self.saveFavorites(self.places[indexPath.row].id)
                self.favorites.sortInPlace({$0.distance < $1.distance})
                
                self.tableView.reloadData()
            }
            fav.backgroundColor = UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
            return [fav]
        }
    }
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(mySegmentedControl.selectedSegmentIndex == 1){
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCurrentTableViewArray().count
    }
    
    
    func getCurrentTableViewArray()->[BikePlace]{
        if(mySegmentedControl.selectedSegmentIndex == 1){
            return self.favorites
        }
        if(filteredPlaces.count > 0){
             return self.filteredPlaces
        }
        else {
            return self.places
        }
       
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CustomCell = self.tableView.dequeueReusableCellWithIdentifier("myCell")! as! CustomCell
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        tableView.rowHeight = 51
        let array: [BikePlace] = self.getCurrentTableViewArray()
        
        if hour < 6{
            cell.one.text = array[indexPath.row].getDisplayString() + " [Stengt]"
        }
        else{
            cell.one.text = array[indexPath.row].getDisplayString()
        }
        
        if(self.places[indexPath.row].distance > 10000){
            cell.two.text = String(array[indexPath.row].distance/1000) +
                " Kilometer"  + " - Stativer: " + String(array[indexPath.row].availableSlots) +  " - Sykler: " + String(array[indexPath.row].availableBikes)
        }
        else{
            cell.two.text = String(array[indexPath.row].distance) +
                " Meter"  + " - Stativer: " + String(array[indexPath.row].availableSlots) +  " - Sykler: " + String(array[indexPath.row].availableBikes)
        }
        
        if(array[indexPath.row].availableBikes == 0){
            cell.img.backgroundColor =  UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        }
        else if(array[indexPath.row].availableSlots == 0){
            cell.img.backgroundColor =  UIColor.grayColor()
        }
        else if (array[indexPath.row].availableBikes < 5){
            cell.img.backgroundColor =  UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
        }
        else{
            cell.img.backgroundColor =  UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
        }
        cell.id = array[indexPath.row].id

        return cell
    }
    
  
    
    
}
