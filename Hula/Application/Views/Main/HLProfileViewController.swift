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
    
    func viewDidAppear() {
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
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
        
        getUserProfile()
    }
    
    @IBAction func closeTooltip(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.completeProfileTooltip.alpha = 0
        })
    }
    
    
    
    
    
    func getUserProfile() {
        
        print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "users/" + HulaUser.sharedInstance.userId
        print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        if let user = dictionary["user"] as? [String: Any] {
                            if (user["name"] as? String) != nil {
                                self.userFullNameLabel.text = user["name"] as? String
                            }
                            if (user["nick"] as? String) != nil {
                                self.userNickLabel.text = user["nick"] as? String
                            }
                            if (user["bio"] as? String) != nil {
                                self.userBioLabel.text = user["bio"] as? String
                            }
                            if (user["image"] as? String) != nil {
                                let urlString = (user["image"] as? String)
                                guard let url = URL(string: urlString!) else { return }
                                URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if error != nil {
                                        print("Failed fetching image:", error!)
                                        return
                                    }
                                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                                        print("Not a proper HTTPURLResponse or statusCode")
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        self.profileImageView.image = UIImage(data: data!)
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            } else {
                // connection error
            }
        })
    }
}
