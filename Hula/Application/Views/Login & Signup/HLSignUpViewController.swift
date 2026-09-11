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
    @IBOutlet weak var signupErrorLabel: UILabel!
    @IBOutlet weak var legallbl: UILabel!
    
    @IBOutlet weak var legalbtn: UIButton!
    let descriptions = [NSLocalizedString("What is your name?", comment: ""), NSLocalizedString("What is your email address?", comment: ""), NSLocalizedString("Set a password for your account", comment: "")]
    let hints = [NSLocalizedString("This is your public identification", comment: ""), NSLocalizedString("We wont bother you with nonsense emails", comment: ""), NSLocalizedString("Use a non-obvious password with more than 5 characters", comment: "")]
    let placeholders = [NSLocalizedString("Nickname", comment: ""), NSLocalizedString("Email address", comment: ""), NSLocalizedString("Password", comment: "")]
    var currentStep = 0;
    var userEmail = ""
    var userNick = ""
    var userPassword = ""
    var nickCheckInFlight = false
    var nickCheckRequestId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let signupRecieved = Notification.Name("signupRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.signupDataRecieved), name: signupRecieved, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentStep = 0
        nickCheckInFlight = false
        nickCheckRequestId += 1
        nextButton.setup()
        resetStepTexts()
        HLDataManager.sharedInstance.ga("signup")
        legalbtn.isHidden = true;
        legallbl.isHidden = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        //self.closeIdentification()
        _ = self.navigationController?.popViewController(animated: true)
    }
    //test
    @IBAction func nextStepPressed(_ sender: Any) {
        if (signupField.text! != ""){
            signupField.isSecureTextEntry = false
            switch currentStep {
            case 0:
                if !SignupNickCheckPolicy.canStartNickCheck(currentStep: currentStep, nickCheckInFlight: nickCheckInFlight) {
                    break
                }
                userNick = signupField.text!
                nickCheckInFlight = true
                nickCheckRequestId += 1
                checkUsernick(nick:userNick, requestId: nickCheckRequestId)
                break
            case 1:
                userEmail = signupField.text!
                signupField.text = ""
                signupField.isSecureTextEntry = true
                currentStep += 1
                legalbtn.isHidden = false;
                legallbl.isHidden = false;
                nextButton.setTitle(NSLocalizedString("Agree", comment: ""), for: .normal)
                resetStepTexts()
                break
            case 2:
                userPassword = signupField.text!
                signupField.text = ""
                //resetStepTexts()
                currentStep += 1
                break
            default:
                
                break
            }
            if currentStep > 2{
                HLDataManager.sharedInstance.signupUser(email: userEmail, nick:userNick, pass: userPassword)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.signupErrorView.frame.origin.y = self.view.frame.height
                        self.greenBackgroundImage.alpha = 1
                    })
                    self.view.endEditing(true)
                }
            }
        } else {
            self.showError(NSLocalizedString("This field cannot be empty. Please fill all the fields.", comment: ""))
        }
    }
    
    func showError(_ msg : String){
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.signupErrorView.frame.origin.y = self.view.frame.height - self.signupErrorView.frame.height
            self.greenBackgroundImage.alpha = 0
            self.signupErrorLabel.text = msg
        })
    }
    
    func checkUsernick(nick:String, requestId: Int){
        let escaped = nick.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let queryURL = HulaConstants.apiURL + "users/validatenick/\( escaped! )"
        //print(queryURL)
        
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            DispatchQueue.main.async {
                guard SignupNickCheckPolicy.shouldApplyNickCheckResponse(currentStep: self.currentStep, requestId: requestId, expectedRequestId: self.nickCheckRequestId) else {
                    return
                }
                self.nickCheckInFlight = false
                if (ok){
                    if let dict = json as? [String:String]{
                        if dict["user"] == "found" {
                            self.showError(NSLocalizedString("Username has already been taken.", comment: ""))
                            self.currentStep = 0
                            self.nextButton.setup()
                            //self.resetStepTexts()
                        } else {
                            self.signupField.text = ""
                            self.currentStep = SignupNickCheckPolicy.stepAfterNickAvailable()
                            self.resetStepTexts()
                        }
                    }
                } else {
                    self.showError(NSLocalizedString("Could not verify that username. Please try again.", comment: ""))
                }
            }
        })
    }

    @IBAction func gotoTermsConditionsAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://hula.trading/legal.html")!)
    }
    @IBAction func signupFieldChanged(_ sender: Any) {
        if (self.signupField.text!.count>4){
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
        
        UIView.animate(withDuration: 0.2, animations: {
            self.signupErrorView.frame.origin.y = self.view.frame.height
            self.greenBackgroundImage.alpha = 1
        })
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.stepLabel.frame.origin.x = -self.view.frame.width*2
            self.descriptionLabel.frame.origin.x = -self.view.frame.width*5
            self.signupField.frame.origin.x = -self.view.frame.width*12
            
        }, completion: { (finished: Bool) in
            guard SignupNickCheckPolicy.isValidDisplayStep(self.currentStep) else {
                return
            }
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
        //print("Signup received. Closing VC")
        DispatchQueue.main.async {
            let signupOk = notification.object as! Bool
            //print("signupOk")
            //print(signupOk)
            if (signupOk){
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "welcome") as! HLWelcomeViewController
                //self.present(nextViewController, animated:true, completion:nil)
                //print("navigationController?.pushViewController")
                self.navigationController?.pushViewController(nextViewController, animated: true)
               
            } else {
                self.showError(HLDataManager.sharedInstance.lastServerMessage)
            }
            self.view.setNeedsDisplay()
        }
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

/// Signup nick-check must not `+=` currentStep for every in-flight Next tap.
/// Three overlapping "available" responses used to land on step 3 and crash
/// `descriptions[currentStep]` (only 0...2 exist). Two taps skipped the email step.
struct SignupNickCheckPolicy {
    static let emailStep = 1
    static let stepCount = 3
    
    static func canStartNickCheck(currentStep: Int, nickCheckInFlight: Bool) -> Bool {
        return currentStep == 0 && !nickCheckInFlight
    }
    
    static func shouldApplyNickCheckResponse(currentStep: Int, requestId: Int, expectedRequestId: Int) -> Bool {
        return currentStep == 0 && requestId == expectedRequestId
    }
    
    static func stepAfterNickAvailable() -> Int {
        return emailStep
    }
    
    static func isValidDisplayStep(_ step: Int) -> Bool {
        return step >= 0 && step < stepCount
    }
}
