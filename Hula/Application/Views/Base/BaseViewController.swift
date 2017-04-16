//
//  BaseViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var dataManager: HLDataManager! = HLDataManager.sharedInstance
    var commonUtils: CommonUtils! = CommonUtils.sharedInstance
    
    @IBOutlet var pageTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //#MARK: Common Functions
    
    
    //#MARK: Common Actions
    @IBAction func goBackToPreviousPage(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func dismissToPreviousPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openUserIdentification(){
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "identification") as! HLIdentificationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
//        let modalViewController = HLIdentificationViewController()
//        modalViewController.modalPresentationStyle = .overCurrentContext
//        present(modalViewController, animated: true, completion: nil)
    }
}
