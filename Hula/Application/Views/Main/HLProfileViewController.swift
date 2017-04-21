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
    }
    
    @IBAction func closeTooltip(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.completeProfileTooltip.alpha = 0
        })
    }
}
