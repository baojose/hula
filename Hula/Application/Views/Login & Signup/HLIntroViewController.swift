//
//  HLIntroViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SpriteKit

class HLIntroViewController: UserBaseViewController, UIScrollViewDelegate {
    
    @IBOutlet var introView1: UIView!
    @IBOutlet var introView2: UIView!
    @IBOutlet var introView3: UIView!
    @IBOutlet var introView5: UIView!
    @IBOutlet var pageCtrl: UIPageControl!
    @IBOutlet var mainScrollView: UIScrollView!
    

    
    @IBOutlet weak var tradeModeLabel: UILabel!
    @IBOutlet weak var dashMask: UIView!
    @IBOutlet weak var dashImage: UIImageView!
    @IBOutlet weak var mobileImage: UIView!
    var initialFrame:CGRect = CGRect(x:0, y:0, width: 191, height: 108)
    var rotating:Bool = false
    
    
    var jump_just_once = true
    var scene: [HulaVideoTransp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jump_just_once = true
        scene[0].play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func initUI(){
        /*
        guard let path = Bundle.main.path(forResource: "slide_1_2", ofType:"mov") else {
            debugPrint("Video file not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = introView1.bounds
        introView1.layer.addSublayer(playerLayer)
        //NotificationCenter.default.addObserver(self, selector: #selector(HLMainViewController.playerEnded(notification:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.play()
        */
        let margin = CGFloat(20)
        let animation_frame = CGRect(origin: CGPoint(x:margin, y:100), size: CGSize(width: self.view.frame.width-margin*2, height: self.view.frame.width-margin*2))
        
        
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_1_2.atlas"))
        let skView = SKView(frame: animation_frame)
        skView.showsFPS = false
        skView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene[0])
        introView1.addSubview(skView)
 
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_2.atlas"))
        let skView2 = SKView(frame: animation_frame)
        skView2.showsFPS = false
        skView2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView2.showsNodeCount = false
        skView2.ignoresSiblingOrder = true
        skView2.presentScene(scene[1])
        introView2.addSubview(skView2)
        
        
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_3.atlas"))
        let skView3 = SKView(frame: animation_frame)
        skView3.showsFPS = false
        skView3.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView3.showsNodeCount = false
        skView3.ignoresSiblingOrder = true
        skView3.presentScene(scene[2])
        introView3.addSubview(skView3)
        
        
        
        self.dashImage.alpha = 0
        self.dashMask.alpha = 0
        self.mobileImage.alpha = 0
        self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
        self.tradeModeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
    }
    func initData(){
        pageCtrl.currentPage = 0
    }
    func initView(){
        introView1.frame = CGRect(x: 0.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView2.frame = CGRect(x: mainScrollView.frame.size.width, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView3.frame = CGRect(x: mainScrollView.frame.size.width * 2.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView5.frame = CGRect(x: mainScrollView.frame.size.width * 3.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        
        mainScrollView.addSubview(introView1)
        mainScrollView.addSubview(introView2)
        mainScrollView.addSubview(introView3)
        mainScrollView.addSubview(introView5)
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width * 4.0, height: 0)
        mainScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    
    func rotateAnimation(){
        if (rotating){
            return
        }
        rotating = true
        if pageCtrl.currentPage == 3 {
            self.mobileImage.alpha = 0
            self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2));
            
            self.dashImage.alpha = 0
            self.dashMask.alpha = 0
            self.dashMask.transform = .identity
            self.dashMask.frame = self.initialFrame
            
            UIView.animate(withDuration: 0.5, animations: {
                self.mobileImage.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    self.dashMask.alpha = 1
                    self.dashImage.alpha = 1
                }, completion: { (success) in
                    
                    
                    
                    UIView.animate(withDuration: 2.0, animations: {
                        self.mobileImage.alpha = 0
                    }, completion: { (success) in
                        self.mobileImage.transform = .identity
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.rotating = false
                            self.rotateAnimation()
                        }
                    })
                })
                
                UIView.animate( withDuration: 0.7, delay:0.4, animations: {
                    self.dashMask.frame.origin.x = 0
                    self.dashMask.frame.origin.y = -200
                    self.dashMask.transform = CGAffineTransform(rotationAngle: 0.8)
                })
            })
        }
    }
    
    //#MARK - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let posX: Int! = Int(round( mainScrollView.contentOffset.x / mainScrollView.frame.size.width) )
        pageCtrl.currentPage = posX
        
        scene[0].stop()
        scene[0].isPaused = true
        scene[1].stop()
        scene[1].isPaused = true
        scene[2].stop()
        scene[2].isPaused = true
        
        if (posX == 0 ){
            scene[0].isPaused = false
            scene[0].play()
        }
        
        
        if (posX == 1){
            scene[1].isPaused = false
            scene[1].play()
        }
        
        if (posX == 2){
            scene[2].isPaused = false
            scene[2].play()
        }
        
        if (posX == 3){
            self.rotateAnimation()
        }
        if (mainScrollView.contentOffset.x > 3.0 * mainScrollView.frame.size.width) {
            if (jump_just_once){
                jump_just_once = false;
                self.navToMainView()
            }
        }
    }
}
