//
//  TeamProfileVC.swift
//  Squad
//
//  Created by Michael Litman on 7/17/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class TeamProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var teamImage: UIImageView!
    var imageChanged = false
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navBar.tintColor = UIColor.white
        
        self.view.backgroundColor = asphaltColor
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            cancelBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            saveBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.teamName.text = SquadCore.selectedSquad["name"] as? String
        SquadCore.getImage(iv: self.teamImage, imageName: SquadCore.selectedSquad["imageName"] as! String, profileImage: false)
        
        self.teamImage.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [AnyHashable: Any]?)
    {
        self.teamImage.image = image
        self.imageChanged = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func updateImageButtonPressed(_ sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func validateForm() -> Bool
    {
        var message = ""
        if(self.teamName.text == "")
        {
            message = "You must enter a team name"
        }
        
        if(message == "")
        {
            return true
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    @IBAction func saveButtonPressed()
    {
        if(self.validateForm())
        {
            if(self.imageChanged)
            {
                SquadCore.storeImage(self.teamImage.image!, fileName: SquadCore.selectedSquad["imageName"] as? String, profileImage: false)
            }
            SquadCore.selectedSquad["name"] = self.teamName.text!
            SquadCore.selectedSquad.saveInBackground(block: { (success: Bool, error: Error?) in
                if(success)
                {
                    let alert = UIAlertController(title: "Success", message: "Changes will be visible the next time you login", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertController(title: "Error", message: "Something went wrong, try again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
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
