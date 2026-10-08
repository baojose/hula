//
//  HLSellerHorizontalViewController.swift
//  Hula
//
//  Created by Juan Searle on 23/10/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSellerHorizontalViewController: BaseViewController {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    @IBOutlet weak var sellerFeedbackLabel: UILabel!
    
    
    @IBOutlet weak var fbIcon: UIImageView!
    @IBOutlet weak var liIcon: UIImageView!
    @IBOutlet weak var twIcon: UIImageView!
    @IBOutlet weak var emIcon: UIImageView!
    
    
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    
    @IBOutlet weak var sellerBioTextView: UITextView!
    
    var user = HulaUser();
    var userProducts: NSArray = []
    var userFeedback: NSArray = []
    var initialTradeFrame: CGRect!

    /// Seller social/bio used IUO `.count>1`.
    class func hasDisplayValue(_ value: String?) -> Bool {
        return UserIdentityPolicy.hasDisplayValue(value)
    }

    class func isEmailVerified(_ status: String?) -> Bool {
        return UserIdentityPolicy.isEmailVerified(status)
    }

    /// The horizontal seller sheet passed IUO `userPhotoURL` into
    /// `getThumbFor(url: String)`. A nil photo crashed before the image load.
    /// Reuse the profile thumb helper so nil becomes the placeholder. Do not trim.
    class func profileThumbURL(_ photoURL: String?) -> String {
        return ProfilePhotoPolicy.thumbURL(photoURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HLDataManager.sharedInstance.ga("other_user_profile_horizontal")
    }
    func initData(){
        
        let thumb = HLSellerHorizontalViewController.profileThumbURL(user.userPhotoURL)
        profileImage.loadImageFromURL(urlString: thumb)
        sellerNameLabel.text = user.userNick
        sellerLocationLabel.text = user.userLocationName
        
        if HLSellerHorizontalViewController.hasDisplayValue(user.twToken){
            twIcon.image = UIImage(named: "icon_twitter_on")
        }
        if HLSellerHorizontalViewController.hasDisplayValue(user.fbToken){
            fbIcon.image = UIImage(named: "icon_facebook_on")
        }
        if HLSellerHorizontalViewController.hasDisplayValue(user.liToken){
            liIcon.image = UIImage(named: "icon_linkedin_on")
        }
        if HLSellerHorizontalViewController.isEmailVerified(user.status){
            emIcon.image = UIImage(named: "icon_mail_on")
        }
        if HLSellerHorizontalViewController.hasDisplayValue(user.userBio){
            sellerBioTextView.text = user.userBio
        } else {
            sellerBioTextView.text = "..."
        }
        sellerFeedbackLabel.text = user.getFeedback()
        
        tradesStartedLabel.text = "\(Int(user.trades_started))"
        tradesClosedLabel.text = "\(Int(user.trades_closed))"
        tradesEndedLabel.text = "\(Int(user.trades_finished))"
    }
    func initView(){
        commonUtils.circleImageView(profileImage)
        
        let totalHeight = sellerBioTextView.frame.origin.y + sellerBioTextView.frame.size.height
        mainScrollView.contentSize = CGSize(width: 0, height: totalHeight)
        
        containerView.frame.size.height = totalHeight
        
    }

    @IBAction func closeViewAction(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}


