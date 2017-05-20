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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
        self.getUserProfile()
        
        
        
        
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
    
    func initData() {
    }
    func initView() {
        commonUtils.circleImageView(profileImageView)
        mainScrollView.contentSize = CGSize(width: 0, height: userBioLabel.frame.size.height + userBioLabel.frame.origin.y)
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
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { action -> Void in
                                            self.facebookValidate()
        })
        let linkedinAction = UIAlertAction(title: "Linkedin", style: .default, handler: nil)
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { action -> Void in
            self.twitterValidate()
        })
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: nil)
        
        alert.addAction(facebookAction)
        alert.addAction(linkedinAction)
        alert.addAction(twitterAction)
        alert.addAction(emailAction)
        
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
                HulaUser.sharedInstance.fbToken = accessToken.authenticationToken as String
                self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
            }
        }
    }
    
    
    func twitterValidate(){
        
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if let unwrappedSession = session {
                print(unwrappedSession);
                unwrappedSession.authToken
                let alert = UIAlertController(title: "Logged In",
                                              message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                HulaUser.sharedInstance.twToken = unwrappedSession.authToken as String
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        })
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
                                self.commonUtils.loadImageOnView(imageView:self.profileImageView, withURL:HulaUser.sharedInstance.userPhotoURL)
                            }
                            
                            
                            if let fbt = (user["fb_token"] as? String) {
                                if (fbt != ""){
                                    HulaUser.sharedInstance.fbToken = fbt
                                    self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
                                }
                            }
                            if let lit = (user["li_token"] as? String) {
                                if (lit != ""){
                                    HulaUser.sharedInstance.liToken = user["li_token"] as? String
                                    self.verLinkedinIcon.image = UIImage(named: "icon_linkedin_on")
                                }
                            }
                                if let twt = (user["tw_token"] as? String){
                                    if (twt != ""){
                                        HulaUser.sharedInstance.twToken = user["tw_token"] as? String
                                        self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                                    }
                            }
                            if let uStatus = (user["status"] as? String) {
                                if (uStatus == "verified"){
                                    self.verMailIcon.image = UIImage(named: "icon_mail_on")
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
