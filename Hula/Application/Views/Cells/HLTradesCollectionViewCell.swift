//
//  HLTradesCollectionViewCell.swift
//  Hula
//
//  Created by Juan Searle on 29/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLTradesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tradeNumber: UILabel!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CommonUtils.sharedInstance.circleImageView(userImage)
    }
    

}
