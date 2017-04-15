//
//  HLLogInViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLLogInViewController: UserBaseViewController {
    @IBOutlet weak var nextButton: HLRoundedButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        self.closeIdentification()
    }
    

    @IBAction func gotoNextStep(_ sender: Any) {
        // check credentials over the API
    }
}
