//
//  HLIntroViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLIntroViewController: UserBaseViewController {
    
    @IBOutlet var introView1: UIView!
    @IBOutlet var introView2: UIView!
    @IBOutlet var introView3: UIView!
    @IBOutlet var introView4: UIView!
    @IBOutlet var introView5: UIView!
    @IBOutlet var pageCtrl: UIPageControl!
    
    
    var timer : Timer!
    var arrIntroViews : [UIView] = []
    
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
        self.startIntroTransition()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopIntroTransition()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func initUI(){

    }
    func initData(){
        arrIntroViews = [introView1, introView2, introView3, introView4, introView5]
        
        pageCtrl.currentPage = 0
    }
    func initView(){
        
    }
    
    func startIntroTransition() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(HLIntroViewController.introViewsTransition), userInfo: nil, repeats: true)
        }
    }
    func stopIntroTransition() {
        if (timer != nil) {
            timer.invalidate()
        }
        timer = nil
    }
    func introViewsTransition() {
        if (pageCtrl.currentPage != 4) {
            let showedView: UIView = arrIntroViews[pageCtrl.currentPage] 
            let willShowView: UIView = arrIntroViews[pageCtrl.currentPage + 1] 
            UIView.transition(from: showedView, to: willShowView, duration: 0.3 , options: UIViewAnimationOptions.transitionCrossDissolve, completion: nil)
            pageCtrl.currentPage = pageCtrl.currentPage + 1
            self.view.bringSubview(toFront: pageCtrl)
        }else{
            self.stopIntroTransition()
            self.navToMainView()
        }
    }
}
