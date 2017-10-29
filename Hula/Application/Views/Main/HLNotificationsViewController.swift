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
    
    @IBOutlet weak var notificationsTable: UITableView!
    var last_logged_user:String = ""
    var timer:Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.refreshNotifications), userInfo: nil, repeats: true)
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    override func viewDidAppear(_ animated: Bool) {
        /*
        let _ = checkUserLogin()
        if (!isUserLoggedIn){
            openUserIdentification()
        }
 */
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.refreshNotifications), userInfo: nil, repeats: true)
        
        if last_logged_user != HulaUser.sharedInstance.userId {
            last_logged_user = HulaUser.sharedInstance.userId
            HLDataManager.sharedInstance.loadUserNotifications()
        }
        
        if (dataManager.arrNotifications.count == 0){
            notificationsView.isHidden = true
            noNotificatiosnFoundView.isHidden = false
        } else {
            notificationsView.isHidden = false
            noNotificatiosnFoundView.isHidden = true
        }
        notificationsTable.reloadData()
        
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HLDataManager.sharedInstance.arrNotifications.count
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCategoryCell") as! HLHomeNotificationsTableViewCell
        let notification : NSDictionary = HLDataManager.sharedInstance.arrNotifications.object(at: indexPath.row) as! NSDictionary
        
        if let is_read = notification.object(forKey: "is_read") as? Bool{
        
            if !is_read {
                cell.NotificationsText.font = UIFont(name:"HelveticaNeue-Regular", size: 14.0)
                cell.unreadIcon.isHidden = false
                cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            } else {
                cell.NotificationsText.font = UIFont(name:"HelveticaNeue-Light", size: 16.0)
                cell.unreadIcon.isHidden = true
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        if let type = notification.object(forKey: "type") as? String{
            if (type == "start"){
                cell.rotationIcon.isHidden = true
                cell.forwardIcon.isHidden = false
            } else {
                cell.rotationIcon.isHidden = false
                cell.forwardIcon.isHidden = true
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
        let notification : NSDictionary = HLDataManager.sharedInstance.arrNotifications.object(at: indexPath.row) as! NSDictionary
        
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
            
            if (type == "start"){
                let user_id = notification.object(forKey: "from_id") as! String
                HLDataManager.sharedInstance.getUserProfile(userId: user_id, taskCallback: {(user, prods) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let myModalViewController = storyboard.instantiateViewController(withIdentifier: "sellerInfoPage") as! HLSellerInfoViewController
                    myModalViewController.user = user
                    myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                    myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    self.navigationController?.pushViewController(myModalViewController, animated: true)
                })
            }
        }
        
        if let notification_id = notification.object(forKey: "_id") as? String{
            let queryURL = HulaConstants.apiURL + "notifications/" + notification_id
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(ok)
                if (ok){
                    DispatchQueue.main.async {
                        HLDataManager.sharedInstance.loadUserNotifications()
                        tableView.reloadData()
                        self.updateTabBarCounter()
                    }
                }
            })
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // remove the item from the data model
            let notification : NSDictionary = HLDataManager.sharedInstance.arrNotifications.object(at: indexPath.row) as! NSDictionary
            
            
            
            /*
            // delete the table view row
                HLDataManager.sharedInstance.arrNotifications.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
             */
            if let notification_id = notification.object(forKey: "_id") as? String{
                let queryURL = HulaConstants.apiURL + "notifications/delete/" + notification_id
                HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                    //print(ok)
                    if (ok){
                        DispatchQueue.main.async {
                            
                            //tableView.deleteRows(at: [indexPath], with: .fade)
                            HLDataManager.sharedInstance.loadUserNotifications()
                            self.checkIfNotificationsLoaded()
                            self.updateTabBarCounter()
                        }
                    }
                })
            }
            
        }
    }
    // IB Actions
    func refreshNotifications(){
        HLDataManager.sharedInstance.loadUserNotifications()
        self.checkIfNotificationsLoaded()
    }
    
    // Custom functions for ViewController
    func checkIfNotificationsLoaded(){
        print("checking notifications...")
        if (HLDataManager.sharedInstance.isLoadingNotifications == false){
            //tableView.deleteRows(at: [indexPath], with: .fade)
            notificationsTable.reloadData()
            self.updateTabBarCounter()
            UIApplication.shared.applicationIconBadgeNumber = HLDataManager.sharedInstance.numNotificationsPending
        } else {
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                self.checkIfNotificationsLoaded()
            }
        }
    }
    func updateTabBarCounter(){
        
        if ( HLDataManager.sharedInstance.numNotificationsPending > 0 ){
            self.tabBarController?.tabBar.items?[1].badgeValue = "\(HLDataManager.sharedInstance.numNotificationsPending)"
        } else {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        }
    }
}

