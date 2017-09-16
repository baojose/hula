//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 14/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import SpriteKit

class HLSwappViewController: UIViewController {
    
    weak var barterDelegate: HLBarterScreenDelegate?
    
    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    //@IBOutlet weak var swappPageControl: HLPageControl!
    //@IBOutlet weak var nextTradeBtn: UIButton!
    //@IBOutlet weak var extraRoomBtn: UIButton!
    //@IBOutlet weak var extraRoomImage: UIImageView!
    @IBOutlet weak var mainCentralLabel: UILabel!
    @IBOutlet weak var otherUserNick: UILabel!
    @IBOutlet weak var otherUserImage: UIImageView!
    @IBOutlet weak var otherUserView: UIView!
    @IBOutlet weak var myUserView: UIView!
    @IBOutlet weak var bottomBarView: UIImageView!
    @IBOutlet weak var sendOfferBtn: HLRoundedButton!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var threeDotsView: UIView!
    @IBOutlet weak var addTradeRoomBtn: HLRoundedButton!
    @IBOutlet weak var chatButton: HLRoundedButton!
    var initialOtherUserX:CGFloat = 0.0
    
    var selectedScreen = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        CommonUtils.sharedInstance.circleImageView(otherUserImage)
        self.myUserView.isHidden = true;
        self.otherUserView.isHidden = true;
        self.sendOfferBtn.alpha = 0;
        self.remainingTimeLabel.alpha = 0;
        self.addTradeRoomBtn.alpha = 1;
        self.mainCentralLabel.alpha = 0;
        
        
        self.mobileImage.alpha = 0
        self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
        
        let threeDots = HLThreeDotsWaiting(size: CGSize(width:40, height:10))
        let skView = SKView(frame: CGRect(x: 0, y: 0, width: 40, height: 10))
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(threeDots)
        threeDotsView.addSubview(skView)
        threeDots.animateDots()
        threeDotsView.isHidden = true
        controlSetupBottomBar(index:0);
    }
    override func viewWillAppear(_ animated: Bool) {
        
        // rotation effect
        self.portraitView.frame.origin.y = 0
        self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
        if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.6) {
                    self.portraitView.frame.origin.y = 1000
                    self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        initialOtherUserX = self.view.frame.width - self.otherUserView.frame.width
        self.myUserView.frame.origin.x = -500
        self.otherUserView.frame.origin.x = self.view.frame.width + 500
        self.myUserView.isHidden = false;
        self.otherUserView.isHidden = false;
        
        self.addTradeRoomBtn.alpha = 1;
        self.mainCentralLabel.alpha = 0;
        
        
        self.rotateAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let swappPageViewController = segue.destination as? HLSwappPageViewController {
            swappPageViewController.swappDelegate = self
        }
        
        
        if let chatVC = segue.destination as? ChatViewController {
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                let thisTrade: NSDictionary = swappPageVC.arrTrades[swappPageVC.currentIndex]
                if let chat = thisTrade.object(forKey: "chat") as? [NSDictionary]{
                    chatVC.chat = chat
                    chatVC.trade_id = (thisTrade.object(forKey: "_id") as? String)!
                    //print(chat)
                }
            }
        }
    }
    
    @IBAction func closeSwappMode(_ sender: Any) {
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func rotateAnimation(){
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            mobileImage.alpha = 0
            self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2));
            UIView.animate(withDuration: 0.5, animations: {
                self.mobileImage.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1.2, animations: {
                    self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                }, completion: { (success) in
                    UIView.animate(withDuration: 1.5, animations: {
                        self.mobileImage.alpha = 0
                    }, completion: { (success) in
                        self.mobileImage.transform = .identity
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            
                            self.rotateAnimation()
                        }
                    })
                })
            })
        }
    }
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            self.portraitView.frame.origin.y = 0
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            portraitView.isHidden = false
            self.dismiss(animated: true) {
                // After dismiss
            }
        } else {
            DispatchQueue.main.async {
                //portraitView.isHidden = true
                UIView.animate(withDuration: 0.6) {
                    self.portraitView.frame.origin.y = 1000
                    self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                }
            }
        }
    }
    
    @IBAction func extraRoomAction(_ sender: Any) {
    }
    
    /*
    @IBAction func nextTradeAction(_ sender: Any) {
        //print(self.childViewControllers)
        
        if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
            let nextPage = swappPageControl.currentPage + 1
            //print(nextPage)
            //print(swappPageVC.arrTrades.count)
            let thisTrade: NSDictionary = swappPageVC.arrTrades[nextPage - 1]
            swappPageVC.currentTrade = thisTrade
            swappPageVC.goTo(page: nextPage)
            
        }
        
    }
    */
    @IBAction func backToLobbyAction(_ sender: Any) {
        if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
            swappPageVC.goTo(page: 0)
        }
    }
    @IBAction func sendOfferAction(_ sender: Any) {
        if let tradeStatus = barterDelegate?.getCurrentTradeStatus() {
            //print("tradeStatus: \(tradeStatus)")
            let trade_id = tradeStatus.tradeId
            let turn_id = tradeStatus.turn_user_id
            //print(tradeStatus.owner_products)
            if (turn_id != HulaUser.sharedInstance.userId){
                print("This is not your turn!!!")
            } else {
                let queryURL = HulaConstants.apiURL + "trades/\(trade_id!)"
                let owner_products = tradeStatus.owner_products.joined(separator: ",")
                let other_products = tradeStatus.other_products.joined(separator: ",")
                var status = HulaConstants.sent_status
                if (sender as? UIButton)!.tag == 91053 {
                    status = HulaConstants.end_status
                }
                let dataString:String = "status=\(status)&owner_products=\(owner_products)&other_products=\(other_products)"
                //print(dataString)
                HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                    if (ok){
                        //print(json!)
                        DispatchQueue.main.async {
                            
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                            
                            viewController.delegate = self as AlertDelegate
                            viewController.isCancelVisible = false
                            
                            if (sender as? UIButton)!.tag == 91053 {
                                viewController.message = "Your offer has been closed. Contact with the user to exchange the selected products.\nIn order to free up this trading room, this trade will be moved to your trade history, on your profile area."
                            } else {
                                viewController.message = "Your offer has been sent with your changes.\nPlease allow 72 hours for the user to reply."
                            }
                            
                            
                            self.present(viewController, animated: true)
                        }
                    } else {
                        // connection error
                        print("Connection error")
                    }
                })
            }
        } else {
            print("No trade/barter delegato vc found!")
        }
    }
    func controlSetupBottomBar(index:Int){
        //print("seting up bottom bar with index: \(index)")
        
        if (index != 0){
            UIView.animate(withDuration: 0.3) {
                /*
                self.extraRoomBtn.alpha = 0
                self.extraRoomImage.alpha = 0
                self.nextTradeBtn.alpha = 0
 */
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = 0
                self.otherUserView.frame.origin.x = self.view.frame.width - self.otherUserView.frame.width
                self.sendOfferBtn.alpha = 1
                self.chatButton.alpha = 1
                
                self.addTradeRoomBtn.alpha = 0;
                self.mainCentralLabel.alpha = 0;
            }
            self.threeDotsView.isHidden = true;
            
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                let thisTrade: NSDictionary = swappPageVC.arrTrades[swappPageVC.currentIndex]
                
                var other_user_id = ""
                
                if (HulaUser.sharedInstance.userId == thisTrade.object(forKey: "owner_id") as! String){
                    // I am the owner
                    other_user_id = thisTrade.object(forKey: "other_id") as! String
                } else {
                    other_user_id = thisTrade.object(forKey: "owner_id") as! String
                }
                if let current_user_turn = thisTrade.object(forKey: "turn_user_id") as? String{
                    if current_user_turn != HulaUser.sharedInstance.userId {
                        self.sendOfferBtn.alpha = 0
                        self.mainCentralLabel.alpha=1;
                        self.mainCentralLabel.text = "Waiting for user reply"
                        let h_str = thisTrade.object(forKey: "last_update") as! String
                        let date = h_str.dateFromISO8601?.addingTimeInterval(HulaConstants.courtesyTime * 60.0 * 60.0)
                        //print(date)
                        
                        let formatter = DateComponentsFormatter()
                        formatter.allowedUnits = [.hour]
                        formatter.unitsStyle = .short
                        var str_hours = formatter.string(from: Date(), to: date!)!
                        str_hours = (str_hours.replacingOccurrences(of: " hr", with: ""))
                        if (str_hours[0] == "-"){
                            str_hours = "0";
                        }
                        
                        self.remainingTimeLabel.alpha = 1
                        self.remainingTimeLabel.text = "Remaining time for response: \(str_hours)"
                        self.threeDotsView.isHidden = false;
                        
                    } else {
                        self.remainingTimeLabel.alpha = 0;
                        self.threeDotsView.isHidden = true;
                        if self.tradeCanBeClosed(thisTrade) {
                            // can be closed
                            self.sendOfferBtn.titleLabel?.text = "Accept trade"
                            self.sendOfferBtn.tag = 91053
                            
                        } else {
                            self.sendOfferBtn.titleLabel?.text = "Send offer"
                            self.sendOfferBtn.tag = 1
                        }
                    }
                    
                }
                
                otherUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: other_user_id))

                let queryURL = HulaConstants.apiURL + "users/\(other_user_id)/nick"
                HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (result, json) in
                    
                    if let dict = json as? [String:String]{
                    //print(dict)
                        if let nick = dict["nick"] {
                            //print(nick)
                            DispatchQueue.main.async {
                                self.otherUserNick.text = nick
                            }
                        }
                    }
                })
                
            }
            
            
        } else {
            UIView.animate(withDuration: 0.3) {
                /*
                self.extraRoomBtn.alpha = 1
                self.extraRoomImage.alpha = 1
                self.nextTradeBtn.alpha = 1
                 */
                self.addTradeRoomBtn.alpha = 1;
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = -500
                self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                self.sendOfferBtn.alpha = 0
                //self.mainCentralLabel.text = "Available Table Rooms"
                self.chatButton.alpha = 0
                self.remainingTimeLabel.alpha = 0;
                self.threeDotsView.isHidden = true
            }
        }
    }
    
    func tradeCanBeClosed(_ trade:NSDictionary) -> Bool{
        if let bids = trade.object(forKey: "bids") as? NSArray{
            //print(bids.count)
            
            if let isMutated = barterDelegate?.isTradeMutated(){
                
                if (bids.count > 1) && (!isMutated) {
                    return true
                }
            }
        }
        return false
    }
    
}

extension HLSwappViewController: SwappPageViewControllerDelegate {
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageCount count: Int) {
        //swappPageControl.numberOfPages = count
    }
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageIndex index: Int) {
        //swappPageControl.currentPage = index
        
        controlSetupBottomBar(index: index)
    }
    
    
}

protocol HLBarterScreenDelegate: class {
    func getCurrentTradeStatus() -> HulaTrade
    func isTradeMutated() -> Bool!
}

extension HLSwappViewController: AlertDelegate{
    func alertResponded(response: String) {
        print("Response: \(response)")
        
        DispatchQueue.main.async {
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                swappPageVC.goTo(page: 0)
            }
        }
    }
}
