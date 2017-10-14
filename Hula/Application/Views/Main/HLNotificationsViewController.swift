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
        
        if let is_read = notification.object(forKey: "is_read") as? Bool{
        
            if !is_read {
                cell.NotificationsText.font = UIFont(name:"HelveticaNeue-Regular", size: 14.0)
                cell.unreadIcon.isHidden = false
                cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            } else {
                cell.NotificationsText.font = UIFont(name:"HelveticaNeue-Light", size: 16.0)
                cell.unreadIcon.isHidden = true
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification : NSDictionary = dataManager.arrNotifications.object(at: indexPath.row) as! NSDictionary
        
        if let type = notification.object(forKey: "type") as? String{
            if (type == "trade"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myModalViewController = storyboard.instantiateViewController(withIdentifier: "swappView")
                myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.present(myModalViewController, animated: true, completion: nil)
            }
            
            if (type == "chat"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myModalViewController = storyboard.instantiateViewController(withIdentifier: "swappView") as! HLSwappViewController
                myModalViewController.redirect = notification.object(forKey: "from_id") as! String
                myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.present(myModalViewController, animated: true, completion: nil)
            }
        }
        
        if let notification_id = notification.object(forKey: "_id") as? String{
        
            let queryURL = HulaConstants.apiURL + "notifications/" + notification_id
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(ok)
                if (ok){
                    HLDataManager.sharedInstance.loadUserNotifications()
                    if ( HLDataManager.sharedInstance.numNotificationsPending > 0 ){
                        self.tabBarController?.tabBar.items?[1].badgeValue = "\(HLDataManager.sharedInstance.numNotificationsPending)"
                    } else {
                        self.tabBarController?.tabBar.items?[1].badgeValue = nil
                    }
                    tableView.reloadData()
                }
            })
        }
        
    }
    // IB Actions
    
    // Custom functions for ViewController
    
    
}

