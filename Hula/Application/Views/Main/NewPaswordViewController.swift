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
        let queryURL = HulaConstants.apiURL + "users/resetpass/\(HulaUser.sharedInstance.userId!)"
        let current_pass:String = currentPass.text!
        let new_pass:String = pass1.text!
        let new_pass2:String = pass2.text!
        if (new_pass.characters.count < 5){
            // password too short
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            
            viewController.delegate = self as AlertDelegate
            viewController.isCancelVisible = false
            viewController.message = "Your new password is too short."
            self.present(viewController, animated: true)
            return
        }
        if (current_pass.characters.count < 4){
            // old password too short
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            
            viewController.delegate = self as AlertDelegate
            viewController.isCancelVisible = false
            viewController.message = "Your previous password is too short."
            self.present(viewController, animated: true)
            return
        }
        if (new_pass != new_pass2){
            // old password too short
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            
            viewController.delegate = self as AlertDelegate
            viewController.isCancelVisible = false
            viewController.message = "Passwords do not match."
            self.present(viewController, animated: true)
            return
        }
        print(queryURL)
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: "current_pass=\(current_pass)&new_pass=\(new_pass)", isPut: false, taskCallback: { (ok, json) in
            
            if (ok){
                //print(json)
                DispatchQueue.main.async {
                    let _ = self.navigationController?.popViewController(animated: true)
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
    func alertResponded(response: String) {
        print("Response: \(response)")
        
    }
}
