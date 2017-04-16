//
//  HLLogInViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLLogInViewController: UserBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var nextButton: HLRoundedNextButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var greenBackgroundImage: UIImageView!
    @IBOutlet weak var loginErrorView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginRecieved = Notification.Name("loginRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginDataRecieved), name: loginRecieved, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        nextButton.setup()
        nextButton.stopAnimation()
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        self.closeIdentification()
    }
    
    @IBAction func emailValueChanged(_ sender: Any) {
        checkUserInput()
    }

    @IBAction func passwordValueChanged(_ sender: Any) {
        checkUserInput()
    }
    @IBAction func gotoNextStep(_ sender: Any) {
        // check credentials over the API
        HLDataManager.sharedInstance.loginUser(email: emailField.text!, pass: passwordField.text!)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.loginErrorView.frame.origin.y = self.view.frame.height
            self.greenBackgroundImage.alpha = 1
        })
        
    }
    func checkUserInput(){
        let email_str = emailField.text!
        let pass_str = passwordField.text!
        if ((pass_str.characters.count>4) && (email_str.characters.count>4)){
            nextButton.startAnimation()
        } else {
            nextButton.stopAnimation()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func loginDataRecieved(notification: NSNotification) {
        print("Login received. Closing VC")
        let loginOk = notification.object as! Bool
        print(loginOk)
        if (loginOk){
            self.closeIdentification()
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.loginErrorView.frame.origin.y = self.view.frame.height - self.loginErrorView.frame.height
                    self.greenBackgroundImage.alpha = 0
                })
            }
        }
        self.view.setNeedsDisplay()
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
}
