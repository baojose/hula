//
//  HLTradesCollectionViewCell.swift
//  Hula
//
//  Created by Juan Searle on 29/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLTradesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tradeArrowsImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cellSeparatorView: UIImageView!
    @IBOutlet weak var tradeNumber: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tradeArrowsImage.transform = tradeArrowsImage.transform.rotated(by: CGFloat( Double.pi/2))
        
        CommonUtils.sharedInstance.circleImageView(userImage)
    }
    

}
