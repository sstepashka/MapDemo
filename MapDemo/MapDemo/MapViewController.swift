//
//  MapViewController.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 26/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import UIKit
import MapKit
import DBMapSelectorViewController

struct Point {
    let title: String
    let subtitle: String?
    
    let coordinate: CLLocationCoordinate2D;
    
    let description: String?
}

extension Point {
    static func loadFromFile(filename: String) -> [Point] {
        guard let fileURL = NSBundle.mainBundle().URLForResource(filename, withExtension: "json") else {
            fatalError("Could not get file with name \(filename) from resources.")
        }
        
        guard let data = NSData(contentsOfURL: fileURL) else {
            fatalError("Can't create input stream from file with URL: \(fileURL)")
        }
        
        guard let JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) else {
            fatalError("Can't parse JSON from file with URL: \(fileURL)")
        }
        
        guard let JSONPoints = JSON as? [[String: AnyObject]] else {
            fatalError("Wrong JSON data format.")
        }
        
        return JSONPoints.map({ (JSONPoint) -> Point in
            guard let title = JSONPoint["title"] as? String else {
                fatalError("Can't parse point title.")
            }
            
            let subtitle = JSONPoint["subtitle"] as? String
            let description = JSONPoint["description"] as? String
            
            guard let JSONCoordinate = JSONPoint["coordinate"] as? [String: CLLocationDegrees] else {
                fatalError("Can't parse point coordinate.")
            }
            
            guard let latitude = JSONCoordinate["latitude"] else {
                fatalError("Can't parse point latitude.")
            }
            
            guard let longitude = JSONCoordinate["longitude"] else {
                fatalError("Can't parse point longtitude.")
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            return Point(title: title, subtitle: subtitle, coordinate: coordinate, description: description)
        })
    }
}

class PointAnnotation: NSObject, MKAnnotation {
    let point: Point
    
    init(point: Point) {
        self.point = point
        super.init()
    }
    
    @objc var coordinate: CLLocationCoordinate2D {
        return point.coordinate
    }
    
    var title: String? {
        return point.title
    }
    
    var subtitle: String? {
        return point.subtitle
    }
}

extension Point {
    func annotation() -> MKAnnotation {
        return PointAnnotation(point: self)
    }
}

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    let points = Point.loadFromFile("points")
    var mapSelectorManager: DBMapSelectorManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSelectorManager = DBMapSelectorManager(mapView: mapView)
        mapSelectorManager.delegate = self
        
        mapSelectorManager.circleCoordinate = CLLocationCoordinate2DMake(54.857260, 83.107504)
        mapSelectorManager.circleRadius = 1000
        
        mapSelectorManager.applySelectorSettings()
        
        mapView.addAnnotations(points.map({ $0.annotation() }))
        
        if let point = points.first {
            mapView.region = MKCoordinateRegion(center: point.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        }
        
        navigationItem.rightBarButtonItems = [searchButton()]
        
        mapSelectorManager.hidden = true
    }
    
    @IBAction func search(sender: AnyObject) {
        mapSelectorManager.hidden = !mapSelectorManager.hidden
        
        if (mapSelectorManager.hidden) {
            navigationItem.leftBarButtonItems = .None
            navigationItem.rightBarButtonItems = [searchButton()]
        } else {
            navigationItem.leftBarButtonItems = [cancelButton()]
            navigationItem.rightBarButtonItems = [doneButton()]
        }
    }
    
    private func searchButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(search))
    }
    
    private func doneButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(showListOfRegion))
    }
    
    private func cancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(search))
    }
    
    @IBAction func showListOfRegion(sender: AnyObject) {
//        let center = mapSelectorManager.circleCoordinate
//        let radius = mapSelectorManager.circleRadius
        
        performSegueWithIdentifier("ShowPointList", sender: self)
    }
}

extension MapViewController: DBMapSelectorManagerDelegate {
    func mapSelectorManagerDidHandleUserInteraction(mapSelectorManager: DBMapSelectorManager!) {
        
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(PointAnnotation) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView.canShowCallout = true
            
            return annotationView
        }
        
        return mapSelectorManager.mapView(mapView, viewForAnnotation: annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        mapSelectorManager.mapView(mapView,
                                   annotationView: view,
                                   didChangeDragState: newState,
                                   fromOldState: oldState)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return mapSelectorManager.mapView(mapView, rendererForOverlay: overlay)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapSelectorManager.mapView(mapView, regionDidChangeAnimated: animated)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegueWithIdentifier("PointDetail", sender: view.annotation)
    }
}

extension MapViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PointDetail" {
            let pointDetailViewController = segue.destinationViewController as! PointDetailViewController
            let pointAnnotation = sender as! PointAnnotation
            
            pointDetailViewController.point = pointAnnotation.point
        }
    }
}
