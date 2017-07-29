//
//  HLNotificationsViewController.swift
//  Hula
//
//  Created by Juan Searle on 11/4/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLNotificationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var noNotificatiosnFoundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        /*
        let _ = checkUserLogin()
        if (!isUserLoggedIn){
            openUserIdentification()
        }
 */
        if (dataManager.arrNotifications.count == 0){
            notificationsView.isHidden = true
            noNotificatiosnFoundView.isHidden = false
        } else {
            notificationsView.isHidden = false
            noNotificatiosnFoundView.isHidden = true
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
        
        //print(notification)
        cell.NotificationsText.text = notification.object(forKey: "text") as? String
        
        commonUtils.circleImageView(cell.NotificationImageView)
        
        let date = commonUtils.isoDateToNSDate(date: (notification.object(forKey: "date") as? String)!)
        let relativeDate = commonUtils.timeAgoSinceDate(date: date, numericDates: false)
        cell.NotificationsDate.text = relativeDate
        if let usr = notification.object(forKey: "from_id") as? String{
            cell.NotificationImageView.loadImageFromURL(urlString: HulaConstants.apiURL + "users/\(usr)/image")
        }
        return cell
    }
    
    // IB Actions
    
    // Custom functions for ViewController
    
    
}

