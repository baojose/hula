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
            //commonUtils.loadImageOnView(imageView:self.smallProfileImage, withURL:HulaUser.sharedInstance.userPhotoURL)
            self.smallProfileImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
        } else {
            self.addAlertIcon(toView: self.pictureView)
        }
        
        
        if (userData.userNick.characters.count>1){
            userNameLabel.text = userData.userNick
        } else {
            self.addAlertIcon(toView: self.nameView)
        }
        
        if (userData.userEmail.characters.count>1){
            userEmailLabel.text = userData.userEmail
        }
        
        if (userData.userName.characters.count>1){
            userFullNameLabel.text = userData.userName
        } else {
            self.addAlertIcon(toView: self.fullNameView)
        }
        if (userData.userBio.characters.count>1){
            userBioLabel.text = userData.userBio
        } else {
            self.addAlertIcon(toView: self.bioView)
        }
        
        if (userData.userLocationName.characters.count>1){
            locationLabel.text = userData.userLocationName
        } else {
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
        case 2:
            // Full name
            title = "Change your full name"
            previous = userData.userName
            label = "Full name"
            item_toUpdate = "userName"
        case 3:
            // Bio
            title = "Change your bio"
            previous = userData.userBio
            label = "Bio"
            item_toUpdate = "userBio"
        case 4:
            // Location
            title = "Change location"
            previous = userData.userLocationName
            label = "Location"
            item_toUpdate = "userLocationName"
        case 5:
            // Password
            title = "Change your password"
            previous = ""
            label = "Password"
            item_toUpdate = "userPassword"
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
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
        
    }
    
    // Custom functions for ViewController
    func addAlertIcon(toView: UIView){
        let imageName = "icon_alert_thumbnails"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: toView.frame.width/2 + 20, y: toView.frame.height/2 - 8, width: 16, height: 16)
        toView.addSubview(imageView)
    }
}
