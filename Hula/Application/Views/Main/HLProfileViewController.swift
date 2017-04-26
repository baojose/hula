//
//  HLProfileViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

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
    }
    override func viewDidAppear(_ animated: Bool) {
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
            getUserProfile()
        }
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
    
    @IBAction func closeTooltip(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.completeProfileTooltip.alpha = 0
        })
    }
    
    
    
    
    
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
