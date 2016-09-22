//
//  ChangePasswordVC.swift
//  Squad
//
//  Created by Michael Litman on 8/23/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController
{
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.passwordTF.becomeFirstResponder()
        
        self.navBar.tintColor = UIColor.white
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            cancelBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            saveBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
    }

    @IBAction func updatePassword()
    {
        var error = ""
        if(self.passwordTF.text == "")
        {
            error = "You must enter a new password"
        }
        else if(self.confirmPasswordTF.text == "")
        {
            error = "You must confirm the password"
        }
        else if(self.passwordTF.text != self.confirmPasswordTF.text)
        {
            error = "The passwords do not match"
        }
        
        if(error == "")
        {
            //change the password
            SquadCore.currentUser.password = self.passwordTF.text!
            SquadCore.currentUser.saveInBackground(block: { (success: Bool, error: Error?) in
                if(success)
                {
                    let alert = UIAlertController(title: "Success", message: "Your password has been successfully changed.  Please use this new password the next time you login.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)

                }
                else
                {
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)

                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
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
