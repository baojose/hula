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
    let media = OnboardingPlayerStore()
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
        media.stop()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    private func playVideo(){
        
        let token = HulaUser.sharedInstance.token!
        //print(token)
        if (token.count>10   ){ //&& false
            // we will jump to mainView only if user is not logged in
            self.navToMainView()
        } else {
            HLDataManager.sharedInstance.ga("splash_video")
            guard let path = Bundle.main.path(forResource: "splash_intro", ofType:"mp4") else {
                debugPrint("splash_intro.mp4 file not found")
                return
            }
            let item = media.replace(url: URL(fileURLWithPath: path), frame: self.view.bounds)
            media.add(to: self.view.layer)
            NotificationCenter.default.addObserver(self, selector: #selector(HLMainViewController.playerEnded(notification:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            media.play()
        }
    }
    
    @objc private func playerEnded (notification:NSNotification) {
        //print("finished")
        let token = HulaUser.sharedInstance.token!
        //print(token)
        if (token.count>10){ // && false
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

/// Owns the splash and intro AVPlayer. Those screens used to keep the player
/// and its layer in weak properties, so ARC released them before play().
final class OnboardingPlayerStore {
    private var player: AVPlayer?
    private var layer: AVPlayerLayer?

    var hasRetainedPlayer: Bool {
        guard let player = player, let layer = layer else { return false }
        if let attached = layer.player {
            return attached === player
        }
        return false
    }

    @discardableResult
    func replace(url: URL, frame: CGRect) -> AVPlayerItem? {
        player?.pause()
        layer?.removeFromSuperlayer()
        let nextPlayer = AVPlayer(url: url)
        let nextLayer = AVPlayerLayer(player: nextPlayer)
        nextLayer.frame = frame
        player = nextPlayer
        layer = nextLayer
        return nextPlayer.currentItem
    }

    func add(to host: CALayer) {
        if let layer = layer {
            host.addSublayer(layer)
        }
    }

    func insert(into host: CALayer, at index: UInt32) {
        if let layer = layer {
            host.insertSublayer(layer, at: index)
        }
    }

    func play() {
        player?.play()
    }

    func stop() {
        player?.pause()
        layer?.removeFromSuperlayer()
        player = nil
        layer = nil
    }
}
