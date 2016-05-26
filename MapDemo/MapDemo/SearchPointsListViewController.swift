//
//  SearchPointsListViewController.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 26/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import UIKit

class SearchPointsListViewController: UITableViewController {
    var points: [Point] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var showDetailPointType: ShowDetailPointType? = .None

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

extension SearchPointsListViewController: ShowDetailPointType {
    func showDetailPoint(point: Point) {
        self.showDetailPointType?.showDetailPoint(point)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.setNeedsLayout()
    }
}
