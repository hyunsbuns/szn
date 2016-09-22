//
//  CreateEventVC.swift
//  Squad
//
//  Created by Steve on 1/11/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class CreateEventVC: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var opponentNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerChanged()
        
        //opponentNameTF.attributedPlaceholder = NSAttributedString(string:"OPPONENT NAME",
        //attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //check to see if a location is set, and display it in the location label
        if(SquadCore.selectedLocation != nil)
        {
            self.locationLabel.text = SquadCore.selectedLocation.name!
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: AnyObject)
    {
        //make sure they selected a location
        if(SquadCore.selectedLocation != nil)
        {
            let event = PFObject(className:"TeamEvent")
            event["owner_id"] = SquadCore.selectedSquad
            event["opponent_name"] = self.opponentNameTF.text!
            event["lat"] = SquadCore.selectedLocation.location.coordinate.latitude
            event["lon"] = SquadCore.selectedLocation.location.coordinate.longitude
            event["date"] = self.datePicker.date
            event["season"] = SquadCore.currentActiveSeason
            event["location"] = self.locationLabel.text!
            event["deleted"] = false
            event.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                //create an initial score record
                let obj = PFObject(className: "Score")
                obj.setValue(event, forKey: "event")
                obj.setValue(0, forKey: "score")
                obj.setValue(0, forKey: "opponent_score")
                obj.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                    SquadCore.addEventToScheduleVC(event, score: obj)
                    SquadCore.selectedLocation = nil
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
        else
        {
            //Show error for not picking a location!!!!!
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject)
    {
        SquadCore.selectedLocation = nil
        self.dismiss(animated: true, completion: nil )
    }
    
    var datePickerHidden = false
    


    func datePickerChanged () {
        dateLabel.text = DateFormatter.localizedString(from: datePicker.date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    }
    
    @IBAction func datePickerValue(_ sender: AnyObject) {
        datePickerChanged()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            toggleDatepicker()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleDatepicker() {
        
        datePickerHidden = !datePickerHidden
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        opponentNameTF.resignFirstResponder()
        //locationTF.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
