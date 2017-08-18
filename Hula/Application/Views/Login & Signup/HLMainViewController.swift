//
//  HLMainViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class HLMainViewController: UserBaseViewController {

    @IBOutlet weak var hulaSplashImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hulaSplashImage.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HLDataManager.sharedInstance.loadUserData()
        self.playVideo()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
    override func shouldAutorotate() -> Bool {
            return false
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation{
            return UIInterfaceOrientation.portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
            return UIInterfaceOrientationMask.portrait
    }
    
    */
    
    private func playVideo(){
        
        let token = HulaUser.sharedInstance.token!
        //print(token)
        if (token.characters.count>10){
            hulaSplashImage.isHidden = false
            // we will jump to mainView only if user is not logged in
            self.navToMainView()
        } else {
            guard let path = Bundle.main.path(forResource: "splash_intro", ofType:"mp4") else {
                debugPrint("splash_intro.mp4 file not found")
                return
            }
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            NotificationCenter.default.addObserver(self, selector: #selector(HLMainViewController.playerEnded(notification:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            player.play()
        }
    }
    
    func playerEnded (notification:NSNotification) {
        //print("finished")
        let token = HulaUser.sharedInstance.token!
        //print(token)
        if (token.characters.count>10){
            // we will jump to mainView only if user is not logged in
            self.navToMainView()
        } else {
            let introViewController = self.storyboard?.instantiateViewController(withIdentifier: "introPage") as! HLIntroViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(introViewController, animated: false)
        }
    }
}
