//
//  CreateProfileVC.swift
//  Squad
//
//  Created by Steve on 12/4/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse

class CreateProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    let user = PFUser()
    var userUserName = String()
    var userPassword = String()
    
    @IBAction func saveBtn(_ sender: AnyObject)
    {
        signUpUser()
    }
    
    @IBOutlet weak var profilePicIV: UIImageView!
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicIV.layer.cornerRadius = self.profilePicIV.frame.size.width / 2
        profilePicIV.clipsToBounds = true
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addProfPicBtn(_ sender: AnyObject)
    {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func signUpUser(){
        
        let user = PFUser()
        user.username = userUserName
        user.password = userPassword
        user["firstName"] = firstNameTF.text
        user["lastName"] = lastNameTF.text
        user["imageName"] = SquadCore.storeImage(self.profilePicIV.image!, fileName: nil, profileImage: true)
        //let imageData = UIImagePNGRepresentation(self.profilePicIV.image!)
        //let imageFile = PFFile(name: "profilePhoto.png", data: imageData!)
        //user["profilePhoto"] = imageFile
        
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                _ = (error._userInfo as! NSDictionary)["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                //print("Signed up")
                let loginVC = self.presentingViewController!.presentingViewController!
                loginVC.dismiss(animated: false, completion:{
                    SquadCore.postLoginStuff(user, sourceVC: loginVC)

                })

                //let mnc = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigationController") as! UINavigationController
                //self.presentViewController(mnc, animated: true, completion: nil)
                // Hooray! Let them use the app now.
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [AnyHashable: Any]?) {
        profilePicIV.image = image
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
