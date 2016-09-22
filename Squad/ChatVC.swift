//
//  ChatVC.swift
//  Squad
//
//  Created by Michael Litman on 12/17/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import Firebase
//import FirebaseDatabase
//import FirebaseDatabaseUI

class ChatVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var chatTV: UITextView!
    @IBOutlet weak var chatEntryView: UIView!
    //@IBOutlet weak var chatBorder: UIView!

    var resizeTextView : UITextView!
    var theMessages = [ChatObject]()
    var origChatTextBoxFrame : CGRect!
    let firebaseRef = SquadCore.FirebaseRootRef.child("Chat")
    //var dataSource: FirebaseTableViewDataSource!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                /*
        self.dataSource = FirebaseTableViewDataSource(ref: self.firebaseRef, prototypeReuseIdentifier: "customCell", view: self.theTableView)
        self.dataSource.populateCellWithBlock{ (cell: UITableViewCell, obj: NSObject) -> Void in
            let snap = obj as! FDataSnapshot
            
            // Populate cell as you see fit, like as below
            let val = snap.value as! NSDictionary
            let theCell = cell as! ChatTableViewCell
            
            let obj = ChatObject(ownerID: val["owner_id"]! as! String, squadID: val["squad_id"]! as! String, message: val["message"]! as! String, timeSince1970: val["timesince1970"] as! Double)
            self.theMessages.append(obj)
            
            let message = obj.message
            
            let owner = obj.ownerID
            let user = SquadCore.getUser(owner, roster: SquadCore.selectedSquadRoster)
            if(user != nil)
            {
                let fname = user!["firstName"] as! String
                let lname = user!["lastName"] as! String
                theCell.ownerLabel.text = "\(fname) \(lname)"
                theCell.messageTextView.text = message
                theCell.messageTextView.sizeToFit()
                let timeStamp = NSDate(timeIntervalSince1970: obj.timeSince1970)
                theCell.timeStampLabel.text = self.calcTimeStamp(timeStamp)
                theCell.ownerImage.file = user!.valueForKey("profilePhoto") as? PFFile
                theCell.ownerImage.loadInBackground()
            }
            self.fastScrollToBottom()
        }
        self.theTableView.dataSource = self.dataSource
        */
        //keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //self.chatEntryView.hidden = true
        self.view.backgroundColor = asphaltColor    
        
        self.resizeTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 318, height: 47))
        
        
        /*addCommentBtn.layer.cornerRadius = min(addCommentBtn.layer.frame.width, addCommentBtn.layer.frame.height)/2
        addCommentBtn.layer.masksToBounds = true */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //chatBorder.layer.cornerRadius = 15
        self.getFirebaseChatMessages()
    }
    
    
    func keyboardWillAppear(_ notification: Notification)
    {
        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.origChatTextBoxFrame = self.chatEntryView.frame
            let origX = self.chatEntryView.frame.origin.x
            let origHeight = self.chatEntryView.frame.size.height
            let origWidth = self.chatEntryView.frame.size.width
            self.chatEntryView.translatesAutoresizingMaskIntoConstraints = true
            self.chatEntryView.frame = CGRect(x: origX, y: keyboardSize.origin.y - origHeight, width: origWidth, height: origHeight)
            chatEntryView.isHidden = false
            
        }
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        if (((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil
        {
            self.chatEntryView.frame = self.origChatTextBoxFrame
            chatEntryView.isHidden = false
        }
    }
    
    
    func getFirebaseChatMessages()
    {
        /*
        let ref = SquadCore.FirebaseRootRef.child("Chat")
        ref.queryOrderedByChild("squad_id").queryEqualToValue(SquadCore.selectedSquad.objectId!).observeEventType(.ChildAdded) { (snapshot : FIRDataSnapshot!) -> Void in
            if(snapshot != nil)
            {
                let val = snapshot.value as! NSDictionary
                //print(val["message"])
                let obj = ChatObject(ownerID: val["owner_id"]! as! String, squadID: val["squad_id"]! as! String, message: val["message"]! as! String, timeSince1970: val["timesince1970"] as! Double)
                self.theMessages.append(obj)
                let path = NSIndexPath(forRow: self.theMessages.count-1, inSection: 0)
                self.theTableView.insertRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.scrollToBottom()
            }
        }
 */
    }
    
    
    func fastScrollToBottom()
    {
        self.theTableView.scrollToRow(at: IndexPath(row: self.theMessages.count-1, section: 0), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func scrollToBottom()
    {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if(self.theMessages.count > 0)
            {
                self.theTableView.scrollToRow(at: IndexPath(row: self.theMessages.count-1, section: 0), at: UITableViewScrollPosition.top, animated: false)
            }
        }) 
        
    }
    
    func resetChatEntry()
    {
        self.chatTV.text = ""
    }
    
    @IBAction func hideKeyBoardButtonPressed(_ sender: AnyObject)
    {
        self.chatTV.resignFirstResponder()
    }
    
    @IBAction func commentPostButtonPressed(_ sender: AnyObject)
    {
        
        // Write data to Firebase
        let chatMessage = ["squad_id" : SquadCore.selectedSquad.objectId!, "owner_id": SquadCore.currentUser.objectId!, "message" : self.chatTV.text!, "timesince1970" : Date().timeIntervalSince1970] as [String : Any]
        SquadCore.FirebaseRootRef.child("Chat").childByAutoId().setValue(chatMessage)
        self.resetChatEntry()
    }
    
    @IBAction func commentCancelButtonPressed(_ sender: AnyObject)
    {
        self.resetChatEntry()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UICollectionViewDataSource

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.theMessages.count
    }
    
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        self.resizeTextView.text = SquadCore.theMessages[indexPath.row].valueForKey("message") as! String
        return self.resizeTextView.contentSize.height + 50
    }
*/
    func calcTimeStamp(_ date : Date) -> String
    {
        let now = Date()
        let minutes = Int(now.timeIntervalSince(date)/60)
        let hours = Int(minutes / 60)
        let days = Int(hours / 24)
        let weeks = Int(days / 7)
        var answer = ""
        if(minutes < 60)
        {
            answer = "\(minutes)m ago"
        }
        else if minutes >= 60 && hours < 24
        {
            answer = "\(hours)h ago"
        }
        else if hours >= 24 && days < 14
        {
            answer = "\(days)d ago"
        }
        else
        {
            answer = "\(weeks)w ago"
        }
        return answer
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatTableViewCell
    
        let obj = self.theMessages[(indexPath as NSIndexPath).row]
        let message = obj.message
        let owner = obj.ownerID
        let player = SquadCore.getPlayer(owner, roster: SquadCore.selectedSquadRoster)
        if(player != nil)
        {
            let user = player!["user"] as! PFUser
            //try! user.fetchIfNeeded()
            let fname = user["firstName"] as! String
            let lname = user["lastName"] as! String
            cell.ownerLabel.text = "\(fname) \(lname)"
            cell.messageTextView.text = message
            cell.messageTextView.sizeToFit()
            let timeStamp = Date(timeIntervalSince1970: obj.timeSince1970)
            cell.timeStampLabel.text = self.calcTimeStamp(timeStamp)
            let imageName = user["imageName"]
            if(imageName != nil)
            {
                SquadCore.getImage(iv: cell.ownerImage, imageName: imageName as! String, profileImage: true)
            }
        }
        return cell

    }
}
