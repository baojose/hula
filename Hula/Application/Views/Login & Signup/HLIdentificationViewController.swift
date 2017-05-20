//
//  HLIdentificationViewController.swift
//  Hula
//
//  Created by Juan Searle on 15/04/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLIdentificationViewController: UserBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let user = HulaUser.sharedInstance
        if (user.token.characters.count > 10){
            // user not logged in
            self.closeIdentification()
        }
    }
    
    
    @IBAction func closeIdentificationVC(_ sender: Any) {
        self.closeIdentification()
        
        //_ = self.tabBarController?.selectedIndex = 0
        //_ = self.navigationController?.popViewController(animated: true)
    }
    
}
