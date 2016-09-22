//
//  SquadCore.swift
//  Squad
//
//  Created by Michael Litman on 11/19/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import LocationPicker
import Firebase
import FirebaseInstanceID
//import FirebaseMessaging
import Alamofire
import AWSS3
import AWSCore
import SwiftDate
//import JSQMessagesViewController
import FirebaseDatabase
import FBSDKCoreKit
import ParseFacebookUtilsV4
import GoogleMaps
import SwiftInAppPurchase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SquadCore: NSObject
{
    //Global
    static var IAPids = ["token", "token5", "token10", "token25"]
    static var IAPqty = [1, 5, 10, 25]
    static var IAPtitles = ["1 Token", "5 Pack of Tokens", "10 Pack of Tokens", "25 Pack of Tokens"]
    static var IAPprices = ["$0.99", "$4.99", "$9.99", "$24.99"]
    static var premiumEnabled = false
    static var pushToken : String!
    static var mainVC : MainVC!
    static var onboardVC : OnboardViewController!
    static var currentUser : PFUser!
    static var currentPlayer : PFObject!
    static var allUsers : [PFUser]! = nil
    static var currentSeasonSelectorDelegate : SeasonSelectorDelegate!
    static var currentActiveSeason : PFObject!
    static var storyBoard : UIStoryboard!
    static var profile_ReloadStats = true
    static var sznstats_ReloadStats = true
    static var eventStatCache = [String : [StatTotals]]()
    static var currentStatRecords : [PFObject]!
    static var selectedLocation: Location!
    static var imageCache = [String : UIImage]()
    
    static var daysOfWeek: [String:String] = [
        "Sunday" : "SUN",
        "Monday" : "MON",
        "Tuesday" : "TUE",
        "Wednesday" : "WED",
        "Thursday" : "THU",
        "Friday" : "FRI",
        "Saturday" : "SAT",
    ]
    
    static var monthsOfYear: [String:String] = [
        "January" : "JAN",
        "February" : "FEB",
        "March" : "MAR",
        "April" : "APR",
        "May" : "MAY",
        "June" : "JUN",
        "July" : "JUL",
        "August" : "AUG",
        "September" : "SEP",
        "October" : "OCT",
        "November" : "NOV",
        "December" : "DEC",
    ]
    
    static var FirebaseRootRef : FIRDatabaseReference!
    
    //Firebase(url:"https://skwad.firebaseio.com")
    static var currentSkwadCredits = 0
    
    static func premiumMinutesLeft(_ expires: Date) -> Int
    {
        let now = Date()
        if(expires < now)
        {
            return 0
        }
        else
        {
            let diff = expires.difference(to: now, componentFlags: Set<Calendar.Component>([.minute]))
            return abs(diff.minute!)
        }
    }
    
    static func premiumMinutesToTimeLeftString(_ minutes: Int) -> String
    {
        var mins = minutes
        var hours = mins/60
        mins = mins%60
        let days = hours/24
        hours = hours%24
        return "\(days):\(hours):\(mins)"
    }
    
    static func setPremium(_ expires: Date)
    {
        let now = Date()
        if(expires < now)
        {
            //print("Premium Expired")
            premiumEnabled = false
        }
        else
        {
            //print("Premium Active")
            premiumEnabled = true
        }
        
    }
    
    static func appDelegateInternetRequiredStartupStuff()
    {
        SwiftInAppPurchase.sharedInstance.setProductionMode(false)
        var productIden = Set<String>()
        for id in SquadCore.IAPids
        {
            productIden.insert(id)
            
        }
        
        let iap = SwiftInAppPurchase.sharedInstance
        
        iap.requestProducts(productIden) { (products, invalidIdentifiers, error) -> () in
            for _ in products!
            {
                //print(product.productIdentifier)
                //print(product.localizedDescription)
            }
        }
        //Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyCj99DRnVge7lSbnH-RuELVWWCxbojIgMc")
        
        //AWS Cognito Authentication Stuff
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.usEast1,
                                                                identityPoolId:"us-east-1:dae0da51-db7c-4f06-aabd-2676da86124f")
        
        let configuration = AWSServiceConfiguration(region:.usEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        FIRApp.configure()
        SquadCore.FirebaseRootRef = FIRDatabase.database().reference()
        
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "skwadParse"
            $0.clientKey = ""
            $0.server = "https://skwad-parse.herokuapp.com/parse"
        }
        Parse.initialize(with: parseConfig)
        /*
         Parse.enableLocalDatastore()
         Parse.setApplicationId("SyoorAERNMXX3bDnZwwMkcBbo8hpYy6mDwmtdlm3",
         clientKey: "sCGPZ37TTYi82811musfSKE5ELjnJIWQoRxRz5Aa")
         */
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.getPublicReadAccess = true
        PFACL.setDefault(defaultACL, withAccessForCurrentUser:true)
    }
    
    static func connectedToInternet() -> Bool
    {
        let myURLString = "http://google.com"
        guard let myURL = URL(string: myURLString) else {
            //print("Error: \(myURLString) doesn't seem to be a valid URL")
            return false
        }
        
        do
        {
            let myHTMLString = try NSString(contentsOf: myURL, encoding: String.Encoding.isoLatin1.rawValue)
            print("HTML : \(myHTMLString)")
            return true
        }
        catch let error as NSError
        {
            print("Error: \(error)")
            return false
        }
    }
    
    static func homeReset()
    {
        premiumEnabled = false
        currentPlayer = nil
        //currentActiveSeason = nil
        eventStatCache.removeAll()
        currentStatRecords = nil
        currentStatTotals = nil
        selectedEvent = nil
        selectedSquad = nil
        selectedSquadStats.removeAll()
        selectedSquadEvents.removeAll()
        selectedSquadRoster.removeAll()
        selectedSquadEventScores.removeAll()
        selectedSquadFilteredEvents.removeAll()
        profile_ReloadStats = true
        sznstats_ReloadStats = true
    }
    
    static func isSquadAdmin(_ user: PFUser) -> Bool
    {
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] == nil)
            {
                continue
            }
            if(player["isAdmin"] as! Bool)
            {
                let user = player["user"] as! PFUser
                if(user.objectId! == SquadCore.currentUser.objectId!)
                {
                    return true
                }
            }
        }
        return false
    }
    
    static func postLoginStuff(_ user: PFUser, sourceVC: UIViewController)
    {
        SquadCore.currentUser = user
        
        let query = PFQuery(className: "Player")
        query.whereKey("user", equalTo: user)
        query.whereKey("isActive", equalTo: true)
        query.includeKeys(["user","squad"])
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            SquadCore.theSquads = [PFObject]()
            if(objects != nil)
            {
                for player in objects!
                {
                    let squad = player["squad"] as! PFObject
                    //try! squad.fetchIfNeeded()
                    SquadCore.theSquads.append(squad)
                }
            }
            
            //make sure our push token is saved
            if(SquadCore.pushToken != nil)
            {
                let pushQuery = PFQuery(className: "PushMap")
                pushQuery.whereKey("user", equalTo: user)
                pushQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if(objects?.count == 0)
                    {
                        let obj = PFObject(className: "PushMap")
                        obj["user"] = user
                        obj["token"] = SquadCore.pushToken
                        obj.saveInBackground()
                    }
                    else
                    {
                        let obj = objects!.first!
                        obj["token"] = SquadCore.pushToken
                        obj.saveInBackground()
                    }
                })
            }
            let mnc = sourceVC.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
            sourceVC.present(mnc, animated: false, completion: nil)
        }
    }
    
    // Returns the navigation controller if it exists
    static func getNavigationController() -> UINavigationController?
    {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController
        {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    // Returns the most recently presented UIViewController (visible)
    static func getCurrentViewController() -> UIViewController?
    {
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = SquadCore.getNavigationController()
        {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController
        {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    static func drawText(_ text: NSString, image: UIImage, point: CGPoint) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(in: CGRect(x: 0,y: 0,width: image.size.width,height: image.size.height))
        let rect = CGRect(x: point.x, y: point.y, width: image.size.width, height: image.size.height)
        UIColor.white.set()
        let font = UIFont.boldSystemFont(ofSize: 21)
        let att = [NSFontAttributeName:font,NSForegroundColorAttributeName:UIColor.white]
        text.draw(in: rect, withAttributes: att)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!

    /*
        UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0f);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    if([text respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
    //iOS 7
    NSDictionary *att = @{NSFontAttributeName:font};
    [text drawInRect:rect withAttributes:att];
    }
    else
    {
    //legacy support
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
 */
    }
    
    static func rollCall(_ event: PFObject)
    {
        let opponent = event["opponent_name"] as! String
        let date = event["date"] as! Date
        let message = "Attending: \(opponent) on \((date as NSDate).aws_stringValue("M/dd/yyyy"))?"
        var data = [String: String]()
        data["objectId"] = event.objectId!
        
        var users = [PFUser]()
        for player in SquadCore.selectedSquadRoster
        {
            if(player["user"] != nil)
            {
                users.append(player["user"] as! PFUser)
            }
        }
        
        let query = PFQuery(className: "PushMap")
        query.whereKey("user", containedIn: users)
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for obj in objects!
            {
                let token = obj["token"] as! String
                let user = obj["user"] as! PFUser
                data["uid"] = user.objectId!
                if(currentUser.objectId! == user.objectId!)
                {
                    continue
                }
                fcmSendMessage(token, title: "Roll Call", message: message, data: data)
            }
        }
    }
    
    static func fcmSendMessage(_ to: String, title: String, message: String, data: [String: String])
    {
        let params: Parameters = ["to": to, "content_available": false, "priority":"high","notification":["sound":"default","title":title,"body":message],"data":data]
        /*
        var params = [String : AnyObject]()
        params["to"] = to as AnyObject?
        params["content_available"] = false as AnyObject?
        params["priority"] = "high" as AnyObject?
        let val : [String: String] = ["sound":"default","title":title,"body":message]
        params["notification"] = val as AnyObject
        params["data"] = data as AnyObject?
         Alamofire.request(.POST, "https://fcm.googleapis.com/fcm/send", parameters: params, encoding: .JSON, headers: headers)
 */
        let headers = ["Content-Type":"application/json","Authorization":"key=AIzaSyAFSAzOGo1tW0WE_4UxtcQQLic03SXq62A"]
        Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            _ = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
            //print(tempString)
        }
    }
    
    //AWS Image Stuff
    static func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage
    {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(newImage!, 0.5);
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
    
    static func storeImage(_ fullSizeImage: UIImage, fileName: String?, profileImage: Bool) -> String
    {
        // Construct the upload request.
        var hashString = fileName
        if(hashString == nil || hashString == "")
        {
            let date = Date()
            let hashableString = NSString(format: "%f", date.timeIntervalSinceReferenceDate)
            hashString = hashableString.aws_md5() + ".png"
        }
        var maxWidth = CGFloat(600)
        if(profileImage)
        {
            maxWidth = CGFloat(300)
        }
        let image = resizeImage(fullSizeImage, newWidth: maxWidth)
        let path:NSString = "\(NSTemporaryDirectory())\(hashString!)" as NSString
        let imageData = UIImagePNGRepresentation(image)
        try? imageData!.write(to: URL(fileURLWithPath: path as String), options: [.atomic])
        let url: URL = URL(fileURLWithPath: path as String)
        let uploadRequest: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        // set the bucket
        var folder = "/skwad_logos"
        if(profileImage)
        {
            folder = "/profile_images"
        }

        uploadRequest.bucket = "skwad\(folder)"
        uploadRequest.key = hashString!
        uploadRequest.contentType =
        "png"
        uploadRequest.body = url
        uploadRequest.uploadProgress = { (currSent, totalSent, totalExpected) in
            DispatchQueue.main.sync(execute: { () -> Void in
                //print("\(totalSent) of \(totalExpected) bytes sent")
            })
        }
        let transferManager:AWSS3TransferManager =
            AWSS3TransferManager.default()
        transferManager.upload(uploadRequest)
        imageCache[hashString!] = image
        return hashString!
    }
    
    static func deleteImage(_ imageName : String, profileImage: Bool)
    {
        let deleteRequest = AWSS3DeleteObjectRequest.init()
        var folder = "/skwad_logos"
        if(profileImage)
        {
            folder = "/profile_images"
        }

        deleteRequest?.bucket = "skwad\(folder)";
        deleteRequest?.key = imageName;
        let s3 = AWSS3.default()
        s3.deleteObject(deleteRequest!)
    }
    
    /*
    static func getImageJSQ(_ iv: UIImageView, imageName: String, returnedImage: JSQMessagesAvatarImage)
    {
        if(imageName == "")
        {
            return
        }
        
        let cachedImage = imageCache[imageName]
        if(cachedImage != nil)
        {
            iv.image = cachedImage
            /*
            returnedImage.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(iv.image, withDiameter: 35)
 */
            return
        }
        
        // Construct the NSURL for the download location.
        let downloadingFilePath = NSTemporaryDirectory() + imageName
        
        let downloadingFileURL = URL(fileURLWithPath: downloadingFilePath)
        
        // Construct the download request.
        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        let folder = "/profile_images"
        downloadRequest?.bucket = "skwad\(folder)";
        downloadRequest?.key = imageName;
        downloadRequest?.downloadingFileURL = downloadingFileURL;

        let transferManager:AWSS3TransferManager =
            AWSS3TransferManager.default()
        transferManager.download(downloadRequest).continue(  {(task:AWSTask) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let image = UIImage(contentsOfFile: downloadingFilePath)
                iv.image = image!
                imageCache[imageName] = image!
                returnedImage.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(iv.image, withDiameter: 35)
            })
            return nil
        })
        
    }
    */
    static func getImage(iv: UIImageView, imageName: String, profileImage: Bool)
    {
        if(imageName == "")
        {
            return
        }
        
        let cachedImage = imageCache[imageName]
        if(cachedImage != nil)
        {
            iv.image = cachedImage
            return
        }
        
        //let imagePath = NSBundle.mainBundle().pathForResource("imageLoading", ofType: "gif")
        //let loadingImage = UIImage.gifWithData(NSData(contentsOfFile: imagePath!)!)
        //iv.image = loadingImage
        
        // Construct the NSURL for the download location.
        let downloadingFilePath = NSTemporaryDirectory() + imageName
        
        let downloadingFileURL = URL(fileURLWithPath: downloadingFilePath)
        
        // Construct the download request.
        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        var folder = "/skwad_logos"
        if(profileImage)
        {
            folder = "/profile_images"
        }
        downloadRequest?.bucket = "skwad\(folder)";
        downloadRequest?.key = imageName;
        downloadRequest?.downloadingFileURL = downloadingFileURL;
        
        let transferManager = AWSS3TransferManager.default()
        transferManager?.download(downloadRequest).continue(  {(task:AWSTask) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let image = UIImage(contentsOfFile: downloadingFilePath)
                iv.image = image!
                imageCache[imageName] = image!
            })
            return nil
        })
 
    }

    static func getImageForButton(_ imageButton: UIButton, imageName: String, profileImage: Bool)
    {
        if(imageName == "")
        {
            return
        }
        
        let cachedImage = imageCache[imageName]
        if(cachedImage != nil)
        {
            imageButton.setBackgroundImage(cachedImage, for: UIControlState())
            imageButton.setBackgroundImage(cachedImage, for: .selected)
            imageButton.setBackgroundImage(cachedImage, for: .highlighted)
            return
        }
        
        //let imagePath = NSBundle.mainBundle().pathForResource("imageLoading", ofType: "gif")
        //let loadingImage = UIImage.gifWithData(NSData(contentsOfFile: imagePath!)!)
        //imageButton.setBackgroundImage(loadingImage, forState: .Normal)
        //imageButton.setBackgroundImage(loadingImage, forState: .Selected)
        //imageButton.setBackgroundImage(loadingImage, forState: .Highlighted)
        
        // Construct the NSURL for the download location.
        let downloadingFilePath = NSTemporaryDirectory() + imageName
        
        let downloadingFileURL = URL(fileURLWithPath: downloadingFilePath)
        
        // Construct the download request.
        let downloadRequest = AWSS3TransferManagerDownloadRequest.init()
        var folder = "/skwad_logos"
        if(profileImage)
        {
            folder = "/profile_images"
        }
        downloadRequest?.bucket = "skwad\(folder)";
        downloadRequest?.key = imageName;
        downloadRequest?.downloadingFileURL = downloadingFileURL;
        
        let transferManager = AWSS3TransferManager.default()
        transferManager?.download(downloadRequest).continue(  {(task:AWSTask) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                let image = UIImage(contentsOfFile: downloadingFilePath)
                imageButton.setBackgroundImage(image!, for: .normal)
                imageButton.setBackgroundImage(image!, for: .selected)
                imageButton.setBackgroundImage(image!, for: .highlighted)
                imageCache[imageName] = image!
            })
            return nil
        })
    }

    static func sendSMS(_ msg : String, to : String)
    {
        let parameters: Parameters = [
            "text": msg + " " + to,
            "hash": "AP36dbdd97e5e72670f888278675e287c0",
            "to" : to
        ]
        Alamofire.request("https://skwad-twilio-server.herokuapp.com/sms", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            debugPrint(response)
        }
        /*
        Alamofire.request(.POST, "https://skwad-twilio-server.herokuapp.com/sms", parameters: parameters)
 */
    }
    
    static func getPlayer(_ user: PFUser, squad: PFObject)
    {
        let query = PFQuery(className: "Player")
        query.whereKey("user", equalTo: user)
        query.whereKey("squad", equalTo: squad)
        query.includeKey("user")
        let objects = try! query.findObjects()
        currentPlayer = objects.first!
    }
    
    static func setStatRefresh()
    {
        SquadCore.profile_ReloadStats = true
        SquadCore.sznstats_ReloadStats = true
    }

    static func getUsers() -> [PFUser]?
    {
        let query = PFUser.query()
        var users : [PFUser]!
        do
        {
            try users = query!.findObjects() as! [PFUser]
            return users
        }
        catch
        {
            return nil
        }
        
    }
    
    static func getSports() -> [PFObject]
    {
        let query = PFQuery(className: "Sport")
        return try! query.findObjects()
    }
    
    static func isAdmin(_ squad : PFObject, user : PFUser) -> Bool
    {
        return (squad.value(forKey: "owner_id") as! PFUser).objectId! == user.objectId! || SquadCore.isSquadAdmin(currentUser)
    }
    
    //The View Controllers
    static var homeVC : HomeVC!
    //static var scheduleVC : ScheduleVC!
    static var foldingScheduleVC : FoldScheduleVC!
    
    //MainVC
    static var selectedSquad : PFObject!
    static var selectedSquadStats : [PFObject]!
    static var theSquadsCollectionView: UICollectionView!
    static var theSquads : [PFObject]!
    static var currTeamImage : PFImageView!
    
    static func addSquadToMainVC(_ squad : PFObject)
    {
        theSquads.append(squad)
        theSquadsCollectionView.reloadData()
    }
    
    static func getStatWithShortName(_ sn: String) -> PFObject?
    {
        for stat in selectedSquadStats
        {
            if((stat["short_name"] as! String) == sn)
            {
                return stat
            }
        }
        return nil
    }
    
    static func getSquadStats(_ squad: PFObject)
    {
        let query = PFQuery(className: "Stats")
        query.whereKey("sport", equalTo: squad.value(forKey: "sport")!)
        query.includeKey("sport")
        selectedSquadStats = try! query.findObjects()
        
        let sport = SquadCore.selectedSquad["sport"] as! PFObject
        //try! sport.fetchIfNeeded()
        let statOrder = (sport["stat_order"] as! String).components(separatedBy: ",")
        var sortedStats = [PFObject]()
        for stat in statOrder
        {
            sortedStats.append(getStatWithShortName(stat)!)
        }
        selectedSquadStats = sortedStats
    }
    
    static func getSquadRoster(_ squad: PFObject)
    {
        SquadCore.selectedSquadRoster.removeAll()
        let query = PFQuery(className: "Player")
        query.whereKey("squad", equalTo: squad)
        query.whereKey("isActive", equalTo: true)
        query.includeKey("user")
        let players = try! query.findObjects()
        for player in players
        {
            SquadCore.selectedSquadRoster.append(player)
        }
    }
    
    static func getSquadSeasons(_ squad: PFObject) -> [PFObject]
    {
        let query = PFQuery(className: "Season")
        query.whereKey("squad", equalTo: squad).order(byAscending: "createdAt")
        return try! query.findObjects()
    }
    
    static func getActiveSeason(_ squad: PFObject) -> PFObject?
    {
        for season in SquadCore.seasonManagerSeasonList
        {
            if(season.value(forKey: "isActive") as! Bool)
            {
                return season
            }
        }
        return nil
    }
    
    //RollCallVC
    static func getRollCallStatus(_ user: PFUser, event: PFObject) -> String
    {
        let query = PFQuery(className: "RollCall")
        query.whereKey("user_id", equalTo: user)
        query.whereKey("event_id", equalTo: event)
        let objects = try! query.findObjects()
        if(objects.count > 0)
        {
            return objects.first?.value(forKey: "status") as! String
        }
        else
        {
            return "N/A"
        }
    }
    
    static func updateRollCallStatus(_ player : PFObject, event: PFObject, status: String)
    {
        let query = PFQuery(className: "RollCall")
        query.whereKey("player", equalTo: player)
        query.whereKey("event_id", equalTo: event)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if(objects?.count > 0)
            {
                //if we already have a status for this player for this event
                //and it has changed, update it
                let obj = objects?.first!
                let storedStatus = obj?.value(forKey: "status") as! String
                if(storedStatus != status)
                {
                    obj?.setValue(status, forKey: "status")
                    obj?.saveInBackground()
                }
            }
            else
            {
                //this is the first time a status is being made for this player/event
                let obj = PFObject(className: "RollCall")
                obj.setValue(player, forKey: "player")
                obj.setValue(event, forKey: "event_id")
                obj.setValue(status, forKey: "status")
                obj.saveInBackground()
            }
        }
    }
    
    //ChatVC
    static var theMessages : [PFObject]!
    static func getMessagesForSquad(_ squad : PFObject)
    {
        let query = PFQuery(className: "Chat")
        query.whereKey("squad_id", equalTo: squad)
        theMessages = try! query.findObjects()

    }
    
    static func getPlayer(_ ownerID: String, roster: [PFObject]) -> PFObject?
    {
        for player in roster
        {
            //print(player.debugDescription)
            if(player["user"] == nil)
            {
                continue
            }
            else
            {
                let user = player["user"] as! PFUser
                //try! user.fetchIfNeeded()
                if(user.objectId! == ownerID)
                {
                    return player
                }
            }
        }
        return nil
    }
    
    //RosterVC
    static var selectedSquadRoster = [PFObject]()
    
    static func getUserWithId(_ id: String) -> PFUser
    {
        for user in allUsers
        {
            if(user.objectId! == id)
            {
                return user
            }
        }
        return PFUser() //return a blank user
    }
    
    //PlayerVC
    //static var selectedPlayer : PFUser!
    static var selectedPlayerInfo : PFObject!
    
    //ScheduleVC
    static var selectedEvent : PFObject!
    static var selectedSquadEvents : [PFObject]!
    static var selectedSquadFilteredEvents = [PFObject]()
    static var selectedSquadEventScores : [PFObject]!
    static var ScheduleVC_CollectionView : UICollectionView!
    static var FoldScheduleVC_TableView : UITableView!
    static var lastFilterSetting = "Upcoming"
    
    static func addEventToScheduleVC(_ event : PFObject, score: PFObject)
    {
        //find the position of the last event that comes before this one
        let newDate = event.value(forKey: "date") as! Date
        var inserted = false
        for i in 0 ..< selectedSquadEvents.count
        {
            let currDate = selectedSquadEvents[i].value(forKey: "date") as! Date
            
            if(newDate.compare(currDate) == .orderedAscending)
            {
                selectedSquadEvents.insert(event, at: i)
                inserted = true
                break;
            }
        }
        if(!inserted)
        {
            selectedSquadEvents.append(event)
        }
        
        selectedSquadEventScores.append(score)
        if(lastFilterSetting == "Upcoming")
        {
            filterUpcomingEvents()
        }
        else
        {
            filterPastEvents()
        }
        FoldScheduleVC_TableView.reloadData()
    }
    
    static func getEventScoresGivenEvents(_ events : [PFObject]) -> [PFObject]?
    {
        let query = PFQuery(className: "Score")
        query.whereKey("event", containedIn: events)
        return try! query.findObjects()
    }
    
    //Give me all events across ALL seasons for this squad
    static func getEventsGivenSquad(_ theSquad : PFObject) -> [PFObject]?
    {
        let query = PFQuery(className: "TeamEvent")
        query.whereKey("owner_id", equalTo: theSquad)
        query.whereKey("deleted", equalTo: false)
        query.order(byAscending: "date")
        let results = try! query.findObjects()
        return results
    }
    
    static func filterUpcomingEvents()
    {
        lastFilterSetting = "Upcoming"
        //Fill FilteredEvents and Scores with all the elements from today forward
        selectedSquadFilteredEvents.removeAll()
        for event in selectedSquadEvents
        {
            let eventDate = event.value(forKey: "date") as! Date
            let today = Date()
            let season = event.value(forKey: "season") as! PFObject
            if((today.compare(eventDate) == .orderedAscending || today.compare(eventDate) == .orderedSame) && SquadCore.currentSeasonSelectorDelegate.currentSeason.objectId! == season.objectId!)
            {
                selectedSquadFilteredEvents.append(event)
            }
        }
    }
    
    static func filterPastEvents()
    {
        lastFilterSetting = "Past"
        //Fill FilteredEvents and Scores with all the elements from today forward
        selectedSquadFilteredEvents.removeAll()
        for event in selectedSquadEvents
        {
            let eventDate = event.value(forKey: "date") as! Date
            let today = Date()
            if(today.compare(eventDate) == .orderedDescending && SquadCore.currentSeasonSelectorDelegate.currentSeason == event.value(forKey: "season") as! PFObject)
            {
                selectedSquadFilteredEvents.append(event)
            }
        }
    }
    
    //GameStatsVC
    static var gameStatsSummaryTableView : UITableView!
    static var gameStatsStatCollections = [PFObject : StatCollection]()
    static var gameStatsEventScore : PFObject!
    
    static func getCurrentScore(_ event: PFObject) -> PFObject?
    {
        //print(event.debugDescription)
        for score in selectedSquadEventScores
        {
            let currEvent = score.value(forKey: "event") as! PFObject
            if(currEvent.objectId! == event.objectId!)
            {
                return score
            }
        }
        return nil
    }
    
    static func updateScore(_ score: Int, opponent_score: Int)
    {
        gameStatsEventScore.setValue(score, forKey: "score")
        gameStatsEventScore.setValue(opponent_score, forKey: "opponent_score")
        try! gameStatsEventScore.save()
    }
    
    static func getStatCollections(_ roster: [PFObject], event : PFObject, stats : [PFObject])
    {
        //if there is already some stat records lets see if they are already for this event,
        //so we don't hit parse for data we already have
        if(gameStatsStatCollections.count > 0 &&
            gameStatsStatCollections.values.first!.event.objectId! == event.objectId!)
        {
            return
        }
        
        //otherwise, get data from parse
        gameStatsStatCollections.removeAll()
        
        for player in roster
        {
            gameStatsStatCollections[player] = StatCollection(player: player, event: event, stats: stats)
        }
    }
    
    //SeasonManagerVC
    static var seasonManagerSeasonList : [PFObject]!
    static var seasonManagerTableView : UITableView!
    
    static func seasonManagerCreateNewSeason(_ name: String, squad: PFObject)
    {
        let obj = PFObject(className: "Season")
        obj.setValue(squad, forKey: "squad")
        obj.setValue(name, forKey: "name")
        SquadCore.seasonManagerSeasonList.append(obj)
        obj.saveInBackground()
    }
    
    //CreateSkwadVC
    static var createSkwadVC_TVC : CreateSkwadTableViewController!
    
    //SznVC
    static var currentStatTotals : [StatTotals]!
    static func getEventsGivenSeason(_ season: PFObject, events: [PFObject]) -> [PFObject]
    {
        var currSeasonEvents = [PFObject]()
        for event in events
        {
            let currSeason = event.value(forKey: "season") as! PFObject
            if( currSeason.objectId! == season.objectId!)
            {
                currSeasonEvents.append(event)
            }
        }
        return currSeasonEvents
    }
    
    //searches statTotals for the single StatTotals object that matches the provided PFUser
    static func getStatTotalGivenPlayer(_ player: PFObject, statTotals:[StatTotals]) -> StatTotals?
    {
        for statTotal in statTotals
        {
            if(statTotal.player.objectId! == player.objectId!)
            {
                return statTotal
            }
        }
        
        return StatTotals(player: player)
    }
    
    static func isStatCalculated(_ statName: String) -> Bool
    {
        for stat in SquadCore.selectedSquadStats
        {
            let name = stat["name"] as! String
            if(name.compare(statName) == ComparisonResult.orderedSame)
            {
                return (stat["calculated"] as! Bool)
            }
        }
        return false
    }
    
    static func sortStatAveragesGivenStat(_ stat: String, statTotals:[StatTotals]) -> [StatTotals]
    {
        var sortedTotals = [StatTotals]()
        var currTotals = [StatTotals]()
        currTotals.append(contentsOf: statTotals)
        var winningValue = -1.0
        var winningPos = -1
        var currPos = 0
        
        while(currTotals.count > 0)
        {
            //find the biggest total for the given stat
            winningValue = -1
            winningPos = -1
            currPos = 0
            for statTotal in currTotals
            {
                let currTotal = statTotal.getAverageForStat(stat)
                if(currTotal > winningValue)
                {
                    winningValue = currTotal
                    winningPos = currPos
                }
                currPos += 1
            }
            
            sortedTotals.insert(currTotals[winningPos], at: sortedTotals.count)
            currTotals.remove(at: winningPos)
        }
        return sortedTotals
    }

    static func sortStatTotalsGivenStat(_ stat: String, statTotals:[StatTotals]) -> [StatTotals]
    {
        var sortedTotals = [StatTotals]()
        var currTotals = [StatTotals]()
        currTotals.append(contentsOf: statTotals)
        var winningValue = -1.0
        var winningPos = -1
        var currPos = 0

        while(currTotals.count > 0)
        {
            //find the biggest total for the given stat
            winningValue = -1
            winningPos = 0
            currPos = 0
            for statTotal in currTotals
            {
                let currTotal = statTotal.getTotalForStat(stat)
                if(currTotal > winningValue)
                {
                    winningValue = currTotal
                    winningPos = currPos
                }
                currPos += 1
            }
            
            sortedTotals.insert(currTotals[winningPos], at: sortedTotals.count)
            currTotals.remove(at: winningPos)
        }
        return sortedTotals
    }
    
    static func getLeadersCached(_ season: PFObject, roster: [PFObject]) -> [StatTotals]
    {
        //create an array filled with StatTotal objects for each user in the current Roster
        var statTotals = [StatTotals]()
        for player in selectedSquadRoster
        {
            statTotals.append(StatTotals(player: player))
        }
        
        //get all the events for the passed in season
        let currSeasonEvents = getEventsGivenSeason(season, events: selectedSquadEvents)
        
        let records = SquadCore.currentStatRecords
        
        //loops through all events in this season add the stat collections from each event
        //to the appropriate StatTotals object for each player on the roster
        for event in currSeasonEvents
        {
            for player in roster
            {
                let statTotal = SquadCore.getStatTotalGivenPlayer(player, statTotals: statTotals)
                statTotal!.addStatCollection(StatCollection(player: player, event: event, stats: SquadCore.selectedSquadStats, statRecords: records!))
            }
        }
        
        //we now have all the stat totals for all the events for all the player on the roster for this season
        return statTotals
    }
    
    static func getCareerLeaders(_ roster: [PFObject]) -> [StatTotals]
    {
        //create an array filled with StatTotal objects for each user in the current Roster
        var statTotals = [StatTotals]()
        for player in roster
        {
            statTotals.append(StatTotals(player: player))
        }
        
        //get all the statRecords for all of the players on this roster for all of the events
        let query = PFQuery(className: "StatRecord")
        query.whereKey("player", containedIn: roster)
        query.limit = 1000
        query.includeKey("stat")
        var records : [PFObject]!
        try! records = query.findObjects()
        var allRecords = [PFObject]()
        var skip = 0
        while(records.count == 1000)
        {
            allRecords.append(contentsOf: records)
            skip += 1000
            query.skip = skip
            try! records = query.findObjects()
        }
        allRecords.append(contentsOf: records)
        SquadCore.currentStatRecords = allRecords
        
        //loops through all events in this season add the stat collections from each event
        //to the appropriate StatTotals object for each player on the roster
        for event in selectedSquadEvents
        {
            for player in roster
            {
                let statTotal = SquadCore.getStatTotalGivenPlayer(player, statTotals: statTotals)
                statTotal!.addStatCollection(StatCollection(player: player, event: event, stats: SquadCore.selectedSquadStats, statRecords: allRecords))
            }
        }
        
        //we now have all the stat totals for all the events for all the player on the roster for this season
        return statTotals
    }

    static var lastGetLeadersSeason : PFObject?
    static func getLeaders(_ season: PFObject, roster: [PFObject]) -> [StatTotals]
    {
        if(lastGetLeadersSeason != nil && lastGetLeadersSeason!.objectId! == season.objectId!)
        {
            return SquadCore.currentStatTotals
        }
        lastGetLeadersSeason = season
        
        if(roster.count == 1)
        {
            let totals = eventStatCache[season.objectId!]
            if(totals != nil)
            {
                return totals!
            }
        }
        //create an array filled with StatTotal objects for each user in the current Roster
        var statTotals = [StatTotals]()
        for player in roster
        {
            statTotals.append(StatTotals(player: player))
        }
        
        //get all the events for the passed in season
        let currSeasonEvents = getEventsGivenSeason(season, events: selectedSquadEvents)
        
        //get all the statRecords for all of the players on this roster for all of the events
        let query = PFQuery(className: "StatRecord")
        query.whereKey("player", containedIn: roster)
        query.whereKey("event", containedIn: currSeasonEvents)
        query.limit = 1000
        query.includeKey("stat")
        var records : [PFObject]!
        var allRecords = [PFObject]()
        var skip = 0
        try! records = query.findObjects()
        while(records.count == 1000)
        {
            allRecords.append(contentsOf: records)
            skip += 1000
            query.skip = skip
            try! records = query.findObjects()
        }
        allRecords.append(contentsOf: records)
        SquadCore.currentStatRecords = allRecords
        
        //loops through all events in this season add the stat collections from each event
        //to the appropriate StatTotals object for each player on the roster
        for event in currSeasonEvents
        {
            for player in roster
            {
                let statTotal = SquadCore.getStatTotalGivenPlayer(player, statTotals: statTotals)
                let sc = StatCollection(player: player, event: event, stats: SquadCore.selectedSquadStats, statRecords: allRecords)
                statTotal!.addStatCollection(sc)
            }
        }
        
        //we now have all the stat totals for all the events for all the player on the roster for this season
        if(roster.count == 1)
        {
            eventStatCache[season.objectId!] = statTotals
        }
        return statTotals
    }
}
