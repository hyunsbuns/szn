//
//  LocationPlotterVC.swift
//  Squad
//
//  Created by Michael Litman on 2/18/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import MapKit

class LocationPlotterVC: UIViewController
{
    var mapView: MKMapView!
    var lat : CLLocationDegrees!
    var lon : CLLocationDegrees!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.updateMap()
    }

    func setLocation(_ lat: CLLocationDegrees, lon: CLLocationDegrees)
    {
        self.lat = lat
        self.lon = lon
    }
    
    func updateMap()
    {
        let coords = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
        let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.00725, longitudeDelta: 0.00725))
        self.mapView.setRegion(region, animated: false)
        let pin = MapAnnotation(coords: coords)
        self.mapView.addAnnotation(pin)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
