//
//  SelectAreaOverlay.swift
//  MapDemo
//
//  Created by Kuragin Dmitriy on 31/05/16.
//  Copyright © 2016 Kuragin Dmitriy. All rights reserved.
//

import Foundation
import MapKit

class CornerAnnotationView: MKAnnotationView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            CGContextSaveGState(context)
            
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
//            CGContextSetRGBFillColor(context, colorRed, colorGreen, colorBlue, 1.0);
            CGContextSetLineWidth(context, 2.0);
            
            CGContextFillEllipseInRect(context, self.bounds)
            CGContextFillPath(context);
            
            CGContextRestoreGState(context)
        }
    }
}