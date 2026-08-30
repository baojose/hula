//
//  NewPaswordViewController.swift
//  Hula
//
//  Created by Juan Searle on 29/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class NewPaswordViewController: UIViewController {

    @IBOutlet weak var currentPass: UITextField!
    @IBOutlet weak var pass1: UITextField!
    @IBOutlet weak var pass2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveAction(_ sender: Any) {
        guard let queryURL = PasswordChangePolicy.resetPath(userId: HulaUser.sharedInstance.userId) else {
            return
        }
        let current_pass = currentPass.text
        let new_pass = pass1.text
        let new_pass2 = pass2.text
        if let message = PasswordChangePolicy.validationMessage(
            current: current_pass,
            newPassword: new_pass,
            confirmation: new_pass2
        ) {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            
            viewController.delegate = self as AlertDelegate
            viewController.isCancelVisible = false
            viewController.message = message
            self.present(viewController, animated: true)
            return
        }
        let postString = PasswordChangePolicy.postString(current: current_pass ?? "", newPassword: new_pass ?? "")
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: postString, isPut: false, taskCallback: { (ok, json) in
            DispatchQueue.main.async {
                if PasswordChangePolicy.shouldPop(httpOk: ok, json: json) {
                    let _ = self.navigationController?.popViewController(animated: true)
                } else if let message = PasswordChangePolicy.serverMessage(httpOk: ok, json: json) {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    viewController.delegate = self as AlertDelegate
                    viewController.isCancelVisible = false
                    viewController.message = message
                    self.present(viewController, animated: true)
                }
            }
        })
        
    }
    
    @IBAction func closePasswordViewAction(_ sender: Any) {
        DispatchQueue.main.async {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
extension NewPaswordViewController: AlertDelegate{
    func alertResponded(response: String, trigger:String) {
        print("Response: \(response)")
        
    }
}
