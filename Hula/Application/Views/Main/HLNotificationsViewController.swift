//
//  HLNotificationsViewController.swift
//  Hula
//
//  Created by Jose Bao on 4/8/17.
//  Copyright © 2017 star. All rights reserved.
//


import UIKit

class NotificationsCategoryCell: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HLHomeNotificationsTableViewCell") as! HLFeedbackHistoryTableViewCell
        
        return cell
    }
}


