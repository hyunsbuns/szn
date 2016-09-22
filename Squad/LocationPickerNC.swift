//
//  LocationPickerNC.swift
//  Squad
//
//  Created by Michael Litman on 2/16/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import LocationPicker
import CoreLocation

class LocationPickerNC: UINavigationController
{
    let locationPicker = LocationPickerViewController()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // you can optionally set initial location
        if(SquadCore.selectedLocation != nil)
        {
            self.locationPicker.location = SquadCore.selectedLocation
            self.setNavigationBarHidden(true, animated: false)
        }
        
        locationPicker.searchBarStyle = .default
        //let location = CLLocation(latitude: 35, longitude: 35)
        //let initialLocation = Location(name: "My Home", location: location, placemark: CLPlacemark())
        //locationPicker.location = initialLocation
        
        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true
        
        // default: navigation bar's `barTintColor` or `.whiteColor()`
        locationPicker.currentLocationButtonBackground = .blue
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"
        
        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"
        
        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600
        
        locationPicker.completion = { location in
            // do some awesome stuff with location
        }
        
        self.pushViewController(self.locationPicker, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        //print(self.locationPicker.location?.location)
        SquadCore.selectedLocation = self.locationPicker.location!
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
