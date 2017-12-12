//
//  HLHomeNotificationsTableViewCell.swift
//  Hula
//
//  Created by Jose Bao on 4/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLHomeNotificationsTableViewCell: UITableViewCell {
    
    //MARK: Properties

    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var rotationIcon: UIImageView!
    @IBOutlet weak var NotificationsText: UILabel!
    @IBOutlet var NotificationImageView: UIImageView!
    @IBOutlet var NotificationsDate: UILabel!
    @IBOutlet weak var unreadIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
