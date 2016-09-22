//
//  NewAnnouncementVC.swift
//  Squad
//
//  Created by Michael Litman on 7/9/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class NewAnnouncementVC: UIViewController
{
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var textView: UITextView!
    var announcementsCVC : AnnouncementsCVC!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.titleTF.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    func validateForm() -> Bool
    {
        var error = ""
        if(titleTF.text == "")
        {
            error = "You must enter a title"
        }
        else if(self.textView.text == "")
        {
            error = "You must enter an announcement"
        }
        if(error != "")
        {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else
        {
            return true
        }
    }
    
    @IBAction func saveButtonPressed()
    {
        if(validateForm())
        {
            let obj = PFObject(className: "Announcements")
            obj["squad"] = SquadCore.selectedSquad
            obj["poster"] = SquadCore.currentUser
            obj["title"] = self.titleTF.text!
            obj["message"] = self.textView.text!
            obj["timestamp"] = Date()
            obj.saveInBackground(block: { (success: Bool, error: Error?) in
                if(success)
                {
                    //update the collection view and reload its data
                    self.announcementsCVC.data.insert(obj, at: 0)
                    self.announcementsCVC.collectionView?.reloadData()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning()
    {
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
