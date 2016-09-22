//
//  EditProfileVC.swift
//  Squad
//
//  Created by Michael Litman on 5/7/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class EditProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    var data : [PFObject]!
    var checked = [Bool]()
    var numChecked = 0

    @IBOutlet weak var imageButton: UIButton!
    //@IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var jerseyNumberTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navBar.tintColor = UIColor.white
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            saveBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        if let font = UIFont(name: "AvenirNext-Regular", size: 15) {
            cancelBtn.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        self.navBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
        //self.errorLabel.hidden = true
        let query = PFQuery(className: "Positions")
        query.whereKey("sport", equalTo: SquadCore.selectedSquad["sport"] as! PFObject)
        data = try! query.findObjects()
        
        let firstName = SquadCore.currentUser["firstName"]
        if (firstName != nil)
        {
            self.firstNameTF.text = firstName as? String
        }
        
        let lastName = SquadCore.currentUser["lastName"]
        if (lastName != nil)
        {
            self.lastNameTF.text = lastName as? String
        }
        
        let imageName = SquadCore.currentUser["imageName"]
        if(imageName != nil)
        {
            SquadCore.getImageForButton(imageButton, imageName: (imageName as? String)!, profileImage: true)
        }
        
        let jersey_number = SquadCore.currentPlayer["jersey_number"]
        if(jersey_number != nil)
        {
            self.jerseyNumberTF.text = jersey_number as? String
        }
        
        
        for position in data
        {
            var currPosition = SquadCore.currentPlayer["position1"] as! PFObject
            if(currPosition.objectId! == position.objectId!)
            {
                checked.append(true)
                numChecked += 1
                continue
            }
            
            currPosition = SquadCore.currentPlayer["position2"] as! PFObject
            if(currPosition.objectId! == position.objectId!)
            {
                checked.append(true)
                numChecked += 1
                continue
            }
            checked.append(false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [AnyHashable: Any]?)
    {
        //profilePicIV.image = image
        self.imageButton.setBackgroundImage(image, for: UIControlState())
        self.imageButton.setBackgroundImage(image, for: .selected)
        self.imageButton.setBackgroundImage(image, for: .highlighted)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addProfPicBtn(_ sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject?)
    {
        let user = SquadCore.currentUser
        let player = SquadCore.currentPlayer
        user?["firstName"] = self.firstNameTF.text
        user?["lastName"] = self.lastNameTF.text
        if(user?["imageName"] != nil)
        {
            SquadCore.storeImage(self.imageButton.currentBackgroundImage!, fileName: user?["imageName"] as? String, profileImage: true)
        }
        else
        {
            user?["imageName"] = SquadCore.storeImage(self.imageButton.currentBackgroundImage!, fileName: nil, profileImage: true)
        }
        player?["jersey_number"] = self.jerseyNumberTF.text
        var numSet = 0
        var pos = 0
        for position in self.data
        {
            if(self.checked[pos])
            {
                if(numSet == 0)
                {
                    player?["position1"] = position
                    numSet += 1
                }
                else
                {
                    player?["position2"] = position
                    numSet += 1
                }
            }
            pos += 1
        }
        player?.saveInBackground(block: { (success: Bool, error: Error?) in
            if(success)
            {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[(indexPath as NSIndexPath).row]["position"] as? String
        if(self.checked[(indexPath as NSIndexPath).row])
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath)
        if(self.checked[(indexPath as NSIndexPath).row])
        {
            self.checked[(indexPath as NSIndexPath).row] = false
            cell?.accessoryType = .none
            self.numChecked -= 1
            //self.errorLabel.hidden = true
        }
        else
        {
            self.checked[(indexPath as NSIndexPath).row] = true
            cell?.accessoryType = .checkmark
            self.numChecked += 1
            //self.errorLabel.hidden = true
            
        }
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
