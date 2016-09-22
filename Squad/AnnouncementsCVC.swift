//
//  AnnouncementsCVC.swift
//  Squad
//
//  Created by Michael Litman on 7/9/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import Parse

class AnnouncementsCVC: UICollectionViewController
{
    var data = [PFObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let query = PFQuery(className: "Announcements")
        query.whereKey("squad", equalTo: SquadCore.selectedSquad)
        query.order(byDescending: "timestamp")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if(error == nil)
            {
                self.data.append(contentsOf: objects!)
                self.collectionView?.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of items
        return self.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AnnouncementCVCell
    
        // Configure the cell
        let obj = self.data[(indexPath as NSIndexPath).row]
        let title = obj["title"] as! String
        let message = obj["message"] as! String
        let timeStamp = obj["timestamp"] as! Date
        cell.titleTF.text = title
        cell.textView.text = message
        cell.timestampTF.text = (timeStamp as NSDate).aws_stringValue("M/dd/yyyy")
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier != nil)
        {
            if(segue.identifier == "New Announcement")
            {
                let vc = segue.destination as! NewAnnouncementVC
                vc.announcementsCVC = self
            }
        }
    }

}
