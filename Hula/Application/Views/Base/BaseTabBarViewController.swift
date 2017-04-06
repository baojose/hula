//
//  BaseTabBarViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    @IBOutlet weak var tabbar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTabbar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initTabbar(){
        
        let tabArray = self.tabbar.items as NSArray!
        let tabItem0 = tabArray?.object(at: 0) as! UITabBarItem
        let myImage:UIImage = UIImage(named: "icon_tabbar_home_off")!
        tabItem0.selectedImage = myImage
        tabItem0.image = UIImage(named:"icon_tabbar_home_off")?.withRenderingMode(.alwaysOriginal)
        
        let tabItem1 = tabArray?.object(at: 1) as! UITabBarItem
        let myImage1:UIImage = UIImage(named: "icon_tabbar_notification")!
        tabItem1.selectedImage = myImage1
        tabItem1.image = UIImage(named:"icon_tabbar_notification")?.withRenderingMode(.alwaysOriginal)
        
        let tabItem2 = tabArray?.object(at: 2) as! UITabBarItem
        let myImage2:UIImage = UIImage(named: "icon_tabbar_stock_off")!
        tabItem2.selectedImage = myImage2
        tabItem2.image = UIImage(named:"icon_tabbar_stock_off")?.withRenderingMode(.alwaysOriginal)
        
        let tabItem3 = tabArray?.object(at: 3) as! UITabBarItem
        let myImage3:UIImage = UIImage(named: "icon_tabbar_profile_off")!
        tabItem3.selectedImage = myImage3
        tabItem3.image = UIImage(named:"icon_tabbar_profile_off")?.withRenderingMode(.alwaysOriginal)
        
        self.tabbar.tintColor = HulaConstants.appMainColor
        
        let tabbarSelectedItemBackgroundImage: UIImage! = UIImage(named: "img_tabbar_selected_bg")?.withRenderingMode(.alwaysOriginal)
        self.tabbar.selectionIndicatorImage = tabbarSelectedItemBackgroundImage;
    }

}
