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
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CommonUtils.sharedInstance.circleImageView(userImage)
        CommonUtils.sharedInstance.circleImageView(myImage)
    }
    

}
