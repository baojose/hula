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

    /// Empty tradeId must not PUT `trades/` or GET `trades//agree`.
    class func tradeUpdateURL(apiBase: String, tradeId: String?) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["trades", tradeId])
    }

    class func tradeAgreeURL(apiBase: String, tradeId: String?) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["trades", tradeId, "agree"])
    }

    class func notificationDeleteURL(apiBase: String, notificationId: String?) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["notifications", "delete", notificationId])
    }

    class func notificationReadURL(apiBase: String, notificationId: String?) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["notifications", notificationId])
    }

    /// Avatar GET. Blank from_id must not hit `users//image`.
    class func userImageURL(apiBase: String, userId: String?) -> String? {
        return CommonUtils.userImageURL(apiBase: apiBase, userId: userId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.refreshNotifications), userInfo: nil, repeats: true)
        
        
        let notificationsRecieved = Notification.Name("notificationsRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsLoadedCallback), name: notificationsRecieved, object: nil)
        HLDataManager.sharedInstance.getTrades(taskCallback: { (success) in
            // trades loaded
            print("trades loaded from notifications")
        })

    }
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
        //finishedLoadingInitialTableCells = false
    }
    override func viewDidAppear(_ animated: Bool) {
        /*
        let _ = checkUserLogin()
        if (!isUserLoggedIn){
            openUserIdentification()
        }
 */
        
        HLDataManager.sharedInstance.ga("notifications")
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
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCategoryCell") as! HLHomeNotificationsTableViewCell
        guard let notification = HLDataManager.sharedInstance.notification(at: indexPath.row) else {
            return cell
        }
        
        var is_old = false
        
        if let is_read = notification.object(forKey: "is_read") as? Bool{
        
            if !is_read {
                cell.NotificationsText.font = UIFont(name: HulaConstants.regular_font, size: 15.0)
                cell.unreadIcon.isHidden = false
                cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            } else {
                cell.NotificationsText.font = UIFont(name: HulaConstants.light_font, size: 15.0)
                cell.unreadIcon.isHidden = true
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            if let date = notification.object(forKey: "date") as? String, date.count > 0 {
                let realdate = CommonUtils.sharedInstance.isoDateToNSDate(date: date)
                let days_since = daysBetween(start: realdate as Date, end: NSDate() as Date )
                print(days_since);
                if days_since > 3 {
                    is_old = true;
                }
            }
            cell.newTradeActionView.isHidden = true
            if let type = notification.object(forKey: "type") as? String{
                if (type == "start"){
                    cell.rotationIcon.isHidden = true
                    cell.forwardIcon.isHidden = false
                    //if !is_read && !is_old {
                        print("old \(is_old)")
                        cell.rejectBtn.tag = indexPath.row;
                        cell.rejectBtn.addTarget(self, action: #selector(rejectBtnTapped), for: .touchUpInside)
                        cell.acceptBtn.tag = indexPath.row;
                        cell.acceptBtn.addTarget(self, action: #selector(acceptBtnTapped), for: .touchUpInside)
                        cell.newTradeActionView.isHidden = false
                    //}
                } else {
                    cell.rotationIcon.isHidden = false
                    cell.forwardIcon.isHidden = true
                }
            }
        }
        
        
        cell.NotificationsText.text = notification.object(forKey: "text") as? String
        commonUtils.circleImageView(cell.NotificationImageView)

        cell.NotificationsDate.text = commonUtils.relativeDateLabel(
            fromISO: notification.object(forKey: "date") as? String,
            numericDates: false
        )
        if let usr = notification.object(forKey: "from_id") as? String,
           let avatarURL = HLNotificationsViewController.userImageURL(apiBase: HulaConstants.apiURL, userId: usr) {
            cell.NotificationImageView.loadImageFromURL(urlString: avatarURL)
        }
        return cell
    }
    
    
    func rejectBtnTapped(_ sender:UIButton){
        let tag = sender.tag
        guard let notification = HLDataManager.sharedInstance.notification(at: tag) else { return }
        let notification_id = notification.object(forKey: "_id") as? String
        
        if let user_id = notification.object(forKey: "from_id") as? String{
            let tradeId = HLDataManager.sharedInstance.getTradeWith(user_id)
            if PendingOfferPolicy.shouldRunOfferAction(tradeId: tradeId) {
                // close trade
                guard let queryURL = HLNotificationsViewController.tradeUpdateURL(
                    apiBase: HulaConstants.apiURL,
                    tradeId: tradeId
                ) else {
                    return
                }
                let status = HulaConstants.cancel_status
                let dataString = CommonUtils.tradeStatusPostString(status: status)
                print(queryURL)
                HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                    if (ok){
                        if let nid = notification_id {
                            self.markAsReadNotification(nid)
                        }
                        HLDataManager.sharedInstance.getTrades(taskCallback: { (success) in
                            // update trade counts
                            print("Trades loaded from sellerinfo")
                        })
                    } else {
                        // connection error
                        print("Connection error")
                    }
                })
            }
        }
    }
    func acceptBtnTapped(_ sender:UIButton){
        
        let tag = sender.tag
        guard let notification = HLDataManager.sharedInstance.notification(at: tag) else { return }
        let notification_id = notification.object(forKey: "_id") as? String
        print("Accept pressed")
        if let user_id = notification.object(forKey: "from_id") as? String{
            let tradeId = HLDataManager.sharedInstance.getTradeWith(user_id)
            print("Trade id \(tradeId)")
            print("User id \(user_id)")
            if PendingOfferPolicy.shouldRunOfferAction(tradeId: tradeId) {
                // Agree first; only open the trade room after the server accepts.
                guard let queryURL = HLNotificationsViewController.tradeAgreeURL(
                    apiBase: HulaConstants.apiURL,
                    tradeId: tradeId
                ) else {
                    return
                }
                print("queryURL \(queryURL)");
                HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                    guard CommonUtils.agreeResponseSucceeded(ok: ok, json: json) else { return }
                    if let nid = notification_id {
                        self.markAsReadNotification(nid)
                    }
                    DispatchQueue.main.async {
                        if let portraitNC = self.tabBarController?.navigationController as? HulaPortraitNavigationController {
                            portraitNC.openSwapView()
                        }
                    }
                })
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let notification = HLDataManager.sharedInstance.notification(at: indexPath.row) else { return }
        
        if let type = notification.object(forKey: "type") as? String{
            if (type == "trade"){
                if let portraitNC = self.tabBarController?.navigationController as? HulaPortraitNavigationController {
                    portraitNC.openSwapView()
                }
                
            }
            
            if (type == "chat"){
                if let portraitNC = self.tabBarController?.navigationController as? HulaPortraitNavigationController {
                    portraitNC.openSwapView()
                }
            }
            
            if (type == "start"){
                if let user_id = notification.object(forKey: "from_id") as? String, user_id.count > 0 {
                    HLDataManager.sharedInstance.getUserProfile(userId: user_id, taskCallback: {(user, prods, userfeedback) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let myModalViewController = storyboard.instantiateViewController(withIdentifier: "sellerInfoPage") as! HLSellerInfoViewController
                        myModalViewController.user = user
                        myModalViewController.userProducts = prods
                        myModalViewController.userFeedback = userfeedback
                        myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                        myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        self.navigationController?.pushViewController(myModalViewController, animated: true)
                    })
                }
            }
        }
        
        if let notification_id = notification.object(forKey: "_id") as? String{
            markAsReadNotification(notification_id)
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // remove the item from the data model
            guard let notification = HLDataManager.sharedInstance.notification(at: indexPath.row) else { return }
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.alpha = 0.5
            
            /*
            // delete the table view row
                HLDataManager.sharedInstance.arrNotifications.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
             */
            if let notification_id = notification.object(forKey: "_id") as? String{
                guard let queryURL = HLNotificationsViewController.notificationDeleteURL(
                    apiBase: HulaConstants.apiURL,
                    notificationId: notification_id
                ) else {
                    return
                }
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
    
    func markAsReadNotification(_ notification_id:String){
        guard let queryURL = HLNotificationsViewController.notificationReadURL(
            apiBase: HulaConstants.apiURL,
            notificationId: notification_id
        ) else {
            return
        }
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                DispatchQueue.main.async {
                    HLDataManager.sharedInstance.loadUserNotifications()
                    self.notificationsTable.reloadData()
                    self.updateTabBarCounter()
                }
            }
        })
    }
    
    private var finishedLoadingInitialTableCells = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var lastInitialDisplayableCell = false
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if HLDataManager.sharedInstance.arrNotifications.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        if !finishedLoadingInitialTableCells {
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.rowHeight/2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    // IB Actions
    func refreshNotifications(){
        print("Notifications reloaded and propagated")
        HLDataManager.sharedInstance.loadUserNotifications()
        self.checkIfNotificationsLoaded()
    }
    
    func notificationsLoadedCallback(){
        notificationsTable.reloadData()
        checkIfNotificationsLoaded()
    }
    
    // Custom functions for ViewController
    func checkIfNotificationsLoaded(){
        print("checking notifications...")
        if (HLDataManager.sharedInstance.isLoadingNotifications == false){
            //tableView.deleteRows(at: [indexPath], with: .fade)
            notificationsTable.reloadData()
            self.updateTabBarCounter()
            UIApplication.shared.applicationIconBadgeNumber = HLDataManager.sharedInstance.numNotificationsPending
            
            if (dataManager.arrNotifications.count == 0){
                notificationsView.isHidden = true
                noNotificatiosnFoundView.isHidden = false
            } else {
                notificationsView.isHidden = false
                noNotificatiosnFoundView.isHidden = true
            }
        } else {
            print("...too soon.")
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

