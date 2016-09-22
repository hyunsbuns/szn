//
//  ManageAdminsVC.swift
//  Squad
//
//  Created by Michael Litman on 7/14/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class ManageAdminsVC: UIViewController
{
    var listVC : ManageAdminsList!
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navBar.tintColor = UIColor.white
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            cancelBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            saveBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
       
    }

    @IBAction func saveButtonPressed()
    {
        listVC.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.listVC = segue.destination as! ManageAdminsList
    }
    

}
