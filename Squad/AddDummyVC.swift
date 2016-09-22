//
//  AddDummyVC.swift
//  Squad
//
//  Created by Michael Litman on 6/8/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse
import Spring

class AddDummyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate
{
    var data : [PFObject]!
    var checked = [Bool]()
    var numChecked = 0
    var parentRosterVC : RosterVC!
    var parentProfileVC : ProfileVC!
    
    var editMode = false
    var player : PFObject!
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var jerseyNumberTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    //@IBOutlet weak var container: SpringView!
    @IBOutlet weak var textContainer: SpringView!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.isOpaque = false
        
        self.textContainer.layer.cornerRadius = 5
        self.textContainer.clipsToBounds = true
        
        self.imageButton.layer.cornerRadius = min(imageButton.layer.frame.width, imageButton.layer.frame.height)/2
        self.imageButton.clipsToBounds = true
        
        self.errorLabel.isHidden = true
        let query = PFQuery(className: "Positions")
        query.whereKey("sport", equalTo: SquadCore.selectedSquad["sport"] as! PFObject)
        data = try! query.findObjects()
        
        /*if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            view.insertSubview(blurEffectView, atIndex: 0)
        } 
        else {
            self.view.backgroundColor = UIColor.blackColor()
        }*/
        
        if(self.editMode)
        {
            self.firstNameTF.text = self.player["firstName"] as? String
            self.lastNameTF.text = self.player["lastName"] as? String
            self.jerseyNumberTF.text = self.player["jersey_number"] as? String
            SquadCore.getImageForButton(self.imageButton, imageName: self.player["imageName"] as! String, profileImage: true)
            for position in data
            {
                var currPosition = self.player["position1"] as! PFObject
                if(currPosition.objectId! == position.objectId!)
                {
                    checked.append(true)
                    numChecked += 1
                    continue
                }
                
                currPosition = self.player["position2"] as! PFObject
                if(currPosition.objectId! == position.objectId!)
                {
                    checked.append(true)
                    numChecked += 1
                    continue
                }
                checked.append(false)
            }
        }
        else
        {
            for _ in data
            {
                checked.append(false)
            }

        }
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func validateForm() -> Bool
    {
        var message = ""
        if(self.firstNameTF.text == "")
        {
            message = "You must enter a first name!"
        }
        else if(self.lastNameTF.text == "")
        {
            message = "You must enter a last name!"
        }
        if(message == "")
        {
            self.errorLabel.text = ""
            self.errorLabel.isHidden = true
            return true
        }
        else
        {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
            return false
        }
    }
    
    @IBAction func saveButtonPressed()
    {
        if(self.validateForm())
        {
            if(self.editMode)
            {
                player["firstName"] = self.firstNameTF.text!
                player["lastName"] = self.lastNameTF.text!
                player["dummy"] = true
                player["jersey_number"] = self.jerseyNumberTF.text!
                player["squad"] = SquadCore.selectedSquad
                SquadCore.storeImage(self.imageButton.currentBackgroundImage!, fileName: player["imageName"] as? String, profileImage: true)
                var numSet = 0
                var pos = 0
                for position in self.data
                {
                    if(self.checked[pos])
                    {
                        if(numSet == 0)
                        {
                            player["position1"] = position
                            numSet += 1
                        }
                        else
                        {
                            player["position2"] = position
                            numSet += 1
                        }
                    }
                    pos += 1
                }
                player.saveInBackground(block: { (success: Bool, error:Error?) in
                    if(success)
                    {
                        //Update profileVC accordingly
                        self.parentProfileVC.player = self.player
                        self.parentProfileVC.loadData()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
            else
            {
                let player = PFObject(className: "Player")
                player["firstName"] = self.firstNameTF.text!
                player["lastName"] = self.lastNameTF.text!
                player["dummy"] = true
                player["isAdmin"] = false
                player["isActive"] = true
                player["jersey_number"] = self.jerseyNumberTF.text!
                player["squad"] = SquadCore.selectedSquad
                player["imageName"] = SquadCore.storeImage(self.imageButton.currentBackgroundImage!, fileName: nil, profileImage: true)
                var numSet = 0
                var pos = 0
                for position in self.data
                {
                    if(self.checked[pos])
                    {
                        if(numSet == 0)
                        {
                            player["position1"] = position
                            numSet += 1
                        }
                        else
                        {
                            player["position2"] = position
                            numSet += 1
                        }
                    }
                    pos += 1
                }
                player.saveInBackground(block: { (success: Bool, error:Error?) in
                    if(success)
                    {
                        //update the roster and dismiss
                        SquadCore.selectedSquadRoster.append(player)
                        self.parentRosterVC.tableView.reloadData()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
            self.errorLabel.isHidden = true
        }
        else
        {
            if(numChecked == 2)
            {
                self.errorLabel.text = "You can only have 2 positions"
                self.errorLabel.isHidden = false
            }
            else
            {
                self.checked[(indexPath as NSIndexPath).row] = true
                cell?.accessoryType = .checkmark
                self.numChecked += 1
                self.errorLabel.isHidden = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        
        textfield.resignFirstResponder()
        return true
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
