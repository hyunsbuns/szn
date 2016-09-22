//
//  CreateSkwadTableViewController.swift
//  Squad
//
//  Created by Steve on 1/26/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class CreateSkwadTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
{

    @IBOutlet weak var skwadNameTextField: UITextField!
    @IBOutlet weak var seasonNameTextField: UITextField!
    //@IBOutlet weak var skwadPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var selectedSportLabel: UILabel!
    @IBOutlet weak var teamImage: UIImageView!
    
    var imageSet = false
    var selectedSport : PFObject!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set the default sport to nothing
        self.selectedSport = nil
        
        //self.view.backgroundColor = nightColor
        
        SquadCore.createSkwadVC_TVC = self
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNextCondensed-Medium", size: 16)!]
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        
        
    }
    
    @IBAction func addTeamImageBtnPressed(_ sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [AnyHashable: Any]?)
    {
        teamImage.image = image
        self.imageSet = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: AnyObject)
    {
        if (SquadCore.createSkwadVC_TVC.skwadNameTextField.text?.characters.count == 0)
        {
            let alertController = UIAlertController(title: "Error", message: "Enter a Skwad name", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                //print("You've pressed OK button");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
        else if (SquadCore.createSkwadVC_TVC.seasonNameTextField.text?.characters.count == 0)
        {
            let alertController = UIAlertController(title: "Error", message: "Enter a Season name", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                //print("You've pressed OK button");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
        else if (!self.imageSet)
        {
            let alertController = UIAlertController(title: "Error", message: "You must select an image", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                //print("You've pressed OK button");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        else if (self.selectedSport == nil)
        {
            let alertController = UIAlertController(title: "Error", message: "You must select a sport!", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                //print("You've pressed OK button");
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        else
        {
            let squad = PFObject(className:"Squad")
            squad["owner_id"] = SquadCore.currentUser
            squad["name"] = SquadCore.createSkwadVC_TVC.skwadNameTextField.text
            squad["sport"] = self.selectedSport
            squad["password"] = "abc123"
            let today = 14.days.fromNow
            squad["premium_expiration"] = today
            squad.add(SquadCore.currentUser, forKey: "players")
            squad.acl?.getPublicWriteAccess = true
            
            let imageName = SquadCore.storeImage(self.teamImage.image!, fileName: "", profileImage: false)
            //squad["teamImage"] = imageFile
            squad["imageName"] = imageName
            
            squad.saveInBackground
            {
                    (success: Bool, error: Error?) -> Void in
                    if (success)
                    {
                        //Add an initial season for this squad
                        let season = PFObject(className: "Season")
                        season["name"] = self.seasonNameTextField.text!
                        season["isActive"] = true
                        season["squad"] = squad
                        season.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                            if(success)
                            {
                                let obj = PFObject(className: "Player")
                                obj["isActive"] = true
                                obj["dummy"] = false
                                obj["user"] = SquadCore.currentUser
                                obj["squad"] = squad
                                obj.saveInBackground(block: { (success: Bool, error: Error?) in
                                    
                                    if(success)
                                    {
                                        SquadCore.addSquadToMainVC(squad)
                                        
                                        let alert = UIAlertController(title: "Success", message: "The Skwad has been created and 14 days of Premium Service has been added to your account.", preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                            self.dismiss(animated: true, completion: nil )
                                        })
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    else
                                    {
                                        //initial player failed, undo everything
                                        squad.deleteInBackground()
                                        season.deleteInBackground()
                                        let alert = UIAlertController(title: "Error", message: "There was a problem creating the Skwad, please try again shortly.", preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                                
                            }
                            else
                            {
                                //problem saving the season undo everything
                                squad.deleteInBackground()
                                let alert = UIAlertController(title: "Error", message: "There was a problem creating the Skwad, please try again shortly.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                        
                    }
                    else
                    {
                        // There was a problem, check error.description
                        let alertController = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            //print("You've pressed OK button");
                        }
                        
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool
    {
        
        skwadNameTextField.resignFirstResponder()
        //skwadPasswordTextField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject)
    {
        
        self.dismiss(animated: true, completion: nil )
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func selectedCategory (_ segue: UIStoryboardSegue)
    {
        let selectedCategoryViewController = segue.source as! SelectSportTVC
        
        if let sport = selectedCategoryViewController.selectedSport
        {
            selectedSportLabel.text = sport.value(forKey: "name") as? String
            self.selectedSport = sport
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Something Else"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    /*override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        //header.contentView.backgroundColor = UIColor(red: 0/255, green: 181/255, blue: 229/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        //header.alpha = 0.5 //make the header transparent
    }*/
    
    /*@IBAction func selectedCategory (segue: UIStoryboardSegue) {
        let selectedSportTVC = segue.sourceViewController as! SelectSportTVC
        
        if let selectedCategory = selectedSportTVC.pickedCategory {
            selectedSportLabel.text = selectedCategory
        }
    }
    */
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "tvEmbed") {
            
            let newViewController = segue.destinationViewController as! CreateSkwadVC
            
            self.skwadNameTextField.text = newViewController.skwadName as String
            
            self.skwadPasswordTextField.text = newViewController.skwadPassword as String
            
    }*/


}

