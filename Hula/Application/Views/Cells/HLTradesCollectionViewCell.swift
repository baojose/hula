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
        boxView.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha: 1.0).cgColor
        
        //boxView.clipsToBounds = true
        if (!isEmptyRoom){
            boxView.layer.shadowColor = UIColor.black.cgColor
            boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxView.layer.shadowOpacity = 0.2
            boxView.layer.shadowRadius = 2
            optionsDotsImage.alpha = 1.0
        } else {
            optionsDotsImage.alpha = 0.2
        }
        
        // test for commit
    }
    

}
