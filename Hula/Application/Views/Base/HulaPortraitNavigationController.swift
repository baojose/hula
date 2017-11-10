//
//  HulaPortraitNavigationController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaPortraitNavigationController: UINavigationController {
    
    var commonUtils: CommonUtils! = CommonUtils.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    func rotated() {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && appDelegate.allowRotation {
            openSwapView()
        }
        /*
         if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
         print("Portrait")
         }
         */
    }
    
    func openSwapView(){
        if !HLDataManager.sharedInstance.isInSwapVC {
            HLDataManager.sharedInstance.isInSwapVC = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myModalViewController = storyboard.instantiateViewController(withIdentifier: "swappView")
            myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            myModalViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(myModalViewController, animated: true, completion: nil)
        }
    }
}
