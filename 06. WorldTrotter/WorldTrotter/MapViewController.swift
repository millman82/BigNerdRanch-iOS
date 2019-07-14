//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Tim Miller on 7/14/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var mapView: MKMapView!
    var zoomButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    override func loadView() {
        // Create a map view
        mapView = MKMapView()
        
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
        
        zoomButton = UIButton(type: .custom)
        zoomButton.setImage(UIImage(named: "ZoomIcon"), for: .normal)
        zoomButton.setTitleColor(UIColor.black, for: .normal)
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomButton)
        
        zoomButton.addTarget(self, action: #selector(MapViewController.zoomInCurrentLocation(_:)), for: .touchUpInside)
        
        let zoomButtonTopConstraint = zoomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        let zoomButtonTrailingConstraint = zoomButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        zoomButtonTopConstraint.isActive = true
        zoomButtonTrailingConstraint.isActive = true
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
        
        print("clicked")
    }
    
}


