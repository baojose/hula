//
//  HLSettingViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSettingViewController: BaseViewController {

    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    var userData:HulaUser = HulaUser.sharedInstance
    
    @IBOutlet weak var smallProfileImage: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var fullNameView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData() {
        
    }
    func initView() {
        commonUtils.circleImageView(profileImageView)
        mainScrollView.contentSize = CGSize(width: 0, height: contentView.frame.size.height)
        
        if (userData.userPhotoURL.characters.count>1){
            self.removeAlertIcon(fromView: self.pictureView)
            self.smallProfileImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
        } else {
            self.addAlertIcon(toView: self.pictureView)
        }
        
        
        if (userData.userNick.characters.count>1){
            userNameLabel.text = userData.userNick
            self.removeAlertIcon(fromView: self.nameView)
        } else {
            userNameLabel.text = "Name"
            self.addAlertIcon(toView: self.nameView)
        }
        
        if (userData.userEmail.characters.count>1){
            userEmailLabel.text = userData.userEmail
        }
        
        if (userData.userName.characters.count>1){
            userFullNameLabel.text = userData.userName
            self.removeAlertIcon(fromView: self.fullNameView)
        } else {
            userFullNameLabel.text = "Full name"
            self.addAlertIcon(toView: self.fullNameView)
        }
        if (userData.userBio.characters.count>1){
            userBioLabel.text = userData.userBio
            self.removeAlertIcon(fromView: self.bioView)
        } else {
            userBioLabel.text = "About you"
            self.addAlertIcon(toView: self.bioView)
        }
        
        if (userData.userLocationName.characters.count>1){
            locationLabel.text = userData.userLocationName
            self.removeAlertIcon(fromView: self.locationView)
        } else {
            locationLabel.text = "Location"
            self.addAlertIcon(toView: self.locationView)
        }
    }
    
    
    // IB Actions
    @IBAction func userLogout(_ sender: Any) {
        HLDataManager.sharedInstance.logout()
        self.goBackToPreviousPage(sender)
    }
    @IBAction func editItemAction(_ sender: Any) {
        print((sender as! UIButton).tag)
        var title = "";
        var previous = "";
        var label = ""
        var item_toUpdate = "";
        var remChar = 300
        switch (sender as! UIButton).tag {
        case 0:
            // image update
            let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectPictureGeneral") as! HLPictureSelectViewController
            self.present(cameraViewController, animated: true)

        case 1:
            // Name
            title = "Change your nickname"
            previous = userData.userNick
            label = "Nickname"
            item_toUpdate = "userNick"
            remChar = 40
        case 2:
            // Full name
            title = "Change your full name"
            previous = userData.userName
            label = "Full name"
            item_toUpdate = "userName"
            remChar = 120
        case 3:
            // Bio
            title = "Change your bio"
            previous = userData.userBio
            label = "Bio"
            item_toUpdate = "userBio"
            remChar = 300
        case 4:
            // Location
            title = "Change location"
            previous = userData.userLocationName
            label = "Location"
            item_toUpdate = "userLocationName"
            remChar = 80
        case 5:
            // Password
            title = "Change your password"
            previous = ""
            label = "Password"
            item_toUpdate = "userPassword"
            remChar = 40
        default:
            // nada
            break
        }
        if ((sender as! UIButton).tag != 0 ){
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "fieldEditor") as! HLEditFieldViewController
            editViewController.field_label = label
            editViewController.field_title = title
            editViewController.field_previous_val = previous
            editViewController.field_key = item_toUpdate
            editViewController.remainingChars = remChar
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
        
    }
    
    @IBAction func helpOptionAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://hula.trading/")!)
    }
    // Custom functions for ViewController
    func addAlertIcon(toView: UIView){
        let imageName = "icon_alert_thumbnails"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.tag = 220;
        imageView.frame = CGRect(x: toView.frame.width/2 + 20, y: toView.frame.height/2 - 8, width: 16, height: 16)
        toView.addSubview(imageView)
    }
    func removeAlertIcon(fromView: UIView){
        for view in fromView.subviews{
            if view.tag == 220{
                view.removeFromSuperview()
            }
        }
    }
}
