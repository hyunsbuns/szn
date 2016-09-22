//
//  MapHolderVC.swift
//  Squad
//
//  Created by Michael Litman on 7/26/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import MapKit

class MapHolderVC: UIViewController
{
    var lat : CLLocationDegrees!
    var lon : CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func getDirectionsButtonPressed()
    {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?center=\(lat),\(lon)=14&views=traffic")!)
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Google Maps is required for this feature!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
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
