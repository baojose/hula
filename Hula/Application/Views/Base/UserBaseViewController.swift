//
//  UserBaseViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class UserBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func navToMainView() {
        
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "baseTabBarPage") as! BaseTabBarViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    func closeIdentification() {
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true);
        }
    }
    
}
