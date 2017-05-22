//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSwappViewController: UIViewController {

    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var initialCoverView: UIImageView!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var hisProfileImage: UIImageView!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var hisProfileLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        CommonUtils.sharedInstance.circleImageView(myProfileImage)
        CommonUtils.sharedInstance.circleImageView(hisProfileImage)
        myProfileLabel.text = HulaUser.sharedInstance.userNick
        CommonUtils.sharedInstance.loadImageOnView(imageView:myProfileImage, withURL:HulaUser.sharedInstance.userPhotoURL)
        
        rotated()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.initialCoverView.center.y += 1000
            self.initialCoverView.transform = CGAffineTransform(rotationAngle: 0.8)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true) { 
            // After dismiss
        }
        
    }
    @IBAction func closeSwappInterfaceAction(_ sender: Any) {
        portraitView.isHidden = false
        landscapeView.isHidden = true
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("portrait")
            portraitView.isHidden = false
            landscapeView.isHidden = true
            self.dismiss(animated: true) {
                // After dismiss
            }
        } else {
            print("landscape")
            portraitView.isHidden = true
            landscapeView.isHidden = false
        }
    }
}
