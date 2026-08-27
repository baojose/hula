//
//  HLFeedbackHistoryViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFeedbackHistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var feedbackList: NSArray = []

    /// Star scores are POSTed as integers (`val=1…5`) and often arrive as Int/NSNumber.
    /// `as? CGFloat` fails for those bridges and left the % label blank.
    class func feedbackScorePercent(from val: Any?) -> String? {
        let score: Double?
        if let v = val as? Double {
            score = v
        } else if let v = val as? Float {
            score = Double(v)
        } else if let v = val as? CGFloat {
            score = Double(v)
        } else if let v = val as? Int {
            score = Double(v)
        } else if let v = val as? NSNumber {
            // Reject Bool-bridged NSNumber (true/false → 1/0).
            let objCType = String(cString: v.objCType)
            if objCType == "c" || objCType == "B" {
                score = nil
            } else {
                score = v.doubleValue
            }
        } else {
            score = nil
        }
        guard let points = score else {
            return nil
        }
        let perc = Int(round(points * 20))
        return "\(perc)%"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        HLDataManager.sharedInstance.ga("feedback_history")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackList.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedbackHistoryCell") as! HLFeedbackHistoryTableViewCell
        if let this_fb = feedbackList[indexPath.row] as? NSDictionary{
            print(this_fb)
            if let label = HLFeedbackHistoryViewController.feedbackScorePercent(from: this_fb["val"]) {
                cell.feedbackPercentage.text = label
            }
            if let tmp = this_fb["comments"] as? String {
                cell.feedbackCommentLabel.text = "\(tmp)"
            }
            if let tmp = this_fb["giver_id"] as? String {
                cell.userImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: tmp))
            }
        }
        
        return cell
    }
}
