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
    weak var player : AVPlayer?
    weak var playerLayer : AVPlayerLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HLDataManager.sharedInstance.loadUserData()
        HLDataManager.sharedInstance.ga("splash_screen")
        self.playVideo()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if player != nil {
            player!.pause();
            player = nil
        }
        playerLayer?.removeFromSuperlayer()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    /// Splash used `token!` and `count>10`. Nil/short tokens must play the intro,
    /// matching the tab login gate, instead of crashing launch.
    class func shouldSkipSplashVideo(token: String?) -> Bool {
        return TabLoginPolicy.isLoggedIn(token: token)
    }

    private func playVideo(){
        
        //print(token)
        if HLMainViewController.shouldSkipSplashVideo(token: HulaUser.sharedInstance.token) {
            // we will jump to mainView only if user is not logged in
            self.navToMainView()
        } else {
            HLDataManager.sharedInstance.ga("splash_video")
            guard let path = Bundle.main.path(forResource: "splash_intro", ofType:"mp4") else {
                debugPrint("splash_intro.mp4 file not found")
                return
            }
            player = AVPlayer(url: URL(fileURLWithPath: path))
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            NotificationCenter.default.addObserver(self, selector: #selector(HLMainViewController.playerEnded(notification:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
            player!.play()
        }
    }
    
    @objc private func playerEnded (notification:NSNotification) {
        //print("finished")
        //print(token)
        if HLMainViewController.shouldSkipSplashVideo(token: HulaUser.sharedInstance.token) {
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
