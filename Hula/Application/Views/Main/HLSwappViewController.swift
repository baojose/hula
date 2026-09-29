//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 14/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import SpriteKit
import FacebookShare
import CoreMotion

class HLSwappViewController: UIViewController {
    
    weak var barterDelegate: HLBarterScreenDelegate?
    
    @IBOutlet weak var tradeModeLabel: UILabel!
    @IBOutlet weak var dashMask: UIView!
    @IBOutlet weak var dashImage: UIImageView!
    @IBOutlet weak var mobileImage: UIView!
    
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
    @IBOutlet weak var otherOfferBtn: HLRoundedButton!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var chatCountLbl: UILabel!
    @IBOutlet weak var tradeModeLine: UIView!
    @IBOutlet weak var currentTradesBtn: UIButton!
    @IBOutlet weak var pastTradesBtn: UIButton!
    @IBOutlet weak var threeDotsView: UIView!
    @IBOutlet weak var addTradeRoomBtn: HLRoundedButton!
    @IBOutlet weak var chatButton: HLRoundedButton!
    @IBOutlet weak var myCheckMark: UIImageView!
    @IBOutlet weak var otherCheckMark: UIImageView!
    
    @IBOutlet weak var pastChatCountLbl: UILabel!
    var initialOtherUserX:CGFloat = 0.0
    
    var motionManager = CMMotionManager();
    
    var selectedScreen = 0
    var initialFrame:CGRect = CGRect(x:0, y:0, width: 191, height: 108)
    var prevUser: String = ""
    var tradeMode = "current"
    var last_index_setup:Int = 0
    var trade_id_closed : String = ""
    var user_id_closed : String = ""
    var redirect: String = ""
    var backFromChat: Bool = false
    var tempTag: Int = 0
    var detection_counter : Int = 0;
    
    let kTagJustAccept: Int = 1;
    let kTagCloseDeal: Int = 91053;
    let kTagProductsReceived: Int = 90441
    
    var firstLoad : Bool = true

    /// Share-reward extra room. Cap at 50 so a share loop cannot inflate maxTrades unboundedly.
    class func shouldGrantExtraTradeRoom(maxTrades: Int) -> Bool {
        return maxTrades < 50
    }

    /// Send-offer routing. An empty product side still goes through the donation
    /// gate, including Close Deal, so a one-sided tray cannot skip the warning.
    class func offerSendRoute(
        ownerProductCount: Int,
        otherProductCount: Int,
        buttonTag: Int,
        closeDealTag: Int
    ) -> String {
        return OfferSubmissionPolicy.sendOfferRoute(
            ownerProductCount: ownerProductCount,
            otherProductCount: otherProductCount,
            buttonTag: buttonTag,
            closeDealTag: closeDealTag
        )
    }

    /// Donation / empty-tray gate. Nil owner or viewer ids must not unwrap.
    class func offerDonationDecision(
        ownerProductCount: Int,
        otherProductCount: Int,
        ownerMoney: Float,
        otherMoney: Float,
        ownerId: String?,
        viewerId: String?
    ) -> String {
        return OfferSubmissionPolicy.donationDecision(
            ownerProductCount: ownerProductCount,
            otherProductCount: otherProductCount,
            ownerMoney: ownerMoney,
            otherMoney: otherMoney,
            ownerId: ownerId,
            viewerId: viewerId
        )
    }

    /// PUT body for Accept vs Close Deal vs Products Received.
    class func offerSubmittedFields(
        buttonTag: Int,
        closeDealTag: Int,
        productsReceivedTag: Int
    ) -> (status: String, accepted: Bool) {
        return OfferSubmissionPolicy.submittedFields(
            buttonTag: buttonTag,
            closeDealTag: closeDealTag,
            productsReceivedTag: productsReceivedTag
        )
    }

    /// Feedback target after an offer write. The owner records the peer; everyone
    /// else records the owner. A nil id becomes an empty string instead of crashing.
    class func offerCounterpartyId(ownerId: String?, otherId: String?, viewerId: String?) -> String {
        return OfferSubmissionPolicy.counterpartyId(
            ownerId: ownerId,
            otherId: otherId,
            viewerId: viewerId
        )
    }

    /// Giveaway confirmation copy differs by role. Keep both historical strings.
    class func giveawayAlertMessage(viewerIsOwner: Bool) -> String {
        if viewerIsOwner {
            return NSLocalizedString("Are you giving your stuff away for free? If not, choose the item you want to exchange it with.", comment: "")
        }
        return NSLocalizedString("Are you giving your stuff away for free? If not, choose something you want to exchange it with.", comment: "")
    }

    /// Facebook app-invite placeholders used `URL(string:)!`.
    class func facebookAppInviteURLs() -> (appLink: URL, previewImageURL: URL?)? {
        return FacebookInvitePolicy.inviteURLs()
    }

    /// Trade-room accelerometer used `OperationQueue.current!`.
    class func accelerometerUpdatesQueue(_ current: OperationQueue?) -> OperationQueue {
        return MotionUpdatePolicy.updatesQueue(current)
    }

    /// Soft-parse trade `last_update` into remaining courtesy hours for the waiting-turn label.
    /// Missing/malformed dates return nil so callers can hide the label instead of crashing.
    class func remainingResponseHoursLabel(
        lastUpdate: Any?,
        now: Date = Date(),
        courtesyHours: Double = HulaConstants.courtesyTime
    ) -> String? {
        guard let h_str = lastUpdate as? String, !h_str.isEmpty,
              let date = h_str.dateFromISO8601?.addingTimeInterval(courtesyHours * 60.0 * 60.0) else {
            return nil
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour]
        formatter.unitsStyle = .short
        guard var str_hours = formatter.string(from: now, to: date) else {
            return nil
        }
        str_hours = (str_hours.replacingOccurrences(of: " hr", with: " h"))
        if str_hours.hasPrefix("-") {
            str_hours = "0"
        }
        return str_hours
    }

    /// Empty/nil tradeId must not PUT `trades/` or GET `trades//ready`.
    class func sanitizedTradeId(_ tradeId: String?) -> String? {
        return CommonUtils.nonEmptyTrimmed(tradeId)
    }

    class func offerReadyURL(apiBase: String, tradeId: String) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["trades", tradeId, "ready"])
    }

    class func offerUpdateURL(apiBase: String, tradeId: String) -> String? {
        return CommonUtils.apiResourceURL(apiBase: apiBase, path: ["trades", tradeId])
    }

    /// Trade-room nick lookup. Blank peer id must not hit `users//nick`.
    class func userNickURL(apiBase: String, userId: String?) -> String? {
        return CommonUtils.userResourceURL(apiBase: apiBase, userId: userId, extra: ["nick"])
    }

    /// Post-deal feedback. Blank resource must not POST to the API root.
    class func feedbackURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "feedback")
    }

    /// Encode product-id lists so Close Deal / Send Offer cannot split the form body.
    class func offerPostString(
        status: String,
        ownerProducts: [String],
        otherProducts: [String],
        ownerMoney: Float,
        otherMoney: Float,
        accepted: Bool
    ) -> String {
        let ownerEncoded = CommonUtils.formEncodedValue(ownerProducts.joined(separator: ","))
        let otherEncoded = CommonUtils.formEncodedValue(otherProducts.joined(separator: ","))
        let acceptedTrade = accepted ? "true" : "false"
        return "status=" + CommonUtils.formEncodedValue(status)
            + "&owner_products=" + ownerEncoded
            + "&other_products=" + otherEncoded
            + "&owner_money=\(Int(ownerMoney))"
            + "&other_money=\(Int(otherMoney))"
            + "&accepted=" + acceptedTrade
    }

    /// Current/past toggle used `(childViewControllers.first?.childViewControllers)!`.
    class func nestedChildViewControllers(from parent: UIViewController?) -> [UIViewController] {
        guard let children = parent?.childViewControllers.first?.childViewControllers else {
            return []
        }
        return children
    }

    /// Ready checkmarks used `trade!` after a nil test. Missing snapshots must
    /// not unwrap, and owner/other ready must keep the historical mapping.
    class func viewerIsReady(trade: HulaTrade?, viewerId: String?) -> Bool {
        return TradeReadyPolicy.viewerIsReady(trade: trade, viewerId: viewerId)
    }

    class func peerIsReady(trade: HulaTrade?, viewerId: String?) -> Bool {
        return TradeReadyPolicy.peerIsReady(trade: trade, viewerId: viewerId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        CommonUtils.sharedInstance.circleImageView(otherUserImage)
        self.sendOfferBtn.alpha = 0;
        self.otherOfferBtn.alpha = 0;
        self.myCheckMark.alpha = 0;
        self.otherCheckMark.alpha = 0;
        self.remainingTimeLabel.alpha = 0;
        self.addTradeRoomBtn.alpha = 1;
        self.mainCentralLabel.alpha = 0;
        
        self.chatCountLbl.layer.cornerRadius = 6.5
        self.pastChatCountLbl.layer.cornerRadius = 6.5
        
        self.chatCountLbl.clipsToBounds = true
        self.pastChatCountLbl.clipsToBounds = true
        
        
        self.currentTradesBtn.alpha = 1;
        self.pastTradesBtn.alpha = 1
        self.tradeModeLine.frame.origin.x = self.currentTradesBtn.frame.origin.x
        self.tradeModeLine.frame.size.width = self.currentTradesBtn.frame.size.width
        HLDataManager.sharedInstance.tradeMode = "current"
        
        
        self.dashImage.alpha = 0
        self.dashMask.alpha = 0
        self.mobileImage.alpha = 0
        self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
        self.tradeModeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        
        let threeDots = HLThreeDotsWaiting(size: CGSize(width:40, height:10))
        let skView = SKView(frame: CGRect(x: threeDotsView.frame.width/2 - 20, y: 0, width: 40, height: 10))
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(threeDots)
        threeDotsView.addSubview(skView)
        threeDots.animateDots()
        threeDotsView.isHidden = true
        controlSetupBottomBar(index:0);
        
        firstLoad = true
        
        motionManager.accelerometerUpdateInterval = 0.6;
        
        
        if #available(iOS 11.0, *) {
            print("####  setNeedsUpdateOfScreenEdgesDeferringSystemGestures");
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        //print("prefersHomeIndicatorAutoHidden in Swapp")
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        //print(UIDevice.current.orientation)
        
        if (firstLoad) {
            firstLoad = false
            var isNeutral = true
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                //print("portrait!!!!")
                isNeutral = false
            }
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                //print("landscape!!!!")
                isNeutral = false
            }
            if isNeutral && self.view.frame.width > self.view.frame.height {
                isNeutral = false
                self.portraitView.frame.origin.y = 1000
                self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
            }
            
            
            // rotation effect
            //self.portraitView.frame.origin.y = 0
            self.portraitView.frame = self.view.frame
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) && !isNeutral {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6) {
                        self.portraitView.frame.origin.y = 1000
                        self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                    }
                }
            }
        
        }
        HLDataManager.sharedInstance.onlyLandscapeView = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        threeDotsView.frame.origin.x = otherOfferBtn.frame.origin.x + otherOfferBtn.frame.width/2 - 20;
        motionManager.startAccelerometerUpdates(to: HLSwappViewController.accelerometerUpdatesQueue(OperationQueue.current)){ (data, error) in
            if let xc = data?.acceleration.x {
                if abs( xc ) > 0.8 {
                    // portrait mode
                    self.detection_counter += 1
                    if self.detection_counter > 5{
                        self.detection_counter = 0;
                        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)  {
                            let alert = UIAlertController(title: NSLocalizedString("Rotation lock is activated", comment: ""), message: NSLocalizedString("Please unlock your iPhone rotation lock. You can do it from the control center.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
        
        
        if !self.backFromChat {
            controlSetupBottomBar(index:last_index_setup);
        }
        self.backFromChat = false
        self.rotateAnimation()
        
        
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        } else {
            // Fallback on earlier versions
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        motionManager.stopAccelerometerUpdates()
        let app = UIApplication.shared.delegate as! AppDelegate
        app.allowRotation = true;
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
                guard let thisTrade = DashboardTradeSelection.resolvedTrade(
                    currentTrade: swappPageVC.currentTrade,
                    currentIndex: swappPageVC.currentIndex,
                    trades: swappPageVC.arrTrades
                ) else {
                    return
                }
                // trade_id must be set even when `chat` is missing/null/non-array;
                // otherwise ChatViewController hits trades//chat and drops messages.
                let config = HLSwappViewController.chatConfiguration(from: thisTrade)
                chatVC.trade_id = config.tradeId
                chatVC.chat = config.chat
                //print(chat)
                self.backFromChat = true
                self.chatCountLbl.isHidden = true
            }
        }
    }

    /// Extract chat seed data for the trade-room → Chat segue.
    static func chatConfiguration(from trade: NSDictionary) -> (tradeId: String, chat: [NSDictionary]) {
        let tradeId = trade.object(forKey: "_id") as? String ?? ""
        let chat = trade.object(forKey: "chat") as? [NSDictionary] ?? []
        return (tradeId, chat)
    }

    /// Peer id + viewer unread badge for a trade dict.
    /// Soft-parses unread via intFromJSON so bridged NSNumber counts are not dropped.
    static func peerChatContext(from trade: NSDictionary, viewerId: String) -> (peerId: String, unread: Int) {
        let ownerId = trade.object(forKey: "owner_id") as? String ?? ""
        let otherId = trade.object(forKey: "other_id") as? String ?? ""
        if viewerId == ownerId {
            let unread = CommonUtils.intFromJSON(trade.object(forKey: "owner_unread")) ?? 0
            return (otherId, unread)
        }
        let unread = CommonUtils.intFromJSON(trade.object(forKey: "other_unread")) ?? 0
        return (ownerId, unread)
    }
    
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        print("*preferredScreenEdges")
        return .all
    }
    
    @IBAction func closeSwappMode(_ sender: Any) {
        HLDataManager.sharedInstance.isInSwapVC = false
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
        var hasToDismiss = true
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            //print("portrait!!!!")
            hasToDismiss = false
        }
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            //print("landscape!!!!")
            hasToDismiss = false
        }
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) || hasToDismiss{
            mobileImage.alpha = 0
            self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2));
            
            self.dashImage.alpha = 0
            self.dashMask.alpha = 0
            self.dashMask.transform = .identity
            self.dashMask.frame = self.initialFrame
            
            UIView.animate(withDuration: 0.5, animations: {
                self.mobileImage.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    self.dashMask.alpha = 1
                    self.dashImage.alpha = 1
                }, completion: { (success) in
                    
                    UIView.animate(withDuration: 2.0, animations: {
                        self.mobileImage.alpha = 0
                    }, completion: { (success) in
                        self.mobileImage.transform = .identity
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            
                            self.rotateAnimation()
                        }
                    })
                })
                
                UIView.animate( withDuration: 0.7, delay:0.4, animations: {
                    self.dashMask.frame.origin.x = 0
                    self.dashMask.frame.origin.y = -200
                    self.dashMask.transform = CGAffineTransform(rotationAngle: 0.8)
                })
            })
        }
    }
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)  {
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            self.portraitView.frame.origin.y = 0
            self.portraitView.frame.size.height = self.view.frame.height
            portraitView.isHidden = false
            rotateAnimation()
            //print("pre dismiss")
            HLDataManager.sharedInstance.isInSwapVC = false
            if !HLDataManager.sharedInstance.onlyLandscapeView {
                //print(self.presentingViewController)
                self.presentingViewController?.dismiss(animated: true) {
                    //print("post dismiss")
                    // After dismiss
                }
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
            guard let tag = ControlSenderPolicy.tag(from: sender) else {
                return
            }
            self.tempTag = tag

            let route = HLSwappViewController.offerSendRoute(
                ownerProductCount: tradeStatus.owner_products.count,
                otherProductCount: tradeStatus.other_products.count,
                buttonTag: self.tempTag,
                closeDealTag: self.kTagCloseDeal
            )
            if route == OfferSubmissionPolicy.needsDonationCheck {
                manageDonationMessages(tradeStatus: tradeStatus, okStatus:"donation")
                return
            }
            if route == OfferSubmissionPolicy.confirmClose {
                manageConfirmation(tradeStatus: tradeStatus, okStatus:"doit")
                return
            }

            executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
            
        } else {
            print("No trade/barter delegate vc found!")
        }
    }
    
    func manageDonationMessages(tradeStatus:HulaTrade, okStatus:String){
        let decision = HLSwappViewController.offerDonationDecision(
            ownerProductCount: tradeStatus.owner_products.count,
            otherProductCount: tradeStatus.other_products.count,
            ownerMoney: tradeStatus.owner_money,
            otherMoney: tradeStatus.other_money,
            ownerId: tradeStatus.owner_id,
            viewerId: HulaUser.sharedInstance.userId
        )
        if decision == OfferSubmissionPolicy.blockNoItems {
            showAlert(message:NSLocalizedString("Sorry, drag at least one item to send your offer.", comment: ""), trigger:"notrade", cancelVisible:false, okText:"Ok")
            return
        }
        if decision == OfferSubmissionPolicy.blockViewerEmpty {
            showAlert(message:NSLocalizedString("No offer without an item from your side. Unless you wanna offer cash...", comment: ""), trigger:"notrade", cancelVisible:false, okText:NSLocalizedString("OK", comment: ""))
            return
        }
        if decision == OfferSubmissionPolicy.confirmGiveaway {
            let viewerIsOwner = OfferSubmissionPolicy.viewerIsOwner(
                ownerId: tradeStatus.owner_id,
                viewerId: HulaUser.sharedInstance.userId
            )
            showAlert(
                message: HLSwappViewController.giveawayAlertMessage(viewerIsOwner: viewerIsOwner),
                trigger: okStatus,
                cancelVisible: true,
                okText: NSLocalizedString("OK!", comment: "")
            )
            return
        }
        executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
    }
    
    func manageConfirmation(tradeStatus:HulaTrade, okStatus:String){
        showAlert(message:NSLocalizedString("You are about to close the deal. Confirm?", comment: ""), trigger:okStatus, cancelVisible:true, okText: NSLocalizedString("Yes!", comment: ""))
    }
    
    func showAlert(message:String, trigger:String, cancelVisible:Bool,  okText:String){
    
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        
        viewController.delegate = self as AlertDelegate
        viewController.isCancelVisible = cancelVisible
        viewController.okButtonText = okText
        viewController.message = message
        viewController.trigger = trigger
        self.present(viewController, animated: true)
    }
    
    func executeOfferOptions(_ tradeStatus: HulaTrade, buttonTag: Int){
        
        //print("tradeStatus: \(tradeStatus)")
        guard let tradeId = HLSwappViewController.sanitizedTradeId(tradeStatus.tradeId) else {
            return
        }
        let turn_id = tradeStatus.turn_user_id
        self.trade_id_closed = tradeId
        self.user_id_closed = HLSwappViewController.offerCounterpartyId(
            ownerId: tradeStatus.owner_id,
            otherId: tradeStatus.other_id,
            viewerId: HulaUser.sharedInstance.userId
        )
        
        //print(tradeStatus.owner_products)
        // `turn_user_id != userId` unwrapped both IUOs before `&& false`, so a nil
        // turn still crashed Accept. The gate stays off: not-your-turn does not block.
        if TradeTurnPolicy.shouldBlockOffer(
            turnUserId: turn_id,
            viewerId: HulaUser.sharedInstance.userId,
            buttonTag: buttonTag,
            productsReceivedTag: kTagProductsReceived,
            turnGateEnabled: false
        ) {
            print("This is not your turn!!!")
        } else {
            
            guard let queryURL = HLSwappViewController.offerReadyURL(apiBase: HulaConstants.apiURL, tradeId: tradeId) else {
                return
            }
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    
                    guard let queryURL2 = HLSwappViewController.offerUpdateURL(apiBase: HulaConstants.apiURL, tradeId: tradeId) else {
                        return
                    }
                    let submitted = HLSwappViewController.offerSubmittedFields(
                        buttonTag: buttonTag,
                        closeDealTag: self.kTagCloseDeal,
                        productsReceivedTag: self.kTagProductsReceived
                    )
                    let status = submitted.status
                    let acceptedTrade = submitted.accepted
                    let dataString = HLSwappViewController.offerPostString(
                        status: status,
                        ownerProducts: tradeStatus.owner_products,
                        otherProducts: tradeStatus.other_products,
                        ownerMoney: tradeStatus.owner_money,
                        otherMoney: tradeStatus.other_money,
                        accepted: acceptedTrade
                    )
                    //print(dataString)
                    
                    
                    self.sendDataToServer(queryURL: queryURL2, dataString: dataString, buttonTag:buttonTag);
                } else {
                    self.presentTradeUpdateFailureAlert()
                }
            }
            );
            
            
            /*
            */
        }
    }
    
    func sendDataToServer(queryURL:String, dataString:String, buttonTag:Int){
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self as AlertDelegate
                    viewController.isCancelVisible = false
                    
                    if buttonTag == self.kTagCloseDeal {
                        viewController.message = NSLocalizedString("You accepted the deal. Now meet the trader and exchange your stuff.", comment: "")
                        viewController.trigger = "deal_review"
                    } else {
                        if buttonTag == self.kTagProductsReceived {
                            viewController.message = NSLocalizedString("Great! Enjoy your stuff and many thanks for using HULA.\nIn order to free up this trading room, this trade will be moved to your past trades tab.", comment: "")
                            viewController.trigger = "deal_closed"
                        } else {
                            viewController.message = NSLocalizedString("Your offer has been sent with your changes.", comment: "")
                        }
                    }
                    self.present(viewController, animated: true)
                }
            } else {
                self.presentTradeUpdateFailureAlert()
            }
        })
    }

    func presentTradeUpdateFailureAlert() {
        DispatchQueue.main.async {
            self.showAlert(
                message: NSLocalizedString("Could not update the trade. Please try again.", comment: ""),
                trigger: "notrade",
                cancelVisible: false,
                okText: NSLocalizedString("OK", comment: "")
            )
        }
    }

    /// Close Deal / donation confirmations start an async `/ready`→PUT. Returning to lobby
    /// immediately abandons the room before success/failure UI can run.
    class func shouldReturnToLobbyAfterAlert(trigger: String, response: String) -> Bool {
        if trigger == "notrade" {
            return false
        }
        if trigger == "doit" || trigger == "donation" {
            return false
        }
        return true
    }

    @IBAction func showUserAction(_ sender: Any) {
        //print (prevUser)
        HLDataManager.sharedInstance.getUserProfile(userId: prevUser, taskCallback: {(user, prods, feedback) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sellerHorizontal") as! HLSellerHorizontalViewController
            
            viewController.user = user
            self.present(viewController, animated: true)
            self.backFromChat = true
        })
    }
    func manageCheckMarks(trade:HulaTrade?){
        
        if trade != nil {
            self.otherCheckMark.alpha = 0;
            self.myCheckMark.alpha = 0;
            self.threeDotsView.isHidden = false;
            self.sendOfferBtn.tag = kTagJustAccept
            self.sendOfferBtn.setTitle(NSLocalizedString("Accept", comment: ""), for: .normal);
            
            if TradeReadyPolicy.viewerIsReady(trade: trade, viewerId: HulaUser.sharedInstance.userId) {
                // I am ready
                self.myCheckMark.alpha = 1;
                self.sendOfferBtn.setTitle("", for: .normal);
            }
            if TradeReadyPolicy.peerIsReady(trade: trade, viewerId: HulaUser.sharedInstance.userId) {
                self.sendOfferBtn.tag = kTagCloseDeal
                self.otherCheckMark.alpha = 1;
                self.otherOfferBtn.setTitle("", for: .normal)
                self.threeDotsView.isHidden = true;
            }
        } else {
            self.otherCheckMark.alpha = 0;
            self.myCheckMark.alpha = 0;
        }
    }
    
    func controlSetupBottomBar(index:Int){
        //print("setting up bottom bar with index: \(index)")
        
        initialOtherUserX = self.view.frame.width - self.otherUserView.frame.width
        
        if (index != 0){
            // hide/show elements on the bottom bar
            UIView.animate(withDuration: 0.3) {
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = 0
                self.otherUserView.frame.origin.x = self.view.frame.width - self.otherUserView.frame.width
                self.sendOfferBtn.alpha = 1
                self.otherOfferBtn.alpha = 1
                self.addTradeRoomBtn.alpha = 0;
                self.mainCentralLabel.alpha = 0;
                self.currentTradesBtn.alpha = 0;
                self.pastTradesBtn.alpha = 0
                self.tradeModeLine.alpha = 0
                self.pastChatCountLbl.isHidden = true
            }
            self.threeDotsView.isHidden = true;
            
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                if let thisTrade = DashboardTradeSelection.resolvedTrade(
                    currentTrade: swappPageVC.currentTrade,
                    currentIndex: swappPageVC.currentIndex,
                    trades: swappPageVC.arrTrades
                ) {
                    last_index_setup = swappPageVC.currentIndex
                    let peer = HLSwappViewController.peerChatContext(
                        from: thisTrade,
                        viewerId: HulaUser.sharedInstance.userId
                    )
                    let other_user_id = peer.peerId
                    let chat_count = peer.unread


                    let currentStatus = thisTrade.object(forKey: "status") as? String ?? ""
                    if currentStatus == HulaConstants.cancel_status || currentStatus == HulaConstants.end_status {
                        // closed or removed trade!
                        
                        self.sendOfferBtn.alpha = 0
                        self.otherOfferBtn.alpha = 0
                        self.mainCentralLabel.alpha = 0
                        self.remainingTimeLabel.alpha = 0
                        self.threeDotsView.isHidden = true
                        
                    } else if currentStatus.count > 0 {
                        if currentStatus == HulaConstants.review_status {
                            // pending exchange
                            
                            self.mainCentralLabel.alpha = 0
                            self.remainingTimeLabel.alpha = 0
                            self.threeDotsView.isHidden = true
                            
                            self.sendOfferBtn.setTitle( NSLocalizedString("I received my stuff", comment: ""), for: .normal)
                            self.sendOfferBtn.tag = kTagProductsReceived
                            
                            self.otherOfferBtn.alpha = 0;
                        } else {
                            // still bartering
                            
                            if let current_user_turn = thisTrade.object(forKey: "turn_user_id") as? String {
                                
                                if current_user_turn != HulaUser.sharedInstance.userId && false {
                                    // added "false" in order to avoid this case
                                    
                                    // other user turn
                                    
                                    self.sendOfferBtn.alpha = 0
                                    self.otherOfferBtn.alpha = 0
                                    self.mainCentralLabel.alpha=1;
                                    self.mainCentralLabel.text = NSLocalizedString("Waiting for user reply", comment: "")
                                    if let str_hours = HLSwappViewController.remainingResponseHoursLabel(
                                        lastUpdate: thisTrade.object(forKey: "last_update")
                                    ) {
                                        self.remainingTimeLabel.alpha = 1
                                        self.remainingTimeLabel.text = NSLocalizedString("Remaining time for response:", comment: "") + " \(str_hours)"
                                    } else {
                                        self.remainingTimeLabel.alpha = 0
                                    }
                                    self.threeDotsView.isHidden = false;
                                    
                                } else {
                                    self.threeDotsView.isHidden = false;
                                    // my turn!
                                    self.remainingTimeLabel.alpha = 0;
                                    
                                    self.sendOfferBtn.setTitle( NSLocalizedString("Accept", comment: ""), for: .normal)
                                    //self.sendOfferBtn.tag = kTagJustAccept
                                    /*
                                    if self.tradeCanBeClosed(thisTrade) {
                                        // can be closed
                                        self.sendOfferBtn.setTitle( NSLocalizedString("Accept trade", comment: ""), for: .normal)
                                        self.sendOfferBtn.tag = kTagCloseDeal
                                        
                                    } else {
                                        // send counter offer
                                        self.sendOfferBtn.setTitle( NSLocalizedString("Accept trade", comment: ""), for: .normal)
                                        self.sendOfferBtn.tag = kTagJustAccept
                                    }
                                    */
                                }
                            }
                        }
                    }
                    
                    
                    
                    if let tr = self.barterDelegate?.getCurrentTradeStatus() {
                        //print("updating checkmarks...");
                        print("owner ready \(tr.owner_ready)");
                        print("other ready \(tr.other_ready)");
                        self.manageCheckMarks(trade: tr);
                        
                        if tr.other_agree {
                            self.otherUserView.alpha = 1
                            
                            if currentStatus != HulaConstants.cancel_status && currentStatus != HulaConstants.end_status {
                                // closed deals should not show the other's button
                                self.otherOfferBtn.alpha = 1
                            }
                        } else {
                            self.otherUserView.alpha = 0.5
                            self.otherOfferBtn.alpha = 0.5
                        }
                        
                    }
                    
                    if chat_count > 0 {
                        self.chatCountLbl.text = "\(chat_count)"
                        self.chatCountLbl.isHidden = false
                    } else {
                        self.chatCountLbl.isHidden = true
                    }
                    
                    if let alpha = TradeTurnPolicy.chatButtonAlpha(
                        bids: thisTrade.object(forKey: "bids"),
                        turnValue: thisTrade.object(forKey: "turn_user_id"),
                        viewerId: HulaUser.sharedInstance.userId
                    ) {
                        self.chatButton.alpha = alpha
                    }
                    
                    
                    if (prevUser != other_user_id) {
                        prevUser = other_user_id
                        otherUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: other_user_id))
                        
                        if let queryURL = HLSwappViewController.userNickURL(
                            apiBase: HulaConstants.apiURL,
                            userId: other_user_id
                        ) {
                            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (result, json) in
                                if let dict = json as? [String:String]{
                                    if let nick = dict["nick"] {
                                        DispatchQueue.main.async {
                                            if nick.count < 17 {
                                                self.otherUserNick.text = nick
                                            } else {
                                                self.otherUserNick.text = String( nick.prefix(15) ) + "...";
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                    
                    
                    
                } else {
                    // no trades
                    self.addTradeRoomBtn.alpha = 0
                    self.mainCentralLabel.alpha = 0
                    self.myUserView.frame.origin.x = 0
                    self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                    self.sendOfferBtn.alpha = 0
                    self.otherOfferBtn.alpha = 0
                    self.chatButton.alpha = 0
                    self.remainingTimeLabel.alpha = 0;
                    self.threeDotsView.isHidden = true
                    self.currentTradesBtn.alpha = 0;
                    self.pastTradesBtn.alpha = 0
                    self.tradeModeLine.alpha = 0
                    self.chatCountLbl.isHidden = true
                    self.pastChatCountLbl.isHidden = true
                    
                    self.manageCheckMarks(trade: nil);
                }
            }
            
            if self.sendOfferBtn.tag == kTagProductsReceived {
                self.otherOfferBtn.alpha = 0;
            }
            
        } else {
            // index == 0
            
            last_index_setup = 0
            UIView.animate(withDuration: 0.3) {
                /*
                self.extraRoomBtn.alpha = 1
                self.extraRoomImage.alpha = 1
                self.nextTradeBtn.alpha = 1
                 */
                if HulaUser.sharedInstance.maxTrades >= 50{
                    self.addTradeRoomBtn.alpha = 0.3
                } else {
                    self.addTradeRoomBtn.alpha = 1;
                }
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = -500
                self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                self.sendOfferBtn.alpha = 0
                self.otherOfferBtn.alpha = 0
                //self.mainCentralLabel.text = "Available Table Rooms"
                self.chatButton.alpha = 0
                self.remainingTimeLabel.alpha = 0;
                self.threeDotsView.isHidden = true
                self.currentTradesBtn.alpha = 1;
                self.pastTradesBtn.alpha = 1
                self.tradeModeLine.alpha = 1
                self.pastChatCountLbl.isHidden = true
            }
            self.chatCountLbl.isHidden = true
            
            var chat_count = 0
            var other_user_id = ""
            for oldTrade in HLDataManager.sharedInstance.arrPastTrades {
                let thisTrade: NSDictionary = oldTrade
                let peer = HLSwappViewController.peerChatContext(
                    from: thisTrade,
                    viewerId: HulaUser.sharedInstance.userId
                )
                other_user_id = peer.peerId
                chat_count = peer.unread
            }
            if chat_count > 0 {
                self.pastChatCountLbl.isHidden = false
                self.pastChatCountLbl.text = "\(chat_count)"
                print("chat_count")
                print(chat_count)
                print("other_user_id")
                print(other_user_id)
            } else {
                
                self.pastChatCountLbl.isHidden = true
            }
            
            self.manageCheckMarks(trade: nil);
        }
        
    }
    
    func tradeCanBeClosed(_ trade:NSDictionary) -> Bool{
        return TradeCloseEligibilityPolicy.canClose(
            trade: trade,
            isMutated: barterDelegate?.isTradeMutated()
        )
    }
    
    @IBAction func showCurrentTrades(_ sender: Any) {
        
        self.tradeMode = "current"
        UIView.animate(withDuration: 0.3) {
            self.tradeModeLine.frame.origin.x = self.currentTradesBtn.frame.origin.x
            self.tradeModeLine.frame.size.width = self.currentTradesBtn.frame.size.width
        }
        updateTradesList()
    }
    @IBAction func showPastTrades(_ sender: Any) {
        self.tradeMode = "past"
        UIView.animate(withDuration: 0.3) {
            self.tradeModeLine.frame.origin.x = self.pastTradesBtn.frame.origin.x
            self.tradeModeLine.frame.size.width = self.pastTradesBtn.frame.size.width
        }
        updateTradesList()
    }
    
    func updateTradesList(){
        HLDataManager.sharedInstance.tradeMode = self.tradeMode
        for vc in HLSwappViewController.nestedChildViewControllers(from: self) {
            if let db = vc as? HLDashboardViewController{
                db.refreshCollectionViewData()
            }
        }
    }
    @IBAction func addTradeRoomAction(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        
        viewController.delegate = self as AlertDelegate
        viewController.isCancelVisible = true
        viewController.message = NSLocalizedString("Do you need more rooms? Spread the word! Share HULA with your friends and get up to 5 trade rooms.", comment: "")
        viewController.okButtonText = NSLocalizedString("Share Hula", comment: "")
        viewController.trigger = "share"
        self.present(viewController, animated: true)

        
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
        if (index == 0){
            barterDelegate?.reloadTrade()
        }
        controlSetupBottomBar(index: index)
    }
    
    
}

protocol HLBarterScreenDelegate: class {
    func getCurrentTradeStatus() -> HulaTrade
    func isTradeMutated() -> Bool!
    func reloadTrade()
}

extension HLSwappViewController: AlertDelegate{
    func alertResponded(response: String, trigger:String) {
        print("Response: \(response)")
        
        
        DispatchQueue.main.async {
            if trigger == "donation"{
                if response == "ok"{
                    if let tradeStatus = self.barterDelegate?.getCurrentTradeStatus() {
                        self.executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                    }
                }
            }
            if trigger == "doit"{
                if response == "ok"{
                    if let tradeStatus = self.barterDelegate?.getCurrentTradeStatus() {
                        self.executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                    }
                }
            }
            if trigger == "share" && response == "ok"{
                self.shareHula()
            }
            if trigger == "deal_closed" && response == "ok"{
                self.feedback()
            }
            if trigger == "feedback_sent"{
                self.feedback_sent(response:response)
            }
            
            if HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: trigger, response: response) {
                if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                    swappPageVC.goTo(page: 0)
                }
            }
            
            
        }
    }
    
    func shareHula(){
        /*
        // Facebook app invite no longer supported
        let alert = UIAlertController(title: NSLocalizedString("Sharing", comment: ""), message: NSLocalizedString("Please choose a sharing method", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Facebook", style: UIAlertActionStyle.default){
            UIAlertAction in
            self.shareHulaFB()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Other", comment: ""), style: UIAlertActionStyle.default){
            UIAlertAction in
            self.shareHulaStandard()
        })
        self.present(alert, animated: true, completion: nil)
         */
        self.shareHulaStandard()
    }
    
    func shareHulaFB(){
        guard let urls = HLSwappViewController.facebookAppInviteURLs() else {
            return
        }
        let appInvite = AppInvite(appLink: urls.appLink,
                                  deliveryMethod: .facebook,
                                  previewImageURL: urls.previewImageURL)
        do {
            try AppInvite.Dialog.show(from: self, invite: appInvite) { result in
                switch result {
                case .success(let result):
                    print("App Invite Sent with result \(result)")
                    self.addExtraRoom()
                case .failed(let error):
                    print("Failed to send app invite with error \(error)")
                }
            }
        } catch let error {
            print("Failed to show app invite dialog with error \(error)")
        }
    }
    func shareHulaStandard(){
        let text = NSLocalizedString("Hey, I trade on HULA! I get what I want and give what I don't. https://hula.trading", comment: "")
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.5) {
            self.addExtraRoom()
        }

        
    }
    
    func addExtraRoom(){
        if HLSwappViewController.shouldGrantExtraTradeRoom(maxTrades: HulaUser.sharedInstance.maxTrades) {
            HulaUser.sharedInstance.maxTrades += 1
            HulaUser.sharedInstance.updateServerData()
            HLDataManager.sharedInstance.writeUserData()
        }
    }
    
    func feedback(){
        //print("Deal closed. Requesting feedback")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "finalFeedback") as! HLFinalFeedbackViewController
        
        //viewController.delegate = self as AlertDelegate
        //viewController.isCancelVisible = true
        //viewController.message = "We would love to hear how your trade was. Please rate it from one to five stars:"
        //viewController.okButtonText = "Send"
        //viewController.starsVisible = true
        //viewController.trigger = "feedback_sent"
        viewController.trade_id_closed = self.trade_id_closed
        viewController.user_id_closed = self.user_id_closed
        self.present(viewController, animated: true)
        
    }
    
    func feedback_sent(response:String){
        print("Feedback received. \(response)")

        // "ok" / "cancel" acknowledge the alert. They must not POST another row.
        guard FeedbackSubmitPolicy.shouldPost(response: response) else {
            return
        }
        guard CommonUtils.nonEmptyTrimmed(self.trade_id_closed) != nil else {
            return
        }
        guard let queryURL = HLSwappViewController.feedbackURL(apiBase: HulaConstants.apiURL) else {
            return
        }
        let comments = NSLocalizedString("Deal closed. Thank you", comment: "")
        let dataString = CommonUtils.feedbackPostString(
            tradeId: self.trade_id_closed,
            userId: self.user_id_closed,
            comments: comments,
            val: response
        )
        //print(dataString)
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
            if let text = FeedbackSubmitPolicy.successLogText(ok: ok, json: json) {
                print(text)
                DispatchQueue.main.async {
                }
            }
        })
    }
}

/// Trade-room alert feedback posts only when the response is neither the ack
/// "ok" nor "cancel". The compare is exact: do not trim or case-fold.
/// The success callback used `print(json!)`, which trapped on `(true, nil)`.
struct FeedbackSubmitPolicy {
    static func shouldPost(response: String) -> Bool {
        return response != "ok" && response != "cancel"
    }

    static func successLogText(ok: Bool, json: Any?) -> String? {
        guard ok, let json = json else {
            return nil
        }
        return String(describing: json)
    }
}

/// Close Deal after multiple bids required `bids as? NSArray` plus a non-nil
/// `isTradeMutated()` answer. Missing bids, a Swift-array payload, or a nil
/// mutation flag must keep Close Deal off instead of offering a bad path.
struct TradeCloseEligibilityPolicy {
    static func bidCount(from trade: NSDictionary?) -> Int {
        guard let trade = trade else {
            return 0
        }
        if let bids = trade.object(forKey: "bids") as? NSArray {
            return bids.count
        }
        if let bids = trade.object(forKey: "bids") as? [Any] {
            return bids.count
        }
        return 0
    }

    static func canClose(bidCount: Int, isMutated: Bool?) -> Bool {
        guard let isMutated = isMutated else {
            return false
        }
        return bidCount > 1 && !isMutated
    }

    static func canClose(trade: NSDictionary?, isMutated: Bool?) -> Bool {
        return canClose(bidCount: bidCount(from: trade), isMutated: isMutated)
    }
}

/// Trade-room Accept / Close Deal used `trade!` after `if trade != nil`.
/// A missing snapshot, or a nil viewer id, must not unwrap. Owner-ready when
/// the viewer is owner (and other-ready when the viewer is the peer) still
/// means "I accepted"; the inverse still means the peer accepted.
struct TradeReadyPolicy {
    static func viewerIsReady(
        ownerId: String?,
        otherId: String?,
        ownerReady: Bool,
        otherReady: Bool,
        viewerId: String?
    ) -> Bool {
        guard let viewerId = viewerId else {
            return false
        }
        return (ownerReady && ownerId == viewerId) || (otherReady && otherId == viewerId)
    }

    static func peerIsReady(
        ownerId: String?,
        otherId: String?,
        ownerReady: Bool,
        otherReady: Bool,
        viewerId: String?
    ) -> Bool {
        guard let viewerId = viewerId else {
            return false
        }
        return (otherReady && ownerId == viewerId) || (ownerReady && otherId == viewerId)
    }

    static func viewerIsReady(trade: HulaTrade?, viewerId: String?) -> Bool {
        guard let trade = trade else {
            return false
        }
        return viewerIsReady(
            ownerId: trade.owner_id,
            otherId: trade.other_id,
            ownerReady: trade.owner_ready,
            otherReady: trade.other_ready,
            viewerId: viewerId
        )
    }

    static func peerIsReady(trade: HulaTrade?, viewerId: String?) -> Bool {
        guard let trade = trade else {
            return false
        }
        return peerIsReady(
            ownerId: trade.owner_id,
            otherId: trade.other_id,
            ownerReady: trade.owner_ready,
            otherReady: trade.other_ready,
            viewerId: viewerId
        )
    }
}

/// Send-offer used `owner_id == userId` on IUO strings and then chose
/// `offer_sent` vs `review` from the button tag. A nil id crashed before the
/// PUT. Empty trays, cash-only sides, Close Deal, and Products Received must
/// keep their historical route and status.
struct OfferSubmissionPolicy {
    static let needsDonationCheck = "needs_donation_check"
    static let confirmClose = "confirm_close"
    static let proceed = "proceed"
    static let blockNoItems = "block_no_items"
    static let blockViewerEmpty = "block_viewer_empty"
    static let confirmGiveaway = "confirm_giveaway"

    /// Nil ids are not the owner. Empty strings still match, matching other
    /// trade identity checks.
    static func viewerIsOwner(ownerId: String?, viewerId: String?) -> Bool {
        guard let viewerId = viewerId, let ownerId = ownerId else {
            return false
        }
        return ownerId == viewerId
    }

    static func sendOfferRoute(
        ownerProductCount: Int,
        otherProductCount: Int,
        buttonTag: Int,
        closeDealTag: Int
    ) -> String {
        if ownerProductCount == 0 || otherProductCount == 0 {
            return needsDonationCheck
        }
        if buttonTag == closeDealTag {
            return confirmClose
        }
        return proceed
    }

    static func donationDecision(
        ownerProductCount: Int,
        otherProductCount: Int,
        ownerMoney: Float,
        otherMoney: Float,
        ownerId: String?,
        viewerId: String?
    ) -> String {
        if ownerProductCount == 0 && otherProductCount == 0 {
            return blockNoItems
        }
        if viewerIsOwner(ownerId: ownerId, viewerId: viewerId) {
            if ownerProductCount == 0 && ownerMoney == 0 {
                return blockViewerEmpty
            }
            if otherProductCount == 0 && otherMoney == 0 {
                return confirmGiveaway
            }
            return proceed
        }
        if otherProductCount == 0 && otherMoney == 0 {
            return blockViewerEmpty
        }
        if ownerProductCount == 0 && ownerMoney == 0 {
            return confirmGiveaway
        }
        return proceed
    }

    /// Accept stays `offer_sent`. Close Deal becomes `review` without the
    /// accepted flag. Products Received is `review` and accepted.
    static func submittedFields(
        buttonTag: Int,
        closeDealTag: Int,
        productsReceivedTag: Int
    ) -> (status: String, accepted: Bool) {
        var status = HulaConstants.sent_status
        var accepted = false
        if buttonTag == closeDealTag || buttonTag == productsReceivedTag {
            status = HulaConstants.review_status
        }
        if buttonTag == productsReceivedTag {
            accepted = true
        }
        return (status, accepted)
    }

    static func counterpartyId(ownerId: String?, otherId: String?, viewerId: String?) -> String {
        if viewerIsOwner(ownerId: ownerId, viewerId: viewerId) {
            return otherId ?? ""
        }
        return ownerId ?? ""
    }
}

/// Turn checks compared IUO `turn_user_id` / `userId` with `!=` and `==`.
/// A nil id crashed Accept (the `&& false` gate is evaluated after that compare),
/// the barter room's empty turn branch, and the first-bid chat dim.
/// Nil does not match anyone, including another nil. Empty strings still match.
/// The Accept gate stays disabled until product turns it on.
struct TradeTurnPolicy {
    static let badgeMyTurn = "my_turn"
    static let badgeOtherTurn = "other_turn"
    static let badgeInReview = "in_review"
    static let chatDimmedAlpha: CGFloat = 0.3
    static let chatFullAlpha: CGFloat = 1

    static func idsMatch(_ lhs: String?, _ rhs: String?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else {
            return false
        }
        return lhs == rhs
    }

    static func isViewersTurn(turnUserId: String?, viewerId: String?) -> Bool {
        return idsMatch(turnUserId, viewerId)
    }

    /// Historical `executeOfferOptions` never blocks (`turnGateEnabled == false`).
    /// Products Received stays exempt if the gate is enabled. Any other tag,
    /// including Close Deal, blocks only when the turn id is not the viewer.
    static func shouldBlockOffer(
        turnUserId: String?,
        viewerId: String?,
        buttonTag: Int,
        productsReceivedTag: Int,
        turnGateEnabled: Bool
    ) -> Bool {
        if !turnGateEnabled || buttonTag == productsReceivedTag {
            return false
        }
        return !isViewersTurn(turnUserId: turnUserId, viewerId: viewerId)
    }

    /// Dashboard current-room chrome. End/cancel rooms pass list status "past"
    /// and must not change the arrows. A missing or non-string turn is my turn,
    /// including review trades that never stored `turn_user_id`. Review with a
    /// string turn hides both arrows and shows the closed label.
    static func lobbyBadge(
        listStatus: String?,
        tradeStatus: String?,
        turnValue: Any?,
        viewerId: String?
    ) -> String? {
        guard listStatus == "current" else {
            return nil
        }
        guard let turnUserId = turnValue as? String else {
            return badgeMyTurn
        }
        if tradeStatus == HulaConstants.review_status {
            return badgeInReview
        }
        if isViewersTurn(turnUserId: turnUserId, viewerId: viewerId) {
            return badgeMyTurn
        }
        return badgeOtherTurn
    }

    /// First bid on the viewer's turn dims chat to 0.3. Any other countable
    /// bid list is full alpha. A missing or non-array `bids` value leaves the
    /// button alone (nil).
    static func chatButtonAlpha(bids: Any?, turnValue: Any?, viewerId: String?) -> CGFloat? {
        guard let bids = bids as? [Any] else {
            return nil
        }
        if bids.count == 1 && isViewersTurn(turnUserId: turnValue as? String, viewerId: viewerId) {
            return chatDimmedAlpha
        }
        return chatFullAlpha
    }
}
