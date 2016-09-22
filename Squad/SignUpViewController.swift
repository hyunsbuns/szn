//
//  SignUpViewController.swift
//  Squad
//
//  Created by Steve on 11/19/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func signupBtn(_ sender: AnyObject)
    {
        
        //signUpUser()
        
    }
    
    
   
    @IBAction func loginButtonPressed(_ sender: AnyObject)
    {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateProf" {
        let destinationVC : CreateProfileVC = segue.destination as! CreateProfileVC
        
        destinationVC.userUserName = emailTextField.text!
        destinationVC.userPassword = passwordTextField.text!
        
        }
        
    }
    /* func signUpUser(){
        
        
        let user = PFUser()
        user.username = emailTextField.text
        user.password = passwordTextField.text
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
            } else {
                print("Signed up")
                // Hooray! Let them use the app now.
            }
        }
    }
    */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        
        textfield.resignFirstResponder()
        return true
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
