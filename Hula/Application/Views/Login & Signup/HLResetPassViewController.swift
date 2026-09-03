//
//  HLResetPassViewController.swift
//  Hula
//
//  Created by Juan Searle on 24/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLResetPassViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputFieldsView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nextButton: HLRoundedNextButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("password_reset")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backToPreviousAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func emailFieldChanged(_ sender: Any) {
        if AuthFormPolicy.shouldEnableNext(text: emailField.text) {
            nextButton.startAnimation()
        } else {
            nextButton.stopAnimation()
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

    /// Reset-mail GET. Short/blank emails must not hit `users/resetmail/`.
    class func resetMailURL(apiBase: String, email: String?) -> String? {
        return CommonUtils.resetMailURL(apiBase: apiBase, email: email)
    }

    @IBAction func resetPassAction(_ sender: Any) {
        //print("Sending email...")
        let email = AuthFormPolicy.fieldText(emailField.text).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let queryURL = HLResetPassViewController.resetMailURL(
            apiBase: HulaConstants.apiURL,
            email: email
        ) else {
            return
        }
        //print(queryURL)
        
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            guard ok else { return }
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "resetSent") as! HLResetSentViewController
                //print(vc)
                vc.emailText = email
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
}
