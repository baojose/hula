//
//  HLProfileViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import TwitterKit
import CoreLocation


class HLProfileViewController: BaseViewController {
    
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var settingsAlertBadge: UIImageView!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNickLabel: UILabel!
    @IBOutlet weak var userFeedbackLabel: UILabel!
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    @IBOutlet weak var verFacebookIcon: UIImageView!
    @IBOutlet weak var verLinkedinIcon: UIImageView!
    @IBOutlet weak var verTwitterIcon: UIImageView!
    @IBOutlet weak var verMailIcon: UIImageView!
    @IBOutlet weak var completeProfileTooltip: UIView!
    @IBOutlet weak var viewFeedbackBtn: UIButton!
    @IBOutlet weak var fullsizeViewReference: UIView!
    
    
    var arrFeedback: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
        self.getUserProfile()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if !HulaUser.sharedInstance.isUserLoggedIn() {
            
            self.tabBarController?.selectedIndex = 0
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        /*
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
        }
         */
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing for segue...")
        if let destinationVC = segue.destination as? HLFeedbackHistoryViewController{
            destinationVC.feedbackList = arrFeedback
            print("Total feedback: \(destinationVC.feedbackList.count)")
        }
    }
    
    
    func initData() {
        arrFeedback = []
    }
    func initView() {
        commonUtils.circleImageView(profileImageView)
        mainScrollView.contentSize = CGSize(width: 0, height: fullsizeViewReference.frame.size.height + 100)
        mainScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        
        settingsAlertBadge.alpha = 0
        completeProfileTooltip.alpha = 0
    }
    
    // IB Actions
    
    @IBAction func closeTooltip(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.completeProfileTooltip.alpha = 0
        })
    }
    
    @IBAction func validateAction(_ sender: Any) {
        let alert = UIAlertController(title: "Select a verification method",
                                       message: nil,
                                       preferredStyle: .actionSheet)
        
        if HulaUser.sharedInstance.fbToken.characters.count == 0 {
            let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { action -> Void in
                self.facebookValidate()
            })
            alert.addAction(facebookAction)
        }
        
        let linkedinAction = UIAlertAction(title: "Linkedin", style: .default, handler: nil)
        alert.addAction(linkedinAction)
        
        
        if HulaUser.sharedInstance.twToken.characters.count == 0 {
            let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { action -> Void in
                self.twitterValidate()
            })
            alert.addAction(twitterAction)
        }
        
        
        if HulaUser.sharedInstance.status != "verified" {
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: { action -> Void in
                self.emailValidate()
            })
            alert.addAction(emailAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    
    
    
    
    func facebookValidate(){
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                print(grantedPermissions)
                print(declinedPermissions)
                HulaUser.sharedInstance.fbToken = accessToken.authenticationToken as String
                self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
                self.verFacebookIcon.bouncer()
                HulaUser.sharedInstance.updateServerData()
            }
        }
    }
    
    
    func twitterValidate(){
        
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if let unwrappedSession = session {
                print(unwrappedSession);
                /*
                let alert = UIAlertController(title: "Logged In", message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
                 */
                
                self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                self.verTwitterIcon.bouncer()
                HulaUser.sharedInstance.twToken = unwrappedSession.authToken as String
                HulaUser.sharedInstance.updateServerData()
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        })
    }
    
    
    func emailValidate(){
        
        HulaUser.sharedInstance.resendValidationMail()
        let alert = UIAlertController(title: "Email validation", message: "We have just sent you an email to \(HulaUser.sharedInstance.userEmail!). Please follow the instructions provided on that message.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Custom functions for ViewController
    
    func getUserProfile() {
        
        //print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "users/" + HulaUser.sharedInstance.userId
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        //print(dictionary)
                        if let user = dictionary["user"] as? [String: Any] {
                            if (user["name"] as? String) != nil {
                                HulaUser.sharedInstance.userName = user["name"] as? String
                            }
                            if (user["nick"] as? String) != nil {
                                HulaUser.sharedInstance.userNick = user["nick"] as? String
                            }
                            if (user["bio"] as? String) != nil {
                                HulaUser.sharedInstance.userBio = user["bio"] as? String
                            }
                            if (user["email"] as? String) != nil {
                                HulaUser.sharedInstance.userEmail = user["email"] as? String
                            }
                            if (user["image"] as? String) != nil {
                                HulaUser.sharedInstance.userPhotoURL = user["image"] as? String
                                //self.commonUtils.loadImageOnView(imageView:self.profileImageView, withURL:HulaUser.sharedInstance.userPhotoURL)
                                self.profileImageView.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
                            }
                            
                            if (user["location_name"] as? String) != nil {
                                HulaUser.sharedInstance.userLocationName = user["location_name"] as? String
                            }
                            
                            if let loc = user["location"] as? [CGFloat] {
                                let lat = loc[0]
                                let lon = loc[1]
                                HulaUser.sharedInstance.location = CLLocation(latitude:CLLocationDegrees(lat), longitude:CLLocationDegrees(lon));
                                print(HulaUser.sharedInstance.location)
                            }
                            
                            if let fbt = (user["fb_token"] as? String) {
                                if (fbt != ""){
                                    HulaUser.sharedInstance.fbToken = fbt
                                    self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
                                    self.verFacebookIcon.bouncer()
                                }
                            }
                            if let lit = (user["li_token"] as? String) {
                                if (lit != ""){
                                    HulaUser.sharedInstance.liToken = user["li_token"] as? String
                                    self.verLinkedinIcon.image = UIImage(named: "icon_linkedin_on")
                                    self.verLinkedinIcon.bouncer()
                                }
                            }
                            if let twt = (user["tw_token"] as? String){
                                if (twt != ""){
                                    HulaUser.sharedInstance.twToken = user["tw_token"] as? String
                                    self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                                    self.verTwitterIcon.bouncer()
                                }
                            }
                            if let uStatus = (user["status"] as? String) {
                                if (uStatus == "verified"){
                                    HulaUser.sharedInstance.status = user["status"] as? String
                                    self.verMailIcon.image = UIImage(named: "icon_mail_on")
                                    self.verMailIcon.bouncer()
                                }
                            }
                            
                            if (user["feedback_count"] as? CGFloat) != nil {
                                
                                let feedback_points:CGFloat = (user["feedback_points"] as? CGFloat)!
                                let feedback_count:CGFloat = (user["feedback_count"] as? CGFloat)!
                                if (feedback_count>0){
                                    let perc: Int =  Int(round( feedback_points/feedback_count * 100))
                                    self.userFeedbackLabel.text = "\(perc)%"
                                } else {
                                    self.userFeedbackLabel.text = "-"
                                }
                            }
                        }
                        if let feedback = dictionary["feedback"] as? NSArray {
                            self.arrFeedback = feedback
                            //print(self.arrFeedback)
                        }
                    }
                    self.userFullNameLabel.text = HulaUser.sharedInstance.userName
                    self.userNickLabel.text = HulaUser.sharedInstance.userNick
                    self.userBioLabel.text = HulaUser.sharedInstance.userBio
                    if (HulaUser.sharedInstance.isIncompleteProfile()){
                        // badges to inform the user
                        UIView.animate(withDuration: 0.4, animations: {
                            self.completeProfileTooltip.alpha = 1
                            self.settingsAlertBadge.alpha = 1
                        })
                    }
                }
            } else {
                // connection error
            }
        })
    }
}
