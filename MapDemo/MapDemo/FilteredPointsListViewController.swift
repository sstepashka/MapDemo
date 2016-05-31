//
//  FilteredPointsListViewController.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 31/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import UIKit
import MapKit

class FilteredPointsListViewController: PointsListViewController {
    var center: CLLocationCoordinate2D? = .None
    var radius: CLLocationDistance? = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  let center = center,
            let radius = radius
        {
            points = points.filter({ (point) -> Bool in
                let locationFirst = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                let locationSecond = CLLocation(latitude: center.latitude, longitude: center.longitude)
                
                return locationFirst.distanceFromLocation(locationSecond) <= radius
            })
        }
    }
}
