//
//  HLProductTableViewCell.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductTableViewCell: UITableViewCell {
    
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productName: UILabel!
    @IBOutlet var productDistance: UILabel!
    @IBOutlet var productTradeRate: UILabel!
    @IBOutlet var verifiedMethodsView: UIView!
    @IBOutlet var selectedMarkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
