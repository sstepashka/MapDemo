//
//  PointDetailViewController.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 26/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import UIKit

class PointDetailViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    
    var point: Point!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "\(point.title)\n\n\(point.subtitle ?? "<empty>")\n\n\(point.description ?? "<empty>")"
    }
}
