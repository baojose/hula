//
//  HLTradesCollectionViewCell.swift
//  Hula
//
//  Created by Juan Searle on 29/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLTradesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tradeNumber: UILabel!
    @IBOutlet weak var emptyRoomLabel: UILabel!
    @IBOutlet weak var middleArrows: UIImageView!
    @IBOutlet weak var optionsDotsImage: UIImageView!
    @IBOutlet weak var left_side: UIView!
    @IBOutlet weak var right_side: UIView!
    @IBOutlet weak var myTurnView: UIView!
    @IBOutlet weak var otherTurnView: UIView!
    @IBOutlet weak var boxView: UIView!
    
    var dbDelegate: HLDashboardViewController?
    var tradeId: String = ""
    
    var isEmptyRoom = true;
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CommonUtils.sharedInstance.circleImageView(userImage)
        CommonUtils.sharedInstance.circleImageView(myImage)
        boxView.frame = CGRect(x: 8, y: 7, width: self.frame.width - 39, height: 59)
        left_side.frame = CGRect(x: 0, y: 0, width: boxView.frame.width/2, height: 59)
        right_side.frame = CGRect(x: boxView.frame.width/2, y: 0, width: boxView.frame.width/2, height: 59)
        boxView.layer.borderWidth = 1
        boxView.layer.cornerRadius = 4.0
        boxView.layer.borderColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha: 1.0).cgColor
        
        //boxView.clipsToBounds = true
        if (!isEmptyRoom){
            boxView.layer.shadowColor = UIColor.black.cgColor
            boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxView.layer.shadowOpacity = 0.2
            boxView.layer.shadowRadius = 3
            optionsDotsImage.alpha = 1.0
        } else {
            boxView.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha: 0).cgColor
            boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxView.layer.shadowOpacity = 0
            boxView.layer.shadowRadius = 0
            optionsDotsImage.alpha = 0.2
        }
        //print(self.frame)
        
        // test for commit
        self.transform = CGAffineTransform(scaleX: 1,y: 1);
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.tradeId != ""){
             UIView.animate(withDuration: 0.1, animations: {
             self.transform = CGAffineTransform(scaleX: 1.1,y: 1.1);
             
             })
             UIView.animate(withDuration: 0.1, animations: {
             self.transform = CGAffineTransform(scaleX: 1.1,y: 1.1);
             
             }, completion: { (ok) in
             UIView.animate(withDuration: 0.4, animations: {
             self.transform = CGAffineTransform(scaleX: 1,y: 1);
             })
             })
        super.touchesBegan(touches, with: event)
        }
    }
    

    
    @IBAction func tradeOptionsAction(_ sender: Any) {
        if (self.tradeId != ""){
            if dbDelegate != nil {
                let alert = UIAlertController(title: "Trade options",
                                              message: nil,
                                              preferredStyle: .actionSheet)
                
                let reportAction = UIAlertAction(title: "Report this user", style: .default, handler: { action -> Void in
                    
                })
                alert.addAction(reportAction)
                
                
                let removeAction = UIAlertAction(title: "Delete this trade", style: .destructive, handler: { action -> Void in
                    if (self.tradeId != ""){
                        self.closeTrade()
                    }
                })
                alert.addAction(removeAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                dbDelegate?.present(alert, animated: true)
            }
        }
    }
    
    func closeTrade(){
        if (self.tradeId != ""){
            let queryURL = HulaConstants.apiURL + "trades/\(self.tradeId)"
            let status = HulaConstants.end_status
            let dataString:String = "status=\(status)"
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                if (ok){
                    print(json!)
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Your trade has been canceled",
                                                      message: "We have moved it to your trade history page, inside your profile section.",
                                                      preferredStyle: .alert )
                        let reportAction = UIAlertAction(title: "Ok", style: .default, handler: { action -> Void in
                            
                        })
                        alert.addAction(reportAction)
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
}
