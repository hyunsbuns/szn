//
//  ForgotPasswordVC.swift
//  Squad
//
//  Created by Michael Litman on 8/23/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordVC: UIViewController
{
     @IBOutlet weak var emailTF: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.emailTF.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    @IBAction func resetButtonPressed()
    {
        var error = ""
        if(self.emailTF.text == "")
        {
            error = "You must enter the email address associated with this account."
        }
        
        if(error == "")
        {
            //reset password
            PFUser.requestPasswordResetForEmail(inBackground: self.emailTF.text!, block: { (success: Bool, error:Error?) in
                if(success)
                {
                    let alert = UIAlertController(title: "Success", message: "An email has been sent with instructions for resetting your password.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)

                }
                else
                {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
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
