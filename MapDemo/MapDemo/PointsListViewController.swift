//
//  PointsListTableViewController.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 26/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import UIKit

protocol ShowDetailPointType: class {
    func showDetailPoint(point: Point)
}

extension ShowDetailPointType where Self: UIViewController {
    func showDetailPoint(point: Point) {
        let pointDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PointDetailViewController") as! PointDetailViewController
        pointDetailViewController.point = point
        
        self.navigationController?.pushViewController(pointDetailViewController, animated: true)
    }
}

class PointsListViewController: UITableViewController {
    private let points = Point.loadFromFile("points")
    
    private var searchPointsListViewController: SearchPointsListViewController!
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0
        
        searchPointsListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SearchPointsListViewController") as! SearchPointsListViewController
        searchPointsListViewController.showDetailPointType = self
        
        searchController = UISearchController(searchResultsController: searchPointsListViewController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        let point = points[indexPath.row]
        
        cell.textLabel?.text = point.title
        cell.detailTextLabel?.text = "latitude: \(point.coordinate.latitude), longtitude: \(point.coordinate.longitude)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        showDetailPoint(points[indexPath.row])
    }
}

extension PointsListViewController: ShowDetailPointType {

}

extension PointsListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension PointsListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchPointsListViewController = searchController.searchResultsController as! SearchPointsListViewController
        
        if let text = searchController.searchBar.text {
            let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({ (element) -> Bool in
                return element.characters.count > 0
            })
            
            let predicates = words.map({ (word) -> NSPredicate in
                return NSPredicate(format: "self CONTAINS[cd] %@", word)
            })
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            searchPointsListViewController.points = points.filter({ (point) -> Bool in
                return predicate.evaluateWithObject(point.title)
            })
        } else {
            searchPointsListViewController.points = points
        }
    }
}
