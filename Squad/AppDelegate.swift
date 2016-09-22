//
//  AppDelegate.swift
//  Squad
//
//  Created by admin on 11/17/15.
//  Copyright © 2015 squad. All rights reserved.
//

import UIKit
import Parse
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
//import FirebaseDatabase
import AWSCore
import AWSS3
import FBSDKCoreKit
import ParseFacebookUtilsV4
import GoogleMaps
import SwiftInAppPurchase

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    let goldColor: UIColor = UIColor( red: CGFloat(184/255.0), green: CGFloat(170/255.0), blue: CGFloat(108/255.0), alpha: CGFloat(100.0) )
    
    let asphaltColor: UIColor = UIColor( red: CGFloat(28/255.0), green: CGFloat(28/255.0), blue: CGFloat(31/255.0), alpha: CGFloat(100.0) )
    
    let nightColor: UIColor = UIColor( red: CGFloat(18/255.0), green: CGFloat(19/255.0), blue: CGFloat(20/255.0), alpha: CGFloat(100.0) )
    
    let pigeonColor: UIColor = UIColor( red: CGFloat(136/255.0), green: CGFloat(137/255.0), blue: CGFloat(140/255.0), alpha: CGFloat(100.0) )
    
    let skwadDarkGrey: UIColor = UIColor( red: CGFloat(12/255.0), green: CGFloat(12/255.0), blue: CGFloat(12/255.0), alpha: CGFloat(100.0) )
    
    let LGColor: UIColor = UIColor( red: CGFloat(208/255.0), green: CGFloat(208/255.0), blue: CGFloat(208/255.0), alpha: CGFloat(100.0) )
    
    let neonOrange: UIColor = UIColor( red: CGFloat(247/255.0), green: CGFloat(74/255.0), blue: CGFloat(46/255.0), alpha: CGFloat(100.0) )
    
    let photoBlue: UIColor = UIColor( red: CGFloat(63/255.0), green: CGFloat(166/255.0), blue: CGFloat(252/255.0), alpha: CGFloat(100.0) )
    
    let darkblue: UIColor = UIColor( red: CGFloat(11/255.0), green: CGFloat(137/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(100.0) )
    
    let infrared: UIColor = UIColor( red: CGFloat(252/255.0), green: CGFloat(75/255.0), blue: CGFloat(56/255.0), alpha: CGFloat(100.0) )
    
    
    let grapeColor: UIColor = UIColor( red: CGFloat(62/255.0), green: CGFloat(53/255.0), blue: CGFloat(148/255.0), alpha: CGFloat(100.0) )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        if(SquadCore.connectedToInternet())
        {
            SquadCore.appDelegateInternetRequiredStartupStuff()
        }
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Firebase Auth
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageSuccess), name: NSNotification.Name.FIRMessagingSendSuccess, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageError), name: NSNotification.Name.FIRMessagingSendError, object: nil)

        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.titleTextAttributes = [NSFontAttributeName : UIFont(name: "AvenirNext-Regular", size: 18)!, NSForegroundColorAttributeName : UIColor.white]
        
        navigationBarAppearance.tintColor = UIColor.white
        
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.barTintColor = asphaltColor
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
        UITabBar.appearance().barTintColor = UIColor.white
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: asphaltColor], for: .selected)
        
        UITabBar.appearance().tintColor = asphaltColor
 
        return true
    }

    
    func switchViewControllers(_ vc : UIViewController)
    {
        self.window?.rootViewController = vc
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func sendMessageSuccess(_ notification: Notification)
    {
        //print(notification)
    }
    
    func sendMessageError(_ notification: Notification)
    {
        //print(notification)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        if(SquadCore.connectedToInternet())
        {
            FBSDKAppEvents.activateApp()
            connectToFcm()
        }
    }
    
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        FIRMessaging.messaging().disconnect()
        //print("Disconnected from FCM.")
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        //print("Received Message")
        //print(userInfo)
        //print("Message: \(userInfo["aps"])")
        //print("Message: \(userInfo["objectId"])")
        let eventID = userInfo["objectId"] as? String
        //print(eventID)
        let uid = userInfo["uid"] as? String
        
        if(eventID != nil)
        {
            let query = PFQuery(className: "TeamEvent")
            query.whereKey("objectId", equalTo: eventID!)
            query.findObjectsInBackground(block: { (objects : [PFObject]?, error: Error?) in
                //print(error)
                if(error == nil && objects!.count == 1)
                {
                    //print(objects?.count)
                    //print(objects.debugDescription)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let event = objects!.first
                    let vc = storyboard.instantiateViewController(withIdentifier: "RollCallVC") as! RollCallVC
                    vc.event = event!
                    vc.isPushResponse = true
                    vc.uid = uid
                    
                    vc.opponentName = event!["opponent_name"] as! String
                    let date = event!["date"] as! Date
                    vc.date_time = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
                    vc.imageName = SquadCore.getRollCallStatus(SquadCore.currentUser, event: event!)
                    let launchVC = SquadCore.getCurrentViewController()
                    if(launchVC != nil)
                    {
                        if(application.applicationState == UIApplicationState.active)
                        {
                            let pushAlert = UIAlertController(title: "Roll Call Confirm", message: "A Roll Call has been requested.", preferredStyle: .alert)
                            let participateAction = UIAlertAction(title: "Participate", style: .default, handler: { (action:UIAlertAction) in
                                launchVC!.present(vc, animated: true, completion: nil)
                            })
                            let ignoreAction = UIAlertAction(title: "Ignore", style: .cancel, handler: nil)
                            pushAlert.addAction(participateAction)
                            pushAlert.addAction(ignoreAction)
                            launchVC!.present(pushAlert, animated: true, completion: nil)
                        }
                        else
                        {
                            launchVC!.present(vc, animated: true, completion: nil)
                        }
                        
                    }
                    else
                    {
                        //self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if(PFUser.current() != nil)
                        {
                            self.window?.rootViewController = vc
                            self.window?.makeKeyAndVisible()
                        }
                        else
                        {
                            //Trying to make app goto login screen on push when logged out and app not running
                            //**** NOT WORKING
                            let vc = storyboard.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
                            self.window?.rootViewController = vc
                            self.window?.makeKeyAndVisible()
                        }
                        //self.window?.rootViewController = vc
                        //self.window?.makeKeyAndVisible()
                    }
                    
                }
            })
        }
    }
    // [END receive_message]
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification)
    {
        let refreshedToken = FIRInstanceID.instanceID().token()
        if(refreshedToken != nil)
        {
            //print(FIRInstanceID.instanceID().token())
            SquadCore.pushToken = FIRInstanceID.instanceID().token()
            // Connect to FCM since connection may have failed when attempted before having a token.
            connectToFcm()
        }
    }
    
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm()
    {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil)
            {
                //print("Unable to connect with FCM. \(error)")
            }
            else
            {
                //print("Connected to FCM.")
            }
        }
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    func registerForPushNotifications(_ application: UIApplication)
    {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
    {
        if notificationSettings.types != UIUserNotificationType()
        {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
        //print(FIRInstanceID.instanceID().token())
        //print("Device Token:", tokenString)
        SquadCore.pushToken = FIRInstanceID.instanceID().token()
    }
    /*
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    */
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}

