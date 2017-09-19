//
//  HLSignUpViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSignUpViewController: UserBaseViewController, UITextFieldDelegate  {
    @IBOutlet weak var signupField: UITextField!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var greenBackgroundImage: UIImageView!
    @IBOutlet weak var signupErrorView: UIView!
    @IBOutlet weak var nextButton: HLRoundedNextButton!
    @IBOutlet weak var inputFieldsView: UIView!
    
    let descriptions = ["What is your name?", "What is your email address?", "Set a password for your account"]
    let hints = ["This is your public identification", "We wont bother you with nonsense emails", "Use a non-obvious password with more than 5 characters"]
    let placeholders = ["Nickname", "Email address", "Password"]
    var currentStep = 0;
    var userEmail = ""
    var userNick = ""
    var userPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let signupRecieved = Notification.Name("signupRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.signupDataRecieved), name: signupRecieved, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentStep = 0
        nextButton.setup()
        resetStepTexts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        //self.closeIdentification()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextStepPressed(_ sender: Any) {
        if (signupField.text! != ""){
            switch currentStep {
            case 0:
                userNick = signupField.text!
                checkUsernick(nick:userNick)
                break
            case 1:
                userEmail = signupField.text!
                break
            case 2:
                userPassword = signupField.text!
                break
            default:
                break
            }
            currentStep += 1
            if (currentStep <= 2){
                signupField.text = ""
                
                if (currentStep == 2){
                    signupField.isSecureTextEntry = true
                } else {
                    signupField.isSecureTextEntry = false
                }
                resetStepTexts()
            } else {
                // send signup information to the server
                HLDataManager.sharedInstance.signupUser(email: userEmail, nick:userNick, pass: userPassword)
                UIView.animate(withDuration: 0.2, animations: {
                    self.signupErrorView.frame.origin.y = self.view.frame.height
                    self.greenBackgroundImage.alpha = 1
                })
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.signupErrorView.frame.origin.y = self.view.frame.height - self.signupErrorView.frame.height
                self.greenBackgroundImage.alpha = 0
            })
        }
    }
    
    func checkUsernick(nick:String){
        let queryURL = HulaConstants.apiURL + "users/validatenick/\(nick)"
        print(queryURL)
        
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                if let dict = json as? [String:String]{
                    if dict["user"] == "found" {
                        
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.4, animations: {
                                self.greenBackgroundImage.alpha = 0
                            }, completion: { (success) in
                                UIView.animate(withDuration: 1.4, animations: {
                                    self.greenBackgroundImage.alpha = 1
                                })
                            })
                            
                            self.currentStep = 0
                            self.nextButton.setup()
                            self.resetStepTexts()
                        }
                        
                    }
                }
            }
        })
    }

    @IBAction func signupFieldChanged(_ sender: Any) {
        if (self.signupField.text!.characters.count>4){
            nextButton.startAnimation()
        } else {
            nextButton.stopAnimation()
        }
    }
    func resetStepTexts(){
        dismissKeyboard()
        let step_x = self.stepLabel.frame.origin.x
        let description_x = self.descriptionLabel.frame.origin.x
        let signup_x = self.signupField.frame.origin.x
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.stepLabel.frame.origin.x = -self.view.frame.width*2
            self.descriptionLabel.frame.origin.x = -self.view.frame.width*5
            self.signupField.frame.origin.x = -self.view.frame.width*12
            
        }, completion: { (finished: Bool) in
            self.stepLabel.text = "\(self.currentStep+1)/3"
            self.descriptionLabel.text = self.descriptions[self.currentStep]
            self.signupField.placeholder = self.placeholders[self.currentStep]
            self.stepLabel.frame.origin.x = self.view.frame.width*2
            self.descriptionLabel.frame.origin.x = self.view.frame.width*7
            self.signupField.frame.origin.x = self.view.frame.width*14
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                self.stepLabel.frame.origin.x = step_x
                self.descriptionLabel.frame.origin.x = description_x
                self.signupField.frame.origin.x = signup_x
                
            })
        })
    }
    
    func signupDataRecieved(notification: NSNotification) {
        print("Signup received. Closing VC")
        let signupOk = notification.object as! Bool
        print(signupOk)
        if (signupOk){
            self.closeIdentification()
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.signupErrorView.frame.origin.y = self.view.frame.height - self.signupErrorView.frame.height
                    self.greenBackgroundImage.alpha = 0
                })
            }
        }
        self.view.setNeedsDisplay()
    }
    @IBAction func beginEditText(_ sender: Any) {
        moveUpView()
    }
    @IBAction func endEditText(_ sender: Any) {
        moveDownView()
    }
    
    func moveUpView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.inputFieldsView.frame.origin.y = -140
        })
    }
    func moveDownView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.inputFieldsView.frame.origin.y = 0
        })
    }
    func dismissKeyboard(){
        view.endEditing(true)
    }
}
