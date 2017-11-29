//
//  HLFinalFeedbackViewController.swift
//  Hula
//
//  Created by Juan Searle on 26/11/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFinalFeedbackViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    var good_str: String = ""
    var bad_str: String = ""
    var trade_id_closed : String = ""
    var user_id_closed : String = ""
    var points: Int = 3
    let first_copy : String = "We would love to hear how your trade was. Please rate it from one to five stars:"
    let second_copy : String = "What did you love?"
    let third_copy : String = "What went wrong?"
    let wrong_copies : [String] = ["Late arrival", "Bad estate of product", "Annoying negotiation", "Difficult communication", "Complicated process", "Other"]
    var step : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.text = first_copy
        // Do any additional setup after loading the view.
        for i in 101 ..< 107{
            let bt = self.view.viewWithTag(i) as? UIButton
            bt?.layer.cornerRadius = 20
            bt?.layer.borderColor = HulaConstants.appMainColor.cgColor
            bt?.layer.borderWidth = 1
            bt?.alpha = 0
            bt?.setBackgroundColor( .white, fors: .normal)
            bt?.setTitleColor( HulaConstants.appMainColor, for: .normal)
            bt?.setBackgroundColor( HulaConstants.appMainColor, fors: .selected)
            bt?.setTitleColor( .white, for: .selected)
            bt?.clipsToBounds = true
        }
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

    @IBAction func starsButtonAction(_ sender: Any) {
        let index = (sender as! UIButton).tag - 10
        self.points = index
        for i in 1 ... 5 {
            let star = self.view.viewWithTag(i) as! UIImageView
            if i <= index {
                star.image = UIImage(named: "star-fill")
                star.bouncer()
            } else {
                star.image = UIImage(named: "star-empty")
            }
        }
    }
    
    @IBAction func mainButtonAction(_ sender: UIButton) {
        print(sender.tag)
        
        sender.isSelected = !sender.isSelected
        
    }
    
    
    @IBAction func okButtonAction(_ sender: Any) {
        if step == 0 {
            step = 1
            for i in 101 ..< 107{
                let bt = self.view.viewWithTag(i) as? UIButton
                UIView.animate(withDuration: 0.2 + Double(i - 100)/9, animations: {
                    bt?.alpha = 1
                })
            }
            for i in 1 ..< 6{
                let st = self.view.viewWithTag(i)
                UIView.animate(withDuration: Double(i)/10, animations: {
                    st?.alpha = 0
                })
                let bt = self.view.viewWithTag(i+10)
                bt?.alpha = 0
            }
            mainLabel.text = second_copy
        } else {
            if step == 1 {
                step = 2
                good_str = ""
                for i in 101 ..< 107{
                    let st = self.view.viewWithTag(i) as? UIButton
                    if (st?.isSelected)! {
                        good_str = "\(good_str) \(st?.titleLabel?.text ?? "")"
                    }
                    UIView.animate(withDuration: Double(i-100)/10, animations: {
                        st?.alpha = 0
                    }, completion: { (success) in
                        st?.setTitle(self.wrong_copies[i - 101], for: .normal)
                        UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                            st?.alpha = 1
                        })
                        
                        st?.isSelected = false
                    })
                }
                mainLabel.text = third_copy
            } else {
                if step == 2 {
                    
                    bad_str = ""
                    for i in 101 ..< 107{
                        let st = self.view.viewWithTag(i) as? UIButton
                        if (st?.isSelected)! {
                            bad_str = "\(bad_str) \(st?.titleLabel?.text ?? "")"
                        }
                    }
                    // send data
                    sendFeedback()
                    
                }
            }
        }
        
        
    }
    
    
    func sendFeedback(){
            let queryURL = HulaConstants.apiURL + "feedback"
            let comments = "\(good_str). \(bad_str)"
            let dataString:String = "trade_id=\(self.trade_id_closed)&user_id=\(self.user_id_closed)&comments=\(comments)&val=\(points)"
            print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                if (ok){
                    print(json!)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                }
            })
    }
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, fors: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: fors)
    }
}
