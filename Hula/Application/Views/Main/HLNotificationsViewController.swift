//
//  HLNotificationsViewController.swift
//  Hula
//
//  Created by Juan Searle on 11/4/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLNotificationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        let user = HulaUser.sharedInstance
        if (user.token.characters.count < 10){
            // user not logged in
            openUserIdentification()
        } else {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.arrNotifications.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCategoryCell") as! HLHomeNotificationsTableViewCell
        let notification : NSDictionary = dataManager.arrNotifications.object(at: indexPath.row) as! NSDictionary
        
        
        cell.NotificationsText.text = notification.object(forKey: "text") as? String
        //cell.categoryName.attributedText = commonUtils.attributedStringWithTextSpacing(category.object(forKey: "name") as! String, CGFloat(2.33))
        //cell.categoryImage.image = UIImage.init(named: category.object(forKey: "icon") as! String)
        //cell.categoryProductNum.text = String(format:"%i products", (category.object(forKey: "num_products") as! Int))
        
        return cell
    }
}

