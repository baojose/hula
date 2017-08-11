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
    
    var isEmptyRoom = true;
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CommonUtils.sharedInstance.circleImageView(userImage)
        CommonUtils.sharedInstance.circleImageView(myImage)
        
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
        
        // test for commit
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
