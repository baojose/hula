//
//  HLFeedbackHistoryTableViewCell.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFeedbackHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var feedbackIcon: UIImageView!
    @IBOutlet weak var feedbackCommentLabel: UILabel!
    @IBOutlet weak var feedbackPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
