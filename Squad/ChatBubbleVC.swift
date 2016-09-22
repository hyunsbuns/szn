//
//  ChatBubbleVC.swift
//  Squad
//
//  Created by Michael Litman on 3/23/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
//import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import ParseUI

class ChatBubbleVC: UIViewController//JSQMessagesViewController
{
    /*
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.setupBubbles()
        
        //self.title = "Group Chat"
        
        //avatar image size
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 35, height: 35)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 35, height: 35)
        
        //hide attachement button
        self.inputToolbar.contentView!.leftBarButtonItem = nil
        //self.senderId = SquadCore.currentUser.objectId!
        //self.senderDisplayName = "\(SquadCore.currentUser["firstName"]) \(SquadCore.currentUser["lastName"])"
        
        self.getFirebaseChatMessages()
        
    }

    func getFirebaseChatMessages()
    {
        //let ref = SquadCore.FirebaseRootRef.childByAppendingPath("Chat")
        let ref = SquadCore.FirebaseRootRef.child("Chat").child(SquadCore.selectedSquad.objectId!)
        
        ref.queryLimited(toLast: 10).observe(.childAdded) { (snapshot : FIRDataSnapshot!) -> Void in
            if(snapshot != nil)
            {
                let val = snapshot.value as! NSDictionary
                let id = val["owner_id"]! as! String
                let text = val["message"]! as! String
                let timeSince1970 = val["timesince1970"]! as! TimeInterval
                let date = Date(timeIntervalSince1970: timeSince1970)
                let player = SquadCore.getPlayer(id, roster: SquadCore.selectedSquadRoster)
                let user = player!["user"] as! PFUser
                //try! user.fetchIfNeeded()
                let fname = user["firstName"] as! String
                let lname = user["lastName"] as! String
                let displayName = "\(fname) \(lname)"
                self.addMessage(id, displayName: displayName, text: text, date: date)
                self.finishReceivingMessage()
            }
        }
    }

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

    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: Date!)
    {
        let chatMessage = ["squad_id" : SquadCore.selectedSquad.objectId!, "owner_id": senderId, "message" : text, "timesince1970" : date.timeIntervalSince1970] as [String : Any]
        SquadCore.FirebaseRootRef.child("Chat").child(SquadCore.selectedSquad.objectId!).childByAutoId().setValue(chatMessage) { (error: NSError?, db: FIRDatabaseReference) in
            if(error != nil)
            {
                //print(error?.localizedDescription)
            }
        }
        finishSendingMessage()
    }
    
    func addMessage(_ id: String, displayName: String, text: String, date: Date)
    {
        let message = JSQMessage(senderId: id, senderDisplayName: displayName, date: date, text: text)
        messages.append(message)
    }

    fileprivate func setupBubbles()
    {
        let factory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())

        incomingBubbleImageView = factory.incomingMessagesBubbleImage(
            with: skwadDarkGrey)

        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource?
    {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId()
        { // 2
            return outgoingBubbleImageView
        }
        else
        { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        let message = self.messages[indexPath.row]
        let player = SquadCore.getPlayer(message.senderId, roster: SquadCore.selectedSquadRoster)
        let user = player!["user"] as! PFUser
        //try! user.fetchIfNeeded()
        let fname = user["firstName"] as! String
        let lname = user["lastName"] as! String
        let initials = "\(fname.characters.first!)\(lname.characters.first!)"
        let imageView = UIImageView()
        /*
        let returnedImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.boldSystemFont(ofSize: 4), diameter: 10)
        let imageName = user["imageName"]
        if(imageName != nil)
        {
            //print(imageName as! String)
            imageView.image = UIImage(named: "Logo")
            SquadCore.getImageJSQ(imageView, imageName: imageName as! String, returnedImage: returnedImage!)
            //returnedImage.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(imageView.image, withDiameter: 35)
        }
        */
        
        //imageView.file = user!["profilePhoto"] as! PFFile
        //imageView.loadInBackground { (image: UIImage?, error: NSError?) in
            //returnedImage.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: 35)
        //}
        return nil
       // return JSQMessagesAvatarImage.avatar(with: returnedImage!.avatarImage)
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData
    {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 20
    }
    
    /*override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.item]
        return NSAttributedString(string: self.calcTimeStamp(message.date))
    }*/
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 20
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.item]
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        return NSAttributedString(string: self.calcTimeStamp(message.date))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        return NSAttributedString(string: self.calcTimeStamp(message.date))
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[(indexPath as NSIndexPath).item]
        
        if message.senderId == senderId()
        {
            cell.textView!.textColor = UIColor.black
            cell.textView!.backgroundColor = UIColor.jsq_messageBubbleLightGray()
            //cell.textView!.font = UIFont(name: "AvenirNext-Regular", size: 16)
            cell.textView!.layer.cornerRadius = 5
            cell.textView!.clipsToBounds = true
        }
        else
        {
            cell.textView!.textColor = UIColor.white
            cell.textView!.backgroundColor = skwadDarkGrey
            //cell.textView!.font = UIFont(name: "AvenirNext-Regular", size: 16)
            cell.textView!.layer.cornerRadius = 5
            cell.textView!.clipsToBounds = true
        }
        return cell
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
 */

}
