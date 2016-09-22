//
//  OnboardViewController.swift
//  Squad
//
//  Created by Steve on 4/5/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit
import VideoSplash
import Spring
import Parse
import ParseUI
import ParseFacebookUtilsV4
import FBSDKLoginKit
import FBSDKCoreKit

class OnboardViewController: VideoSplashViewController, UITextFieldDelegate
{
    
    //insert into class if implementing pageview:UIPageViewControllerDataSource
    
    /*var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    */
    
    @IBOutlet weak var buttonContainer: SpringView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var textFieldContainer: SpringView!
    @IBOutlet weak var logo: SpringImageView!
    @IBOutlet weak var fbConnectView: SpringView!
    @IBOutlet weak var backBtn: SpringButton!
    
    @IBOutlet weak var signUpTextFieldContainer: SpringView!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpPwTextField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
 

    override func viewDidLoad()
    {
        super.viewDidLoad()
        SquadCore.onboardVC = self
        self.setupVideoBackground()
        
        self.fbConnectView.layer.cornerRadius = min(fbConnectView.layer.frame.width, fbConnectView.layer.frame.height)/2
        self.fbConnectView.clipsToBounds = true
        self.fbConnectView.isHidden = true 
        
        self.textFieldContainer.layer.cornerRadius = 3
        self.textFieldContainer.clipsToBounds = true
        
        self.loginBtn.layer.cornerRadius = 3
        self.loginBtn.clipsToBounds = true
        
        self.textFieldContainer.isHidden = true
        self.loginBtn.isHidden = true
        
        self.backBtn.isHidden = true
        self.signUpTextFieldContainer.isHidden = true
        if(SquadCore.connectedToInternet())
        {
            if(PFUser.current() != nil)
            {
                //Retrieve the current list of users
                SquadCore.allUsers = SquadCore.getUsers()
                if(SquadCore.allUsers != nil)
                {
                    self.doLoginStuff(PFUser.current()!)
                }
            }
        }
        else
        {
            PFUser.logOut()
        }
        
        self.emailTextField.delegate = self
        self.pwTextField.delegate = self
        self.signUpEmailTextField.delegate = self
        self.signUpPwTextField.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(!SquadCore.connectedToInternet())
        {
            self.noInternetFunc()
        }
    }
 
    
    func noInternetFunc()
    {
        let alert = UIAlertController(title: "No Internet", message: "An Internet connection is required for this app.", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
            if(SquadCore.connectedToInternet())
            {
                SquadCore.appDelegateInternetRequiredStartupStuff()
            }
            else
            {
                self.noInternetFunc()
            }
        }
        alert.addAction(retryAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateProf" {
            let destinationVC : CreateProfileVC = segue.destination as! CreateProfileVC
            
            destinationVC.userUserName = signUpEmailTextField.text!
            destinationVC.userPassword = signUpPwTextField.text!
            
        }
        
    }
    
    func setupVideoBackground()
    {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "intro", ofType: "mp4")!)
        //self.videoURL = url
        
        
        self.contentURL = url
        self.videoFrame = view.frame
        self.fillMode = .resizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 0.0
        self.duration = 20.0
        self.alpha = 0.8
        self.backgroundColor = UIColor.black
        self.restartForeground = true
        
    }
    
    @IBAction func bringInLoginContainer (_ sender: AnyObject) {
        
        self.textFieldContainer.isHidden = false
        self.loginBtn.isHidden = false
        self.textFieldContainer.animation = "slideDown"
        self.textFieldContainer.animate()
        
        self.logo.transform = CGAffineTransform(translationX: -600, y: 0)
        self.buttonContainer.isHidden = true
        self.backBtn.isHidden = false
        
        self.fbConnectView.isHidden = false
        self.fbConnectView.animation = "slideUp"
        self.fbConnectView.animate()
        
    }
    
    @IBAction func bringInSignUpContainer(_ sender: AnyObject) {
        
        self.signUpTextFieldContainer.isHidden = false
        self.signUpTextFieldContainer.animation = "slideDown"
        self.signUpTextFieldContainer.animate()
        
        self.logo.transform = CGAffineTransform(translationX: -600, y: 0)
        self.buttonContainer.isHidden = true
        self.backBtn.isHidden = false
        
        self.fbConnectView.isHidden = false
        self.fbConnectView.animation = "slideUp"
        self.fbConnectView.animate()
    }
    
    @IBAction func loginBtnPressed(_ sender: AnyObject) {
        
        
        let user = PFUser()
        user.username = emailTextField.text
        user.password = pwTextField.text
        
        PFUser.logInWithUsername(inBackground: user.username!, password: user.password!) { (user: PFUser?, error: Error?) in
                if user != nil
                {
                    //Retrieve the current list of users
                    SquadCore.allUsers = SquadCore.getUsers()
                    
                    self.doLoginStuff(user!)
                }
                else
                {
                    //login failed
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
        }
        
    }
 
    @IBAction func fbConnectBtnPressed(_ sender: AnyObject)
    {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile"]) { (user: PFUser?, error: Error?) in
            if let user = user
            {
                if user.isNew
                {
                    let params = ["fields": "first_name, last_name, email"]
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: params)
                    req?.start(completionHandler: { (conn: FBSDKGraphRequestConnection?, obj: Any?, error: Error?) in
                        let fbData = obj as! NSDictionary
                        let fname = fbData["first_name"] as! String
                        let lname = fbData["last_name"] as! String
                        let email = fbData["email"] as! String
                        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: ["fields":"url"])
                        pictureRequest?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                            if error == nil
                            {
                                let pictureDict = (result as! NSDictionary)["data"] as! NSDictionary
                                let url = URL(string: pictureDict["url"] as! String)
                                let image = UIImage(data: try! Data(contentsOf: url!))
                                let imageName = SquadCore.storeImage(image!, fileName: nil, profileImage: true)
                                user["firstName"] = fname
                                user["lastName"] = lname
                                user["imageName"] = imageName
                                user["username"] = email 
                                user.saveInBackground()
                                self.doLoginStuff(user)
                            }
                            else
                            {
                                //print("\(error)")
                                user.deleteInBackground()
                            }
                        })
                    })
                    
                }
                else
                {
                    self.doLoginStuff(user)
                }
            }
            else
            {
                //print("Uh oh. The user cancelled the Facebook login.")
            }
        }
        
        
    }
    
    func doLoginStuff(_ user: PFUser)
    {
        self.emailTextField.text = ""
        self.pwTextField.text = ""
        SquadCore.postLoginStuff(user, sourceVC: self)
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        
        self.textFieldContainer.isHidden = true
        self.loginBtn.isHidden = true
        self.signUpTextFieldContainer.isHidden = true 
        
        self.logo.transform = CGAffineTransform(translationX: 0, y: 0)
        self.buttonContainer.isHidden = false
        self.buttonContainer.animation = "slideUp"
        self.buttonContainer.animate()
        
        self.backBtn.isHidden = true
        
        self.fbConnectView.isHidden = true 
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        
        textfield.resignFirstResponder()
        return true
        
    }
    
    /*
    
    func viewControllerAtIndex(index: Int)-> ContentViewController
    {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count))
        {
            return ContentViewController()
        }
        
        var vc : ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        var vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
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
