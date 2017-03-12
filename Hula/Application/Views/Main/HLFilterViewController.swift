//
//  HLFilterViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFilterViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData() {
        
    }
    func initView() {
        self.changeDistanceFilterButtonSelctedState(1)
        self.changeTradeFilterButtonSelctedState(1)
        self.changeConditionFilterButtonSelctedState(1)
    }
    @IBAction func distanceFilterOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeDistanceFilterButtonSelctedState(button.tag)
    }
    @IBAction func tradeFilterOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeTradeFilterButtonSelctedState(button.tag - 5)
    }
    @IBAction func conditionOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeConditionFilterButtonSelctedState(button.tag - 11)
    }
    
    func changeDistanceFilterButtonSelctedState(_ index: Int!) {
        for i in 1 ..< 6 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
    }
    func changeTradeFilterButtonSelctedState(_ index: Int!) {
        for i in 6 ..< 12 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index + 5 == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
    }
    func changeConditionFilterButtonSelctedState(_ index: Int!) {
        for i in 12 ..< 14 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index + 11 == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
    }
}
