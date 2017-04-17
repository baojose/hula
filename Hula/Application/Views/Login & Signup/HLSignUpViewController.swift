//
//  HLSignUpViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSignUpViewController: UserBaseViewController {
    @IBOutlet weak var signupField: UITextField!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let descriptions = ["What is your name?", "What is your email address?", "Set a password for your account"]
    let hints = ["This is your public identification", "We wont bother you with nonsense emails", "Use a non-obvious password with more than 5 characters"]
    let placeholders = ["Nickname", "Email address", "Password"]
    var currentStep = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentStep = 0
        resetStepTexts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        self.closeIdentification()
    }
    
    @IBAction func nextStepPressed(_ sender: Any) {
        currentStep += 1
        if (currentStep <= 2){
            resetStepTexts()
        } else {
            // send signup information to the server
            
        }
    }

    func resetStepTexts(){
        stepLabel.text = "\(currentStep+1)/3"
        descriptionLabel.text = descriptions[currentStep]
        signupField.placeholder = placeholders[currentStep]
    }
}
