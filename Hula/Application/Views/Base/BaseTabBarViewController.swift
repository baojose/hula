//
//  BaseTabBarViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController, UITabBarControllerDelegate{
    
    var commonUtils: CommonUtils! = CommonUtils.sharedInstance
    var isUserLoggedIn: Bool = false
    @IBOutlet weak var tabbar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTabbar()
        
        self.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        
        let notificationsRecieved = Notification.Name("notificationsRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsRecieved), name: notificationsRecieved, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let items : Int = (self.navigationController?.viewControllers.count)!
        if items > 1{
            //print("Appear. Clearing previous vc...")
            self.navigationController?.viewControllers.remove(at: 0)
        }
    }
    
    func initTabbar(){
        
        let items = self.tabbar.items
        if let tabItem0 = TabLoginPolicy.tabItem(at: 0, in: items) {
            let myImage:UIImage = UIImage(named: "icon_tabbar_home_off")!
            tabItem0.selectedImage = myImage
            tabItem0.tag = 0
            tabItem0.image = UIImage(named:"icon_tabbar_home_off")?.withRenderingMode(.alwaysOriginal)
        }

        if let tabItem1 = TabLoginPolicy.tabItem(at: 1, in: items) {
            let myImage1:UIImage = UIImage(named: "icon_tabbar_notification")!
            tabItem1.selectedImage = myImage1
            tabItem1.tag = 1
            tabItem1.image = UIImage(named:"icon_tabbar_notification")?.withRenderingMode(.alwaysOriginal)
        }

        if let tabItem2 = TabLoginPolicy.tabItem(at: 2, in: items) {
            let myImage2:UIImage = UIImage(named: "icon_tabbar_stock_off")!
            tabItem2.selectedImage = myImage2
            tabItem2.tag = 2
            tabItem2.image = UIImage(named:"icon_tabbar_stock_off")?.withRenderingMode(.alwaysOriginal)
        }

        if let tabItem3 = TabLoginPolicy.tabItem(at: 3, in: items) {
            let myImage3:UIImage = UIImage(named: "icon_tabbar_profile_off")!
            tabItem3.selectedImage = myImage3
            tabItem3.tag = 3
            tabItem3.image = UIImage(named:"icon_tabbar_profile_off")?.withRenderingMode(.alwaysOriginal)
        }
        
        self.tabbar.tintColor = HulaConstants.appMainColor
        
        if !Device.IS_IPHONE_X {
            let tabbarSelectedItemBackgroundImage: UIImage! = UIImage(named: "img_tabbar_selected_bg_ok")?.withRenderingMode(.alwaysOriginal)
            self.tabbar.selectionIndicatorImage = tabbarSelectedItemBackgroundImage;
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //print(item.tag)
        if !TabLoginPolicy.shouldAllowTab(itemTag: item.tag, loggedIn: checkUserLogin()) {
            openUserIdentification()
            self.selectedIndex = 0;
        }
        
        notificationsRecieved(nil)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //print("Tapp")
        //print(tabBarController.selectedIndex)
        if (!checkUserLogin()){
            return false
        } else {
            return true
        }
    }

    func notificationsRecieved(_ notification: NSNotification?){
        if ( HLDataManager.sharedInstance.numNotificationsPending > 0 ){
            tabBar.items?[1].badgeValue = "\(HLDataManager.sharedInstance.numNotificationsPending)"
        } else {
            tabBar.items?[1].badgeValue = nil
        }
    }
    
    func checkUserLogin() -> Bool{
        isUserLoggedIn = TabLoginPolicy.isLoggedIn(token: HulaUser.sharedInstance.token)
        return isUserLoggedIn
    }
    
    func openUserIdentification(){
        
        //
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "identification") as! HLIdentificationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        //        let modalViewController = HLIdentificationViewController()
        //        modalViewController.modalPresentationStyle = .overCurrentContext
        //        present(modalViewController, animated: true, completion: nil)
    }
}
