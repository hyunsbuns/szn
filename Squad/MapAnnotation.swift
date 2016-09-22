//
//  MapAnnotation.swift
//  Squad
//
//  Created by Michael Litman on 2/18/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    
    init(coords: CLLocationCoordinate2D)
    {
        self.coordinate = coords
    }
}
