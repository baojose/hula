//
//  HLCalculatorViewController.swift
//  Hula
//
//  Created by Juan Searle on 26/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLCalculatorViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    var amount:Int = 0
    var side:String = "owner"
    
    var calculatorDelegate: CalculatorDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        updatePrice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("calculator")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeCalculatorAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func okAction(_ sender: Any) {
        
        self.calculatorDelegate?.amountSelected(amount: amount, side: self.side )
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func numberPressAction(_ sender: Any) {
        let number = CalculatorAmountPolicy.digit(fromTag: (sender as AnyObject).tag)
        amount = CalculatorAmountPolicy.appendingDigit(number, to: amount)
        updatePrice()
    }
    @IBAction func add1Action(_ sender: Any) {
        
        amount += 1
        updatePrice()
    }
    
    @IBAction func add5Action(_ sender: Any) {
        amount += 5
        updatePrice()
    }
    @IBAction func add10Action(_ sender: Any) {
        amount += 10
        updatePrice()
    }
    @IBAction func clearAllAction(_ sender: Any) {
        amount = 0
        updatePrice()
    }
    @IBAction func clearNumberAction(_ sender: Any) {
        amount = CalculatorAmountPolicy.removingLastDigit(from: amount)
        updatePrice()
    }
    
    func updatePrice(){
        //print(amount)
        priceLabel.text = "$\(amount)"
        //print(float_amount)
    }
}

protocol CalculatorDelegate {
    func amountSelected(amount:Int, side:String)
}
