//
//  MapViewController.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import PKHUD

class MapViewController: UIViewController {
    
    //map level vars
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    var selectionView = SelectionView()
    
    @IBOutlet var mapViewModel: MapViewModel!
    
    //accecibility check call on less prioroty utility queue.
    let timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global(qos: .utility))
    
    // Update the map once the user has made their selection.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map.
        mapView.clear()
        
        // Add a marker to the map.
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        listLikelyPlaces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        listLikelyPlaces()
        
        //add top to and from view.
        addTopView()
        
        //time schedule for servicibility check
        timer.schedule(deadline: .now(), repeating: .seconds(20))
        timer.setEventHandler {
             self.checkAccecibility()
                NSLog("Hello World")
        }
        timer.resume()
    }
    
    //remove timer
    deinit {
        timer.cancel()
    }
    //Accecibility call
    //show servicibility fails if
    //We should keep check of this call if servicibility is false once we should stop
    //I am now sure though.
    // Not very efficient call.
    func checkAccecibility() {
        let checkCall = AccecibilityCheckCall()
        checkCall.checkAccecibility()
        checkCall.callCompletion = {[unowned self] (success, messege) in
            if !success {
                self.selectionView.topViewHeightConstraint.constant = 117
                self.selectionView.blockLabelHeightConstraint.constant = 27
                
                UIView.animate(withDuration: 1.5) {
                    self.view.layoutIfNeeded()
                }
            } else {
                self.selectionView.topViewHeightConstraint.constant = 90
                self.selectionView.blockLabelHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 1.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate ,GMSMapViewDelegate{
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        loadLoacation(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
    }
    
    //load locatoion in map.
    func loadLoacation(withLatitude: CLLocationDegrees,
                       longitude: CLLocationDegrees,
                       zoom: Float) {
        
        let camera = GMSCameraPosition.camera(withLatitude: withLatitude,
                                              longitude: longitude,
                                              zoom: zoom)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        //Load likly places too
        listLikelyPlaces()
    }
    
    func loadMarker(latitude: CLLocationDegrees,
                    longitude: CLLocationDegrees,
                    name:String) {
        //Marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        marker.title = name
        marker.map = self.mapView
        marker.icon = UIImage(named: "pin-map")
        self.mapView.selectedMarker = marker
    }
    
    //Custom info window creation using this delegate methode.
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        //Load from nib
        let infoWindow = loadViewFromXibFile(nibname: "CustomInfoWindow", controller: self) as! CustomInfoWindow
        infoWindow.layer.cornerRadius = 5.0
        infoWindow.layer.borderColor = UIColor.white.cgColor
        infoWindow.layer.borderWidth = 1.0
        infoWindow.infoLabel.text = marker.title
        return infoWindow
    }
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

//Extention to create the top bar design
extension MapViewController {
    
    //Add the top location selection view
    func addTopView() {
        //Creating the top selection View from xib
        selectionView = loadViewFromXibFile(nibname: "SelectionView", controller: self) as! SelectionView
        mapView?.addSubview(selectionView)
        
        //Setting up position with autolayout
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionView.heightAnchor.constraint(equalToConstant: 90),
            selectionView.widthAnchor.constraint(equalToConstant: 300),
            ]);
        NSLayoutConstraint(item: selectionView, attribute: .centerX, relatedBy: .equal, toItem: mapView,
                           attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: selectionView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: mapView,
                           attribute: .topMargin,
                           multiplier: 1,
                           constant: 20).isActive = true
        //Initial set up for the custom view
        //Should have created a custom UIControl but then too much work for assignment.
        selectionView.topViewHeightConstraint.constant = 90
        selectionView.blockLabelHeightConstraint.constant = 0
        
        //Design border and radius and stuff
        designSelectionUI()
        
        //add callbacks
        self.selectionView.fromButton.addTarget(self, action: #selector(fromTapped), for: .touchUpInside)
        self.selectionView.toButton.addTarget(self, action: #selector(toTapped), for: .touchUpInside)
    }
    
    //Design the selection view
    func designSelectionUI() {
        selectionView.topView.layer.cornerRadius = 5.0
        selectionView.topView.layer.borderWidth = 1.0
        selectionView.toGreenView.layer.cornerRadius = 5
        selectionView.fromRedView.layer.cornerRadius = 5
        selectionView.blockLabel.layer.cornerRadius = 5
        selectionView.topView.layer.borderColor = UIColor.gray.cgColor
        selectionView.toTopCnstraint.constant = 20
    }
    
    func loadViewFromXibFile(nibname:String, controller:UIViewController) -> UIView {
        let bundle = Bundle(for: MapViewController.self)
        let nib = UINib(nibName: nibname, bundle: bundle)
        let view = nib.instantiate(withOwner:controller, options: nil)[0] as! UIView
        return view
    }
    
    
    //repete but its ok .. just 2 lines. though i should not do this.
    @objc
    func fromTapped() {
        let autocompleteController = MyGMSAutocompleteViewController()
        autocompleteController.view.tag = 1011
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @objc
    func toTapped() {
        let autocompleteController = MyGMSAutocompleteViewController()
        autocompleteController.view.tag = 1010
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection call back. Use received data to create marker and info window.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Dismiss call back for GMSAutocompleteViewController
        dismiss(animated: true, completion: {
            //Update UI at main thread.
            OperationQueue.main.addOperation {[unowned self] in
                //This is pick up location with tag 1011
                if viewController.view.tag == 1011 {
                    self.selectionView.fromLabel.text = place.formattedAddress
                    var param = [String: AnyObject]()
                    param["lat"] = place.coordinate.latitude as AnyObject
                    param["lng"] = place.coordinate.longitude as AnyObject
                    self.mapViewModel.param = nil
                    self.mapViewModel.lat = place.coordinate.latitude
                    self.mapViewModel.lng = place.coordinate.longitude
                    self.loadLoacation(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: self.zoomLevel)
                }
                //Confused here what to do with the to location data.
                if viewController.view.tag == 1010 {
                    self.selectionView.toLabel.text = place.formattedAddress
                    self.selectionView.toTopCnstraint.constant = 8
                }
                
                //Not sure with assignment statement if I have to call it two times or 1 time. both for from and to.
                if viewController.view.tag == 1011 {
                     HUD.show(.progress)
                    self.mapViewModel.fetchData()
                    self.mapViewModel.callCompletion = {[unowned self] success, messege in
                        self.loadMarker(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, name: self.mapViewModel.costTimeEstimation!)
                        HUD.hide()
                    }
                }
            }
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
