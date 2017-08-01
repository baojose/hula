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
    @IBAction func closeCalculatorAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func okAction(_ sender: Any) {
        
        self.calculatorDelegate?.amountSelected(amount: Float(amount)/100, side: self.side )
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func numberPressAction(_ sender: Any) {
        var number:Int = (sender as AnyObject).tag
        
        if (number == 10){
            number = 0;
        }
        let new_amount = "\(amount)" + "\(number)"
        
        amount = Int(new_amount)!
        updatePrice()
    }
    @IBAction func add1Action(_ sender: Any) {
        
        amount += 100
        updatePrice()
    }
    
    @IBAction func add5Action(_ sender: Any) {
        amount += 500
        updatePrice()
    }
    @IBAction func add10Action(_ sender: Any) {
        amount += 1000
        updatePrice()
    }
    @IBAction func clearAllAction(_ sender: Any) {
        amount = 0
        updatePrice()
    }
    @IBAction func clearNumberAction(_ sender: Any) {
        let str_amount = "\(amount)"
        if(str_amount.characters.count == 1){
            amount = 0
        } else {
            let index = str_amount.index(str_amount.startIndex, offsetBy: str_amount.characters.count - 1)
            let new_str = str_amount.substring(to: index)
            amount = Int(new_str)!
        }
        updatePrice()
    }
    
    func updatePrice(){
        //print(amount)
        let float_amount = CGFloat(amount)/100
        let twoDecimalPlaces = String(format: "%.2f", float_amount)
        priceLabel.text = "$\(twoDecimalPlaces)"
        //print(float_amount)
    }
}

protocol CalculatorDelegate {
    func amountSelected(amount:Float, side:String)
}
