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

class TableViewController: UITableViewController, UISearchResultsUpdating, CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate {
    
    var searchController : UISearchController!
    var refreshController = UIRefreshControl()
    var resultController = UITableViewController()
    let locationManager = CLLocationManager()
    var searchActive = false

    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
   
    var places: [BikePlace] = []
    var filteredPlaces: [BikePlace] = []
    var favorites: [BikePlace] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
    
        let searchBarItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(TableViewController.searchPressed))
        searchBarItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = searchBarItem
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.delegate = self
        self.refreshControl = self.refreshController
        let string = "Dra for å oppdatere"
        let myAttrString = NSAttributedString(string: string, attributes: nil)
        self.refreshController.attributedTitle = myAttrString
        self.refreshController.addTarget(self, action: #selector(TableViewController.refreshTable), for: .valueChanged)
        
        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.barTintColor = UIColor(red: 170/255, green: 50/255, blue: 50/255, alpha: 1.0)
        self.searchController.searchBar.tintColor = UIColor.white
        definesPresentationContext = true
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        refreshTable()
    }
    

    func checkIfLocationEnabled(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
           askForLocationInSettings()
        }

    }
    
    func askForLocationInSettings(){
        let alertController = UIAlertController(
            title: "Stedstjenester avskrudd",
            message: "For at appen skal fungerer må du skru på stedstjenester i innstillinger.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel){ (action) in
            self.refreshControl?.endRefreshing()
        }
        
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Åpne Innstillinger", style: .default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
             self.refreshControl?.endRefreshing()
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        appdelegate.shouldSupportAllOrientation = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    

    func fetchJSON(){
            let API_URL: String = "http://map.webservice.sharebike.com:8888/json/MapService/LiveStationData?APIKey=" +
            "3EFC0CF3-4E99-40E2-9E42-B95C2EDE6C3C&SystemID=citytrondheim"
            let myLocation = locationManager.location!
            Alamofire.request(API_URL).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let array = json["result"]["LiveStationData"].arrayValue
                        for place in array{
                            var online:Bool =  place["Online"].boolValue
                            let longitude: Double = place["Longitude"].doubleValue
                            let latitude: Double = place["Latitude"].doubleValue
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            let distance = Int((myLocation.distance(from: location)))
                            var adress = place["Address"].stringValue
                            let bikes = place["AvailableBikeCount"].intValue
                            let slots = place["AvailableSlotCount"].intValue
                            if(adress.contains("[Offline]")){
                                online = false
                                adress = adress.components(separatedBy: " ")[1]
                            }
                            let object = BikePlace(availableBikes: bikes,availableSlots: slots, adress: adress,online: online,location: location, distance: distance)
                            self.places.append(object)
                        }
                        self.fetchFavorites()
                        self.places.sort(by: {$0.distance < $1.distance})
                        self.tableView.reloadData()
                        
                    }
                default:
                    break
                }
            
        }
    }
    
  
    func saveFavorites(){
        var tmp = ""
        for favorite in favorites{
            tmp = tmp + String(favorite.id) + ","
        }
        UserDefaults.standard.set(tmp, forKey: "favorites")
    }
    
    
    func fetchFavorites(){
        var favoritesID : [Int] = []
        if( UserDefaults.standard.object(forKey: "favorites") != nil) {
            let favString = UserDefaults.standard.object(forKey: "favorites")! as! String
            let tmp = favString.characters.split{$0 == ","}.map(String.init)
            for string in tmp{
                favoritesID.append(Int(string)!)
            }
        }
        for place in places{
            if(favoritesID.contains(place.id)){
                favorites.append(place)
            }
        }
        favorites.sort(by: {$0.distance < $1.distance})
    }
    

    
    // IBAction Methods
    @IBAction func mySegmentedControlPressed(_ sender: AnyObject) {
        if(mySegmentedControl.selectedSegmentIndex == 1){
            let addBarItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(TableViewController.performPopover))
            addBarItem.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = addBarItem
        }
        else{
            let searchBarItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(TableViewController.searchPressed))
            searchBarItem.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = searchBarItem
        }
        self.tableView.reloadData()
    }
    
    func searchPressed(){
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    
    // TableView Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(mySegmentedControl.selectedSegmentIndex == 1){
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCurrentTableViewArray().count
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let unFav = UITableViewRowAction(style: .normal, title: "Fjern"){(
            action: UITableViewRowAction, indexPath: IndexPath!) -> Void in
            self.favorites.remove(at: self.favorites.index(of: self.favorites[indexPath.row])!)
            self.favorites.sort(by: {$0.distance < $1.distance})
            self.tableView.reloadData()
            self.saveFavorites()
        }
        unFav.backgroundColor = UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        return [unFav]
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = 51
        let cell:CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "myCell")! as! CustomCell
        let array: [BikePlace] = self.getCurrentTableViewArray()
        cell.id = array[(indexPath as NSIndexPath).row].id
        cell.img.backgroundColor = array[(indexPath as NSIndexPath).row].getColorCode()
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        addExtraMarks(cell, place: array[(indexPath as NSIndexPath).row])
        return cell
        
    }
    
    // TableView support methods
    
    func updateSearchResults(for searchController: UISearchController) {
        searchActive = searchController.isActive
        self.filteredPlaces =  self.places.filter {place -> Bool in
            if place.getDisplayString().lowercased().contains(self.searchController.searchBar.text!.lowercased()){
                return true
            }
            else{
                return false
            }
        }
        self.resultController.tableView.reloadData()
    }
    
    
    func refreshTable(){
        let status = CLLocationManager.authorizationStatus()
        if(status == .authorizedWhenInUse ){
            self.places.removeAll()
            self.filteredPlaces.removeAll()
            self.favorites.removeAll()
            self.refreshControl?.beginRefreshing()
            fetchJSON()
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }
        else if(status == .notDetermined){
            //nothing
        }
        else{
            self.places.removeAll()
            self.filteredPlaces.removeAll()
            self.favorites.removeAll()
            self.tableView.reloadData()
            askForLocationInSettings()
        }
       
    }
  
    
    
    func getCurrentTableViewArray()->[BikePlace]{
        if(mySegmentedControl.selectedSegmentIndex == 1){
            return self.favorites
        }
        if(searchActive){
            return self.filteredPlaces
        }
        else {
            return self.places
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
    
    // Transfer data between v iews
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "mySegue"){
            let cell = sender as? CustomCell
            let index = self.places.index(where: {$0.id == cell!.id})!
            let secondViewController = segue.destination as! MapViewController
            secondViewController.currentPlace.append(self.places[index])
            secondViewController.places = self.places
        }
            
        else{
            let secondViewController = segue.destination as! MapViewController
            secondViewController.places = self.places
        }
    }
    
    
    func performPopover(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! UINavigationController
        let  destinationController = controller.topViewController as! FavoritesController
        destinationController.currentFavorites = self.favorites
        destinationController.places = self.places
        destinationController.favoritesCountStart = self.favorites.count
        destinationController.passDataBack = {[weak self]
            (data) in
            if self != nil {
                self!.favorites = data
                self!.saveFavorites()
                self!.tableView.reloadData()
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
  
    
    
}
