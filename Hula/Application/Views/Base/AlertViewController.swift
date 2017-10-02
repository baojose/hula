//
//  AlertViewController.swift
//  Hula
//
//  Created by Juan Searle on 02/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var alertBackground: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var message:String = ""
    var delegate:AlertDelegate?
    var isCancelVisible = true
    var okButtonText = "OK"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alertBackground.layer.cornerRadius = 4.0;
        alertBackground.clipsToBounds = true
        messageLabel.text = message
        okButton.setTitle(okButtonText, for: .normal)
        if (isCancelVisible){
            cancelButton.isHidden = false;
        } else {
            cancelButton.isHidden = true;
        }
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

    @IBAction func okButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.alertResponded(response:"ok")
        })
    }
    @IBAction func canceButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.alertResponded(response:"cancel")
        })
    }
}

protocol AlertDelegate {
    func alertResponded(response:String)
}
