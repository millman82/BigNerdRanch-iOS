//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Tim Miller on 7/14/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var interestingLocations: [MKPointAnnotation]!
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    var interestingLocationsSelectedIndex: Int?
    
    override func loadView() {
        // Create a map view
        mapView = MKMapView()
        mapView.delegate = self
        
        // Set it as *the* view of this view controller
        view = mapView
        locationManager = CLLocationManager()
        
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(MapViewController.mapTypeChanged(_:)), for: .valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        let margins = view.layoutMarginsGuide
        let topConstraint = segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        let leadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        
        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        
        let zoomButton = UIButton(type: .custom)
        zoomButton.setImage(UIImage(named: "ZoomIcon"), for: .normal)
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomButton)
        
        zoomButton.addTarget(self, action: #selector(MapViewController.zoomInCurrentLocation(_:)), for: .touchUpInside)
        
        let zoomButtonTopConstraint = zoomButton.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 40)
        let zoomButtonTrailingConstraint = zoomButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        zoomButtonTopConstraint.isActive = true
        zoomButtonTrailingConstraint.isActive = true
        
        initializeInterestingLocationPins()
        
        let interestingLocationsButton = UIButton(type: .custom)
        interestingLocationsButton.setImage(UIImage(named: "MapMarkerIcon"), for: .normal)
        interestingLocationsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(interestingLocationsButton)
        
        interestingLocationsButton.addTarget(self, action: #selector(MapViewController.cycleInterestingLocations(_:)), for: .touchUpInside)
        
        let interestingLocationsButtonBottomConstraint = interestingLocationsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        let interestingLocationsButtonTrailingConstraint = interestingLocationsButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        interestingLocationsButtonBottomConstraint.isActive = true
        interestingLocationsButtonTrailingConstraint.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MapViewController loaded its view.")
    }
    
    @objc func mapTypeChanged(_ segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    @objc func zoomInCurrentLocation(_ button: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = .follow
    }
    
    func initializeInterestingLocationPins() {
        let birthLocationCoordinates = CLLocationCoordinate2D(latitude: 42.034534, longitude: -93.620369)
        let birthLocationPoint = MKPointAnnotation()
        birthLocationPoint.coordinate = birthLocationCoordinates
        birthLocationPoint.title = "Ames, IA"
        birthLocationPoint.subtitle = "The place where I was born"
        
        let currentResidenceCoordinates = CLLocationCoordinate2D(latitude: 35.2981943, longitude: -81.01590809999999)
        let currentResidencePoint = MKPointAnnotation()
        currentResidencePoint.coordinate = currentResidenceCoordinates
        currentResidencePoint.title = "Mount Holly, NC"
        currentResidencePoint.subtitle = "The place where I currently live"
        
        let interestingLocationCoordinates = CLLocationCoordinate2D(latitude: 19.296876, longitude: -81.383275)
        let interestingLocationPoint = MKPointAnnotation()
        interestingLocationPoint.coordinate = interestingLocationCoordinates
        interestingLocationPoint.title = "Grand Cayman, Cayman Islands"
        interestingLocationPoint.subtitle = "Interesting place I have visited"
        
        interestingLocations = [birthLocationPoint, currentResidencePoint, interestingLocationPoint]
    }
    
    @objc func cycleInterestingLocations(_ button: UIButton) {
        mapView.removeAnnotations(interestingLocations)
        
        var currentIndex = 0
        if let previousIndex = interestingLocationsSelectedIndex {
            currentIndex = previousIndex < interestingLocations.count - 1 ? previousIndex + 1 : 0
        }
        
        let location = interestingLocations[currentIndex]
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(location)
        
        interestingLocationsSelectedIndex = currentIndex
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "PinView") as? MKPinAnnotationView {
            pinView.annotation = annotation
            
            return pinView
        }
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        pinView.pinTintColor = MKPinAnnotationView.greenPinColor()
        
        return pinView
    }
    
}




