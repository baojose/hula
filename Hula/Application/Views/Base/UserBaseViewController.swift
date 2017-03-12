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
            let navController = self.storyboard?.instantiateViewController(withIdentifier: "mainNav")
            self.navigationController?.present(navController!, animated: true, completion: nil)
        }
        
    }
}
