//
//  HLResetSentViewController.swift
//  Hula
//
//  Created by Juan Searle on 25/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLResetSentViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    var emailText:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailLabel.text = emailText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("password_reset_sent")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func requestAnotherAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Login sits two screens back: [... , Login, ResetPass, ResetSent].
    /// `count - 3` without a bounds check crashed short stacks.
    class func loginStackIndex(count: Int) -> Int? {
        return ResetSentNavigationPolicy.loginStackIndex(count: count)
    }

    @IBAction func gotoLoginAction(_ sender: Any) {
        guard let nav = self.navigationController else { return }
        let viewControllers = nav.viewControllers
        if let index = HLResetSentViewController.loginStackIndex(count: viewControllers.count) {
            nav.popToViewController(viewControllers[index], animated: true)
        } else {
            nav.popToRootViewController(animated: true)
        }
    }
}

/// Password-reset "Go to login" used `navigationController!` and
/// `viewControllers[count - 3]`. A stack shorter than 3 (modal, deep link,
/// already popped) crashed the reset-sent screen.
struct ResetSentNavigationPolicy {
    static func loginStackIndex(count: Int) -> Int? {
        let index = count - 3
        guard index >= 0, index < count else {
            return nil
        }
        return index
    }
}
