//
//  TableViewController.swift
//  Bysykkel
//
//  Created by Markus Andresen on 02/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }}

class TableViewController: UITableViewController, UISearchResultsUpdating  {
    
    class BikePlace {
        var availableBikes: Int
        var availableSlots: Int
        var adress: String
        var online: Bool
        var description: String
        var longitude: Double
        var latitude: Double
       
        init(availableBikes: Int,  availableSlots: Int, adress: String, online: Bool, longitude: Double, latitude: Double ){
            self.availableBikes = availableBikes
            self.availableSlots = availableSlots
            self.description = adress.substringFromIndex(adress.startIndex.advancedBy(3))
            self.adress = adress.substringFromIndex(adress.startIndex.advancedBy(3)).componentsSeparatedByString(",")[0]
            self.adress = self.adress.componentsSeparatedByString("/")[0]
            self.adress = self.adress.componentsSeparatedByString("(")[0]
            self.online = online
            self.longitude = longitude
            self.latitude = latitude
           
        }
        
        func getDisplayString() -> String{
            let result: String = self.adress
            return result
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
    
    
    func fetchJSON(){
        let API_URL: String = "http://map.webservice.sharebike.com:8888/json/MapService/LiveStationData?APIKey=3EFC0CF3-4E99-40E2-9E42-B95C2EDE6C3C&SystemID=citytrondheim"
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
                
                        let object = BikePlace(availableBikes: place["AvailableBikeCount"].intValue,availableSlots: place["AvailableSlotCount"].intValue,adress: place["Address"].stringValue,online: online,longitude: longitude,latitude: latitude)
                        self.places.append(object)
                    }
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                print(error)
            }
        }
        

    }
    

    var searchController : UISearchController!
    var refreshController = UIRefreshControl()
    var resultController = UITableViewController()
    
    var places: [BikePlace] = []
    var filteredPlaces: [BikePlace] = []
    
    @IBAction func searchPressed(sender: AnyObject) {
        if self.tableView.tableHeaderView == self.searchController.searchBar{
            self.tableView.tableHeaderView = nil
        }
        else{
            self.presentViewController(searchController, animated: true, completion: nil)
        }

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = self.tableView.indexPathForCell(cell)!
            let place = places[indexPath.row]
            let secondViewController = segue.destinationViewController as! ViewController
            secondViewController.latitude = place.latitude
            secondViewController.longitude = place.longitude
            secondViewController.adress = place.adress
            secondViewController.availableBikes = place.availableBikes
            secondViewController.availableSlots = place.availableSlots
            secondViewController.online = place.online
        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.delegate = self
        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.refreshControl = self.refreshController
        self.searchController.dimsBackgroundDuringPresentation = false
        self.refreshController.addTarget(self, action: #selector(TableViewController.refreshTable), forControlEvents: .ValueChanged)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.barTintColor = UIColor(red: 160/255, green: 30/255, blue: 34/255, alpha: 1.0)
        definesPresentationContext = true
        fetchJSON()
    }
    
    override func viewDidAppear(animated: Bool) {
        searchController.active = false
    }
    
    
    
    func refreshTable(){
        self.places.removeAll()
        self.filteredPlaces.removeAll()
        self.tableView.reloadData()
        fetchJSON()
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
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("myCell")! as UITableViewCell

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 212/255, green: 95/255, blue: 100/255, alpha: 0.3)
        cell.selectedBackgroundView = bgColorView
        if tableView == self.tableView{
            cell.textLabel?.text = self.places[indexPath.row].getDisplayString()
            cell.detailTextLabel?.text = String(self.places[indexPath.row].availableBikes) + " sykler, " + String(self.places[indexPath.row].availableSlots) + " låser"
        }
        else{
            cell.textLabel?.text = self.filteredPlaces[indexPath.row].getDisplayString()
        }

        
        return cell
    }

    


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
