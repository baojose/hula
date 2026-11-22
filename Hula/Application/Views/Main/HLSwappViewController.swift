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

    /// Counterparty label on the trade room. A nick shorter than 17 characters
    /// is shown unchanged. A longer nick keeps the first 15 characters and
    /// "...". Nil stays nil so a missing `nick` does not clear the label.
    /// Do not trim. Do not percent-encode. Do not use `displayNick` (that
    /// trims `" bike "` to `bike` and drops whitespace-only nicks).
    class func otherUserNickLabel(_ nick: String?) -> String? {
        guard let nick = nick else {
            return nil
        }
        if nick.characters.count < 17 {
            return nick
        }
        let end = nick.index(nick.startIndex, offsetBy: 15)
        return nick.substring(to: end) + "..."
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
        
        
        // Rebuild only when this appear is not a return from chat or a
        // presented seller sheet. The flag is read first and cleared after.
        let appear = HLSwappViewController.tradeRoomAppearChrome(
            backFromChat: self.backFromChat,
            lastIndexSetup: last_index_setup
        )
        if appear.shouldSetupBottomBar {
            controlSetupBottomBar(index: appear.setupIndex)
        }
        self.backFromChat = appear.backFromChat
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
                if let returning = HLSwappViewController.chatSegueBackFromChat(resolvedTrade: thisTrade) {
                    self.backFromChat = returning
                }
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

    /// `backFromChat` for the chat segue. Nil means there is no resolved
    /// trade, so the segue returns before the assignment and the flag stays
    /// as it was. A resolved trade assigns true even when `chat` is missing,
    /// null, or not an array. Do not trim `_id`. Do not fold this into
    /// `tradeRoomAppearChrome` or `sellerSheetFromStoredPeer`. The
    /// current-chat badge hide stays at the call site.
    class func chatSegueBackFromChat(resolvedTrade: NSDictionary?) -> Bool? {
        if resolvedTrade == nil {
            return nil
        }
        return true
    }

    /// Bottom-bar rebuild on `viewDidAppear`. `controlSetupBottomBar` runs
    /// only when `backFromChat` is false. The flag is cleared after that
    /// check, never before. `setupIndex` is the stored `last_index_setup`,
    /// including `0` and a negative index. Do not clamp it. A seller sheet
    /// sets the incoming flag only when `presentsSellerSheet` is true, so a
    /// stored `""`, `" "`, or `"\n"` leaves it false and this appear still
    /// rebuilds. A presented sheet for `" bike "` skips the rebuild once.
    /// The chat segue sets the flag on its own. Do not fold this into
    /// `sellerSheetFromStoredPeer`. Do not change `manageCheckMarks`.
    class func tradeRoomAppearChrome(
        backFromChat: Bool,
        lastIndexSetup: Int
    ) -> TradeRoomAppearChrome {
        return TradeRoomAppearChrome(
            backFromChatBefore: backFromChat,
            shouldSetupBottomBar: !backFromChat,
            setupIndex: lastIndexSetup,
            backFromChat: false
        )
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

    /// Bottom-bar offer chrome, chosen after `peerChatContext`. A missing,
    /// `NSNull`, numeric, or bool `status` becomes `""` (`as? String ?? ""`).
    /// Exact `"closed"` (`cancel_status`) or `"ended"` (`end_status`) hides
    /// send, the other offer, the central label, and remaining time, and hides
    /// the three dots. Exact `"review"` sets the send title to "I received my
    /// stuff", the products-received tag, hides the central label, remaining
    /// time, and three dots, and sets the other offer alpha to 0. Send itself
    /// stays visible so the receipt button is not cleared. Any other string
    /// with `characters.count > 0` stays bartering. A string `turn_user_id`
    /// with `waitingTurnEnabled: false` shows Accept, shows the three dots,
    /// and sets remaining alpha to 0. The gate is off, so the ids are not
    /// compared and a nil viewer still shows Accept. A non-string turn does
    /// not enter that branch. `""` has count 0 and changes nothing here.
    /// `" "`, `"\n"`, `" closed "`, `"Closed"`, `"Review"`, `" review"`,
    /// `"preview"`, `"a&b"`, `"P1"`, and one emoji are not cancel and not
    /// review. Do not trim. Do not case-fold. Do not percent-encode. Do not
    /// change `?? ""` into a nil return. Do not fold `otherAgreeOverlay`
    /// into this helper (agreement can set the other offer alpha back to 1
    /// unless status is exact `"closed"` or `"ended"`, and a false flag
    /// sets both alphas to 0.5). Do not fold
    /// `productsReceivedOtherOfferAlpha` into this helper. That step runs
    /// later, outside the trade lookup, and hides the other offer only when
    /// the send tag is still exactly the products-received tag. Do not
    /// enable `waitingTurnEnabled`. Do not fold this into
    /// `lobbyTapDestination` (review there opens past trade; here it changes
    /// the offer button).
    /// Do not assign the Accept tag. The bartering branch only changes the title.
    class func bottomBarOfferChrome(
        status: Any?,
        turnUserId: Any?,
        viewerId: String?,
        waitingTurnEnabled: Bool,
        productsReceivedTag: Int
    ) -> BottomBarOfferChrome {
        let statusText = status as? String ?? ""
        if statusText == HulaConstants.cancel_status || statusText == HulaConstants.end_status {
            return BottomBarOfferChrome(
                status: statusText,
                hidesSend: true,
                otherOfferAlpha: 0,
                centralLabelAlpha: 0,
                remainingAlpha: 0,
                hidesThreeDots: true,
                sendTitle: nil,
                sendTag: nil,
                showsAccept: false,
                showsWaiting: false
            )
        }
        if statusText.characters.count > 0 {
            if statusText == HulaConstants.review_status {
                return BottomBarOfferChrome(
                    status: statusText,
                    hidesSend: false,
                    otherOfferAlpha: 0,
                    centralLabelAlpha: 0,
                    remainingAlpha: 0,
                    hidesThreeDots: true,
                    sendTitle: NSLocalizedString("I received my stuff", comment: ""),
                    sendTag: productsReceivedTag,
                    showsAccept: false,
                    showsWaiting: false
                )
            }
            if let turn = turnUserId as? String {
                if TradeTurnPolicy.showsWaitingForReply(
                    turnUserId: turn,
                    viewerId: viewerId,
                    waitingTurnEnabled: waitingTurnEnabled
                ) {
                    return BottomBarOfferChrome(
                        status: statusText,
                        hidesSend: true,
                        otherOfferAlpha: 0,
                        centralLabelAlpha: 1,
                        remainingAlpha: nil,
                        hidesThreeDots: false,
                        sendTitle: nil,
                        sendTag: nil,
                        showsAccept: false,
                        showsWaiting: true
                    )
                }
                return BottomBarOfferChrome(
                    status: statusText,
                    hidesSend: false,
                    otherOfferAlpha: nil,
                    centralLabelAlpha: nil,
                    remainingAlpha: 0,
                    hidesThreeDots: false,
                    sendTitle: NSLocalizedString("Accept", comment: ""),
                    sendTag: nil,
                    showsAccept: true,
                    showsWaiting: false
                )
            }
        }
        return BottomBarOfferChrome(
            status: statusText,
            hidesSend: false,
            otherOfferAlpha: nil,
            centralLabelAlpha: nil,
            remainingAlpha: nil,
            hidesThreeDots: nil,
            sendTitle: nil,
            sendTag: nil,
            showsAccept: false,
            showsWaiting: false
        )
    }

    /// Counterparty agreement overlay, applied after `bottomBarOfferChrome`
    /// and `manageCheckMarks`. `status` is that helper's already-cast string
    /// (`as? String ?? ""`). `otherAgree` true sets the other user view to 1
    /// and restores the other offer button unless the status is exact
    /// `"closed"` or `"ended"`. Those two statuses leave `otherOfferAlpha`
    /// nil, so the chrome value stays and the other button stays hidden.
    /// `otherAgree` false sets both alphas to 0.5, including canceled, ended,
    /// and review, which overwrites the status helper's 0. Do not trim. Do
    /// not case-fold. Do not percent-encode. Do not fold this into
    /// `bottomBarOfferChrome`. Do not read the send-button tag.
    /// `productsReceivedOtherOfferAlpha` still runs later, outside the trade
    /// lookup, and is not part of this step. Do not change `manageCheckMarks`.
    class func otherAgreeOverlay(otherAgree: Bool, status: String) -> OtherAgreeOverlay {
        if otherAgree {
            if status != HulaConstants.cancel_status && status != HulaConstants.end_status {
                return OtherAgreeOverlay(otherUserAlpha: 1, otherOfferAlpha: 1)
            }
            return OtherAgreeOverlay(otherUserAlpha: 1, otherOfferAlpha: nil)
        }
        return OtherAgreeOverlay(otherUserAlpha: 0.5, otherOfferAlpha: 0.5)
    }

    /// Final other-offer hide on a trade-room page (`index != 0`), after
    /// `bottomBarOfferChrome`, `manageCheckMarks`, and `otherAgreeOverlay`.
    /// It sits outside the trade lookup, so it still runs with no page
    /// controller, no trade, and no barter status. Returns 0 only when
    /// `sendTag` is still exactly `productsReceivedTag` (the call site passes
    /// `kTagProductsReceived`, 90441). Any other tag, including
    /// `kTagJustAccept` (1) and `kTagCloseDeal` (91053), returns nil and does
    /// not assign the button. `manageCheckMarks` replaces 90441 with one of
    /// those two tags when a barter trade exists, and
    /// `agreedTradeAfterResolved` stores that same replacement before this
    /// hide, so the hide does not fire on that path. A leftover 90441 from an
    /// earlier review page still hides, because Accept chrome does not clear
    /// the tag. Do not trim. Do
    /// not case-fold a status into this compare. Do not percent-encode. Do
    /// not fold this into `otherAgreeOverlay` or `bottomBarOfferChrome`. Do
    /// not change `manageCheckMarks`. Do not treat tag 1 or 91053 as the
    /// receipt title. The lobby page (`index == 0`) does not call this.
    class func productsReceivedOtherOfferAlpha(
        sendTag: Int,
        productsReceivedTag: Int
    ) -> CGFloat? {
        if sendTag == productsReceivedTag {
            return CGFloat(0)
        }
        return nil
    }

    /// Lobby page (`index == 0`) of `controlSetupBottomBar`. The add-room
    /// button is `0.3` when `maxTrades >= 50` and `1` otherwise. That is the
    /// inverse of `shouldGrantExtraTradeRoom` (`maxTrades < 50`). Exactly 50
    /// is `0.3`. Do not change `0.3` into `0`. The past-chat loop keeps only
    /// the last `arrPastTrades` row: `peerChatContext` replaces both the peer
    /// id and the unread count, including `0`, so an earlier unread is
    /// discarded and is not summed. An empty list stays at count `0`, peer
    /// `""`, and hidden. A last unread that is not greater than `0` hides the
    /// badge. `pastChatPeerId` is printed only when the badge shows. Do not
    /// start an image load. Do not trim. Do not case-fold. Do not
    /// percent-encode. Status strings do not enter this helper. `"a&b"` is
    /// not `a%26b`. `"P1"` is not `"p1"`. `" bike "` is not `bike`. Do not
    /// call `productsReceivedOtherOfferAlpha` (that hide is the `index != 0`
    /// branch). Do not assign the send tag. Do not change
    /// `manageCheckMarks`. Do not fold this into `lobbyTapDestination`,
    /// `lobbyListBucket`, `headline`, `bottomBarOfferChrome`, or
    /// `otherAgreeOverlay`. Do not enable `waitingTurnEnabled`.
    class func lobbyPageChrome(
        maxTrades: Int,
        pastTrades: [NSDictionary],
        viewerId: String
    ) -> LobbyPageChrome {
        let addAlpha: CGFloat
        if maxTrades >= 50 {
            addAlpha = 0.3
        } else {
            addAlpha = 1
        }
        var chatCount = 0
        var peerId = ""
        for oldTrade in pastTrades {
            let peer = peerChatContext(from: oldTrade, viewerId: viewerId)
            peerId = peer.peerId
            chatCount = peer.unread
        }
        return LobbyPageChrome(
            addTradeRoomAlpha: addAlpha,
            showsPastChatBadge: chatCount > 0,
            pastChatCount: chatCount,
            pastChatPeerId: peerId,
            hidesCurrentChatBadge: true,
            sendAlpha: 0,
            otherOfferAlpha: 0,
            centralLabelAlpha: 0,
            chatButtonAlpha: 0,
            remainingAlpha: 0,
            hidesThreeDots: true,
            currentTradesAlpha: 1,
            pastTradesAlpha: 1,
            tradeModeLineAlpha: 1
        )
    }

    /// Empty trade room on a trade-room page (`index != 0` and
    /// `resolvedTrade` is nil). The opening animation on that page already
    /// set the other offer to `1`, the send button to `1`, the add-room
    /// button to `0`, the viewer at x `0`, and the counterparty at
    /// `initialOtherUserX`. This step overwrites send and the other offer to
    /// `0` and parks the counterparty at `initialOtherUserX + 500`. The
    /// add-room button stays `0`. It is not the lobby `1` and not the lobby
    /// cap `0.3`. The viewer stays at x `0`. The lobby page moves that view
    /// to `-500`. Current trades, past trades, and the mode line are `0`.
    /// The lobby page sets those to `1`. Both chat badges stay hidden. This
    /// step does not read a status, a turn, a peer id, `maxTrades`, or
    /// `arrPastTrades`. Do not trim. Do not case-fold. Do not
    /// percent-encode. `"a&b"` is not `a%26b`. `"P1"` is not `"p1"`.
    /// `" bike "` is not `bike`. Do not fold this into `lobbyPageChrome`,
    /// `bottomBarOfferChrome`, `otherAgreeOverlay`, or
    /// `productsReceivedOtherOfferAlpha`. The receipt-tag hide still runs
    /// after this block and can only force the other offer to `0` again when
    /// the send tag is still `90441`. It does not restore the opening alpha
    /// of `1`. `manageCheckMarks(nil)` still runs after these assignments
    /// and does not set the send tag. Do not change `manageCheckMarks`. Do
    /// not enable `waitingTurnEnabled`.
    class func emptyTradeRoomChrome(initialOtherUserX: CGFloat) -> EmptyTradeRoomChrome {
        return EmptyTradeRoomChrome(
            addTradeRoomAlpha: 0,
            centralLabelAlpha: 0,
            myUserOriginX: 0,
            otherUserOriginX: initialOtherUserX + 500,
            sendAlpha: 0,
            otherOfferAlpha: 0,
            chatButtonAlpha: 0,
            remainingAlpha: 0,
            hidesThreeDots: true,
            currentTradesAlpha: 0,
            pastTradesAlpha: 0,
            tradeModeLineAlpha: 0,
            hidesCurrentChatBadge: true,
            hidesPastChatBadge: true
        )
    }

    /// Opening animation on a trade-room page (`index != 0`), before the
    /// page-controller lookup. `initialOtherUserX` is
    /// `viewWidth - otherUserWidth`, and that same value is what the
    /// animation writes as the counterparty x. It is not
    /// `initialOtherUserX + 500`. A result of `0` is kept, including equal
    /// widths and a negative width that lands on the viewer. Do not
    /// special-case it. Do not take the absolute value. Send and the other
    /// offer are `1`. The add-room button is `0`, not the lobby `1` and not
    /// the lobby cap `0.3`. The viewer x is `0`, not the lobby `-500`.
    /// Current trades, past trades, and the mode line are `0`. The past-chat
    /// badge is hidden. The three dots are hidden outside the animation.
    /// The current-chat badge, the chat button, the remaining-time label,
    /// and the send tag are not assigned. When `childViewControllers.first`
    /// is not an `HLSwappPageViewController`, `emptyTradeRoomChrome` does
    /// not run, so send stays `1` and the other offer stays `1` unless the
    /// send tag is still `90441`, which forces the other offer to `0`. A
    /// nil receipt hide does not change the opening `1`. That is the inverse
    /// of the empty room, where the other offer is already `0` and a nil
    /// hide cannot restore `1`. Do not fold this into
    /// `emptyTradeRoomChrome`. Do not change the empty helper's `0` alphas
    /// into these `1`s. Do not read `arrPastTrades`. Do not trim. Do not
    /// case-fold. Do not percent-encode. `"a&b"` is not `a%26b`. `"P1"` is
    /// not `"p1"`. `" bike "` is not `bike`. Status strings do not enter
    /// this helper. Do not change `manageCheckMarks`. Do not enable
    /// `waitingTurnEnabled`.
    class func tradeRoomOpeningChrome(
        viewWidth: CGFloat,
        otherUserWidth: CGFloat
    ) -> TradeRoomOpeningChrome {
        let counterpartyX = viewWidth - otherUserWidth
        return TradeRoomOpeningChrome(
            centralLabelAlpha: 0,
            myUserOriginX: 0,
            otherUserOriginX: counterpartyX,
            initialOtherUserX: counterpartyX,
            sendAlpha: 1,
            otherOfferAlpha: 1,
            addTradeRoomAlpha: 0,
            currentTradesAlpha: 0,
            pastTradesAlpha: 0,
            tradeModeLineAlpha: 0,
            hidesPastChatBadge: true,
            hidesThreeDots: true,
            chatButtonAlpha: nil,
            remainingAlpha: nil,
            hidesCurrentChatBadge: nil,
            sendTag: nil
        )
    }

    /// Resolved trade after the opening animation (`index != 0` and
    /// `resolvedTrade` is non-nil). Starts from `tradeRoomOpeningChrome` and
    /// applies `bottomBarOfferChrome` only where that helper assigns a field.
    /// `hidesSend` sets send to `0`. Otherwise send stays at the opening `1`.
    /// A nil other-offer alpha leaves the opening `1`. A nil central alpha
    /// leaves the opening `0`. A nil dots flag leaves the opening hide. A nil
    /// `sendTag` does not clear a leftover products-received tag, so
    /// `productsReceivedOtherOfferAlpha` can still force the other offer to
    /// `0` later. A string turn with `waitingTurnEnabled: false` on a
    /// non-review, non-cancel status shows the three dots again, sets
    /// remaining to `0`, and sets the Accept title. A non-string turn, or a
    /// status that casts to `""`, assigns none of those and the opening hide
    /// stays. Review assigns the other offer `0` and tag `90441`. Closed and
    /// ended hide send, so the opening `1` becomes `0`. Do not fold this into
    /// `tradeRoomOpeningChrome` or `emptyTradeRoomChrome`. Do not call
    /// `manageCheckMarks`. Do not fold `otherAgreeOverlay`,
    /// `agreedTradeAfterResolved`, or `productsReceivedOtherOfferAlpha` into
    /// this helper. Do not enable `waitingTurnEnabled` at the call site. Do
    /// not trim. Do not case-fold. Do not percent-encode. `"a&b"` is not
    /// `a%26b`. `"P1"` is not `"p1"`. `" bike "` is not `bike`. Frames, the
    /// add-room alpha, and the chat button stay on the opening shell.
    class func resolvedTradeAfterOpening(
        opening: TradeRoomOpeningChrome,
        status: Any?,
        turnUserId: Any?,
        viewerId: String?,
        waitingTurnEnabled: Bool,
        productsReceivedTag: Int
    ) -> ResolvedTradeAfterOpening {
        let offer = HLSwappViewController.bottomBarOfferChrome(
            status: status,
            turnUserId: turnUserId,
            viewerId: viewerId,
            waitingTurnEnabled: waitingTurnEnabled,
            productsReceivedTag: productsReceivedTag
        )
        let sendAlpha: CGFloat
        if offer.hidesSend {
            sendAlpha = 0
        } else {
            sendAlpha = opening.sendAlpha
        }
        let otherOfferAlpha: CGFloat
        if let assigned = offer.otherOfferAlpha {
            otherOfferAlpha = assigned
        } else {
            otherOfferAlpha = opening.otherOfferAlpha
        }
        let centralLabelAlpha: CGFloat
        if let assigned = offer.centralLabelAlpha {
            centralLabelAlpha = assigned
        } else {
            centralLabelAlpha = opening.centralLabelAlpha
        }
        let hidesThreeDots: Bool
        if let assigned = offer.hidesThreeDots {
            hidesThreeDots = assigned
        } else {
            hidesThreeDots = opening.hidesThreeDots
        }
        return ResolvedTradeAfterOpening(
            opening: opening,
            offer: offer,
            sendAlpha: sendAlpha,
            otherOfferAlpha: otherOfferAlpha,
            centralLabelAlpha: centralLabelAlpha,
            hidesThreeDots: hidesThreeDots
        )
    }

    /// Agreement after `resolvedTradeAfterOpening`, and only when
    /// `getCurrentTradeStatus()` returned a trade. `manageCheckMarks` runs
    /// first and replaces the send tag with `justAcceptTag` (`1`), then with
    /// `closeDealTag` (`91053`) when `peerReady` is true. That replacement is
    /// stored here before `productsReceivedOtherOfferAlpha`, so a review tag
    /// of `90441` does not survive and the receipt hide does not fire unless
    /// the tag this step stores is still exactly `productsReceivedTag`.
    /// Agreement then sets the other user to `1` and the other offer to `1`
    /// unless status is exact `"closed"` or `"ended"`, where the agreement
    /// alpha stays nil and the resolved `0` survives. `otherAgree` false sets
    /// both alphas to `0.5`, overwriting the opening `1`, the review `0`, and
    /// the closed `0`. The receipt hide runs after that overwrite and forces
    /// the other offer to `0` only for a matching tag. Do not fold this into
    /// `resolvedTradeAfterOpening`. Do not change `manageCheckMarks`. Do not
    /// change the three-dots flag, the send alpha, or the chat button. Do not
    /// enable `waitingTurnEnabled`. Do not trim. Do not case-fold. Do not
    /// percent-encode. Do not read `arrPastTrades`. `"a&b"` is not `a%26b`.
    /// `"P1"` is not `"p1"`. `" bike "` is not `bike`. Chat badge and
    /// `chatButtonAlpha` are the next step, `resolvedTradeChatChrome`. Do
    /// not fold them into this helper.
    class func agreedTradeAfterResolved(
        resolved: ResolvedTradeAfterOpening,
        otherAgree: Bool,
        peerReady: Bool,
        justAcceptTag: Int,
        closeDealTag: Int,
        productsReceivedTag: Int
    ) -> AgreedTradeAfterResolved {
        let sendTag: Int
        if peerReady {
            sendTag = closeDealTag
        } else {
            sendTag = justAcceptTag
        }
        let agreement = HLSwappViewController.otherAgreeOverlay(
            otherAgree: otherAgree,
            status: resolved.offer.status
        )
        var otherOfferAlpha = resolved.otherOfferAlpha
        if let assigned = agreement.otherOfferAlpha {
            otherOfferAlpha = assigned
        }
        var appliedReceiptHide = false
        if let forced = HLSwappViewController.productsReceivedOtherOfferAlpha(
            sendTag: sendTag,
            productsReceivedTag: productsReceivedTag
        ) {
            otherOfferAlpha = forced
            appliedReceiptHide = true
        }
        return AgreedTradeAfterResolved(
            resolved: resolved,
            agreement: agreement,
            sendTag: sendTag,
            otherUserAlpha: agreement.otherUserAlpha,
            otherOfferAlpha: otherOfferAlpha,
            appliedReceiptHide: appliedReceiptHide
        )
    }

    /// Current-chat badge and chat-button alpha after agreement, still on
    /// the resolved trade. `unread` and `peerId` come from `peerChatContext`
    /// on this trade only. The call site still passes `userId` into that
    /// helper as `String`, so a nil user id traps there and is not coalesced
    /// to `""`. The badge shows only when `unread > 0`. The label is
    /// `"\(unread)"` only then. A negative count hides and is stored as
    /// itself. One count is not summed with `arrPastTrades`. `chatButtonAlpha`
    /// is separate. One `[Any]` bid plus a string turn that matches `viewerId`
    /// is `0.3`. Any other array is `1`. A non-array returns nil and does not
    /// assign the button. Opening left that alpha nil. A nil `viewerId` does
    /// not match a string turn, so one bid is `1`. `""` matches `""`.
    /// `" bike "` does not match `"bike"`. One unread does not dim the
    /// button. One bid does not show the badge. When `agreed` is non-nil, the
    /// receipt hide runs after that and forces the other offer to `0` only
    /// when `agreed.sendTag` is still exactly `productsReceivedTag`. On the
    /// barter path that tag is `1` or `91053`, so the hide does not fire. A
    /// nil `agreed` leaves `otherOfferAlpha` nil. Do not treat that nil as
    /// `0`. Do not fold this into `agreedTradeAfterResolved`. Do not change
    /// `manageCheckMarks`. Do not enable `waitingTurnEnabled`. Do not trim.
    /// Do not case-fold. Do not percent-encode. `"a&b"` is not `a%26b`.
    /// `"P1"` is not `"p1"`. `" bike "` is not `bike`. The peer image and
    /// nick refresh is the next step. Do not fold it into this helper. Do
    /// not start that load from `lobbyPageChrome` or `emptyTradeRoomChrome`.
    class func resolvedTradeChatChrome(
        agreed: AgreedTradeAfterResolved?,
        peerId: String,
        unread: Int,
        bids: Any?,
        turnValue: Any?,
        viewerId: String?,
        productsReceivedTag: Int
    ) -> ResolvedTradeChatChrome {
        let showsBadge = unread > 0
        let text: String? = showsBadge ? "\(unread)" : nil
        let alpha = TradeTurnPolicy.chatButtonAlpha(
            bids: bids,
            turnValue: turnValue,
            viewerId: viewerId
        )
        var offerAlpha: CGFloat? = nil
        var appliedHide = false
        if let agreed = agreed {
            offerAlpha = agreed.otherOfferAlpha
            if let forced = HLSwappViewController.productsReceivedOtherOfferAlpha(
                sendTag: agreed.sendTag,
                productsReceivedTag: productsReceivedTag
            ) {
                offerAlpha = forced
                appliedHide = true
            }
        }
        return ResolvedTradeChatChrome(
            agreed: agreed,
            peerId: peerId,
            unread: unread,
            hidesCurrentChatBadge: !showsBadge,
            currentChatText: text,
            chatButtonAlpha: alpha,
            otherOfferAlpha: offerAlpha,
            appliedPostChatReceiptHide: appliedHide
        )
    }

    /// Peer image and nick refresh after `resolvedTradeChatChrome`, still
    /// inside the resolved trade and before the outer receipt hide. Reloads
    /// only when `previousPeerId != peerId`. `prevUser` starts as `""`. The
    /// compare is exact. Do not trim it. `" bike "` is not `"bike"`.
    /// `"a&b"` is not `"a%26b"`. `"P1"` is not `"p1"`. `"" != ""` does not
    /// reload. On a reload, `storedPeerId` is the raw peer id, not the
    /// encoded path. `imageURL` is the instance `userImageURL(userId:)`,
    /// which is `""` when the static builder returns nil. `nickURL` is
    /// `userNickURL`, which is nil for a blank or whitespace-only id so the
    /// call site does not GET `users//nick`. A non-blank id is trimmed and
    /// percent-encoded by `encodedPathSegment`. Do not change that encoder.
    /// Do not compare the encoded value. A nil `imageURL` or `nickURL` means
    /// this step does not load. Do not fold this into
    /// `resolvedTradeChatChrome`. Do not start a load from `lobbyPageChrome`
    /// or `emptyTradeRoomChrome`. The outer receipt hide still runs after
    /// this step and is not decided here. The avatar tap is
    /// `sellerSheetFromStoredPeer`. Do not fold that sheet into this refresh.
    class func resolvedTradePeerRefresh(
        previousPeerId: String,
        peerId: String,
        apiBase: String
    ) -> ResolvedTradePeerRefresh {
        if previousPeerId != peerId {
            return ResolvedTradePeerRefresh(
                previousPeerId: previousPeerId,
                peerId: peerId,
                shouldReload: true,
                storedPeerId: peerId,
                imageURL: CommonUtils.sharedInstance.userImageURL(userId: peerId),
                nickURL: userNickURL(apiBase: apiBase, userId: peerId)
            )
        }
        return ResolvedTradePeerRefresh(
            previousPeerId: previousPeerId,
            peerId: peerId,
            shouldReload: false,
            storedPeerId: previousPeerId,
            imageURL: nil,
            nickURL: nil
        )
    }

    /// Nick body from `users/{id}/nick`. Only a `[String: String]` is read,
    /// which is the historical `json as? [String: String]` cast. A numeric
    /// nick, a bool, `NSNull`, an array, a string body, or a sibling
    /// non-string field drops the whole payload. A missing `nick` stays nil
    /// and does not clear the label. The text is `otherUserNickLabel`: no
    /// trim, no percent-encoding, and not `displayNick`.
    class func nickLabel(from json: Any?) -> String? {
        guard let dict = json as? [String: String] else {
            return nil
        }
        return otherUserNickLabel(dict["nick"])
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

    /// Seller sheet opened from the trade-room avatar. `lookupUserId` is the
    /// raw stored `prevUser`. It starts as `""` and, after a peer refresh,
    /// is that refresh's raw `storedPeerId`, including `" bike "`, `"a&b"`,
    /// `"P1"`, `" "`, and `"\n"`. Do not trim it. Do not pass
    /// `encodedPathSegment`. `profileURL` is `userProfileURL`. Blank and
    /// whitespace-only ids are nil, so `getUserProfile` returns before the
    /// callback and the sheet is not presented even if a dictionary body is
    /// supplied here. A non-blank id is still passed raw; the existing
    /// encoder trims and percent-encodes only the URL. `" bike "` is not
    /// `"bike"`. The sheet is presented only when that URL exists, the
    /// request succeeded, and the body is `[String: Any]`, which is the
    /// historical callback cast. `backFromChat` is set only then. The
    /// storyboard id stays `sellerHorizontal`. The
    /// `as! HLSellerHorizontalViewController` stays at the call site. Do not
    /// fold this into `resolvedTradePeerRefresh`. Do not start it from
    /// `lobbyPageChrome` or `emptyTradeRoomChrome`. The appear skip is
    /// `tradeRoomAppearChrome`. Do not decide that skip here.
    class func sellerSheetFromStoredPeer(
        storedPeerId: String,
        apiBase: String,
        httpOk: Bool,
        json: Any?
    ) -> SellerSheetFromStoredPeer {
        let profileURL = HLDataManager.userProfileURL(apiBase: apiBase, userId: storedPeerId)
        let arrived = httpOk && (json as? [String: Any]) != nil
        let presents = profileURL != nil && arrived
        return SellerSheetFromStoredPeer(
            storedPeerId: storedPeerId,
            lookupUserId: storedPeerId,
            profileURL: profileURL,
            shouldRequest: profileURL != nil,
            presentsSellerSheet: presents,
            backFromChat: presents,
            storyboardIdentifier: "sellerHorizontal"
        )
    }

    /// The avatar callback writes `backFromChat` only when the sheet is
    /// presented. A blank, whitespace-only, failed, or non-object lookup
    /// leaves the current flag untouched, including a flag the chat segue
    /// already set. Do not clear it here. Do not fold
    /// `tradeRoomAppearChrome` into this helper.
    class func backFromChatAfterSellerSheet(
        current: Bool,
        sheet: SellerSheetFromStoredPeer
    ) -> Bool {
        if sheet.presentsSellerSheet {
            return sheet.backFromChat
        }
        return current
    }

    @IBAction func showUserAction(_ sender: Any) {
        //print (prevUser)
        let lookup = HLSwappViewController.sellerSheetFromStoredPeer(
            storedPeerId: prevUser,
            apiBase: HulaConstants.apiURL,
            httpOk: false,
            json: nil
        )
        HLDataManager.sharedInstance.getUserProfile(userId: lookup.lookupUserId, taskCallback: {(user, prods, feedback) in
            let sheet = HLSwappViewController.sellerSheetFromStoredPeer(
                storedPeerId: lookup.storedPeerId,
                apiBase: HulaConstants.apiURL,
                httpOk: true,
                json: [String: Any]()
            )
            if sheet.presentsSellerSheet {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: sheet.storyboardIdentifier) as! HLSellerHorizontalViewController

                viewController.user = user
                self.present(viewController, animated: true)
                self.backFromChat = HLSwappViewController.backFromChatAfterSellerSheet(
                    current: self.backFromChat,
                    sheet: sheet
                )
            }
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

        // Stored for the lobby offset as well. The trade-room animation uses
        // the same raw difference and does not add 500.
        let opening = HLSwappViewController.tradeRoomOpeningChrome(
            viewWidth: self.view.frame.width,
            otherUserWidth: self.otherUserView.frame.width
        )
        initialOtherUserX = opening.initialOtherUserX
        
        if (index != 0){
            // Opening shell, before the page-controller lookup. An empty
            // room overwrites it. Three dots stay outside the animation.
            UIView.animate(withDuration: 0.3) {
                self.mainCentralLabel.alpha = opening.centralLabelAlpha
                self.myUserView.frame.origin.x = opening.myUserOriginX
                self.otherUserView.frame.origin.x = opening.otherUserOriginX
                self.sendOfferBtn.alpha = opening.sendAlpha
                self.otherOfferBtn.alpha = opening.otherOfferAlpha
                self.addTradeRoomBtn.alpha = opening.addTradeRoomAlpha
                self.mainCentralLabel.alpha = opening.centralLabelAlpha
                self.currentTradesBtn.alpha = opening.currentTradesAlpha
                self.pastTradesBtn.alpha = opening.pastTradesAlpha
                self.tradeModeLine.alpha = opening.tradeModeLineAlpha
                self.pastChatCountLbl.isHidden = opening.hidesPastChatBadge
            }
            self.threeDotsView.isHidden = opening.hidesThreeDots
            
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                if let thisTrade = DashboardTradeSelection.resolvedTrade(
                    currentTrade: swappPageVC.currentTrade,
                    currentIndex: swappPageVC.currentIndex,
                    trades: swappPageVC.arrTrades
                ) {
                    last_index_setup = swappPageVC.currentIndex
                    // Nil `userId` still traps here. Do not coalesce it to `""`
                    // before the badge read. Chat chrome runs after agreement.
                    let peer = HLSwappViewController.peerChatContext(
                        from: thisTrade,
                        viewerId: HulaUser.sharedInstance.userId
                    )


                    // Overwrite only the fields offer chrome assigns. The
                    // opening shell stays for everything else. The gate stays
                    // off. Check marks and the agreement overlay run later.
                    let resolved = HLSwappViewController.resolvedTradeAfterOpening(
                        opening: opening,
                        status: thisTrade.object(forKey: "status"),
                        turnUserId: thisTrade.object(forKey: "turn_user_id"),
                        viewerId: HulaUser.sharedInstance.userId,
                        waitingTurnEnabled: false,
                        productsReceivedTag: kTagProductsReceived
                    )
                    let offer = resolved.offer
                    if offer.hidesSend {
                        self.sendOfferBtn.alpha = 0
                    }
                    if let otherAlpha = offer.otherOfferAlpha {
                        self.otherOfferBtn.alpha = otherAlpha
                    }
                    if let centralAlpha = offer.centralLabelAlpha {
                        self.mainCentralLabel.alpha = centralAlpha
                    }
                    if let remainingAlpha = offer.remainingAlpha {
                        self.remainingTimeLabel.alpha = remainingAlpha
                    }
                    if let hidesDots = offer.hidesThreeDots {
                        self.threeDotsView.isHidden = hidesDots
                    }
                    if let title = offer.sendTitle {
                        self.sendOfferBtn.setTitle(title, for: .normal)
                    }
                    if let tag = offer.sendTag {
                        self.sendOfferBtn.tag = tag
                    }
                    if offer.showsWaiting {
                        // Reachable only if `waitingTurnEnabled` is turned on.
                        // The call above keeps it false, so this does not run.
                        self.mainCentralLabel.text = NSLocalizedString("Waiting for user reply", comment: "")
                        if let str_hours = HLSwappViewController.remainingResponseHoursLabel(
                            lastUpdate: thisTrade.object(forKey: "last_update")
                        ) {
                            self.remainingTimeLabel.alpha = 1
                            self.remainingTimeLabel.text = NSLocalizedString("Remaining time for response:", comment: "") + " \(str_hours)"
                        } else {
                            self.remainingTimeLabel.alpha = 0
                        }
                    }
                    
                    
                    
                    var agreedForChat: AgreedTradeAfterResolved? = nil
                    if let tr = self.barterDelegate?.getCurrentTradeStatus() {
                        //print("updating checkmarks...");
                        print("owner ready \(tr.owner_ready)");
                        print("other ready \(tr.other_ready)");
                        self.manageCheckMarks(trade: tr);

                        // Check marks already replaced the send tag. Agreement
                        // overwrites the other offer except exact closed and
                        // ended. Chat chrome is the next step and is not part
                        // of this one. The receipt hide still runs after chat.
                        let agreed = HLSwappViewController.agreedTradeAfterResolved(
                            resolved: resolved,
                            otherAgree: tr.other_agree,
                            peerReady: TradeReadyPolicy.peerIsReady(
                                trade: tr,
                                viewerId: HulaUser.sharedInstance.userId
                            ),
                            justAcceptTag: kTagJustAccept,
                            closeDealTag: kTagCloseDeal,
                            productsReceivedTag: kTagProductsReceived
                        )
                        self.sendOfferBtn.tag = agreed.sendTag
                        self.otherUserView.alpha = agreed.otherUserAlpha
                        self.otherOfferBtn.alpha = agreed.otherOfferAlpha
                        agreedForChat = agreed
                    }

                    // Badge and chat alpha. A nil alpha does not assign the
                    // button. The post-chat hide writes only when the stored
                    // tag is still the products-received tag. The outer hide
                    // still runs for the empty room and a leftover tag.
                    let chat = HLSwappViewController.resolvedTradeChatChrome(
                        agreed: agreedForChat,
                        peerId: peer.peerId,
                        unread: peer.unread,
                        bids: thisTrade.object(forKey: "bids"),
                        turnValue: thisTrade.object(forKey: "turn_user_id"),
                        viewerId: HulaUser.sharedInstance.userId,
                        productsReceivedTag: kTagProductsReceived
                    )
                    if let text = chat.currentChatText {
                        self.chatCountLbl.text = text
                    }
                    self.chatCountLbl.isHidden = chat.hidesCurrentChatBadge
                    if let alpha = chat.chatButtonAlpha {
                        self.chatButton.alpha = alpha
                    }
                    if chat.appliedPostChatReceiptHide {
                        if let offerAlpha = chat.otherOfferAlpha {
                            self.otherOfferBtn.alpha = offerAlpha
                        }
                    }
                    let other_user_id = chat.peerId

                    // Image and nick only when the raw peer id changes.
                    // Blank ids still reload against a different previous id,
                    // but they do not GET `users//nick`. The outer receipt
                    // hide stays after this block.
                    let refresh = HLSwappViewController.resolvedTradePeerRefresh(
                        previousPeerId: prevUser,
                        peerId: other_user_id,
                        apiBase: HulaConstants.apiURL
                    )
                    if refresh.shouldReload {
                        prevUser = refresh.storedPeerId
                        if let imageURL = refresh.imageURL {
                            otherUserImage.loadImageFromURL(urlString: imageURL)
                        }
                        if let queryURL = refresh.nickURL {
                            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (result, json) in
                                if let label = HLSwappViewController.nickLabel(from: json) {
                                    DispatchQueue.main.async {
                                        self.otherUserNick.text = label
                                    }
                                }
                            })
                        }
                    }
                    
                    
                    
                } else {
                    // No resolved trade. Opening animation already showed the
                    // other offer and parked the counterparty on screen. This
                    // step hides that offer and moves the counterparty off
                    // screen. The receipt-tag hide still runs after the page
                    // controller lookup. Check marks stay a separate call.
                    let empty = HLSwappViewController.emptyTradeRoomChrome(
                        initialOtherUserX: self.initialOtherUserX
                    )
                    self.addTradeRoomBtn.alpha = empty.addTradeRoomAlpha
                    self.mainCentralLabel.alpha = empty.centralLabelAlpha
                    self.myUserView.frame.origin.x = empty.myUserOriginX
                    self.otherUserView.frame.origin.x = empty.otherUserOriginX
                    self.sendOfferBtn.alpha = empty.sendAlpha
                    self.otherOfferBtn.alpha = empty.otherOfferAlpha
                    self.chatButton.alpha = empty.chatButtonAlpha
                    self.remainingTimeLabel.alpha = empty.remainingAlpha
                    self.threeDotsView.isHidden = empty.hidesThreeDots
                    self.currentTradesBtn.alpha = empty.currentTradesAlpha
                    self.pastTradesBtn.alpha = empty.pastTradesAlpha
                    self.tradeModeLine.alpha = empty.tradeModeLineAlpha
                    self.chatCountLbl.isHidden = empty.hidesCurrentChatBadge
                    self.pastChatCountLbl.isHidden = empty.hidesPastChatBadge

                    self.manageCheckMarks(trade: nil);
                }
            }
            
            if let receiptAlpha = HLSwappViewController.productsReceivedOtherOfferAlpha(
                sendTag: self.sendOfferBtn.tag,
                productsReceivedTag: kTagProductsReceived
            ) {
                self.otherOfferBtn.alpha = receiptAlpha
            }
            
        } else {
            // index == 0
            // Add-room alpha and the past-chat badge come from the last row
            // only. Frames stay here. No image load. No receipt-tag hide.
            
            last_index_setup = 0
            let lobby = HLSwappViewController.lobbyPageChrome(
                maxTrades: HulaUser.sharedInstance.maxTrades,
                pastTrades: HLDataManager.sharedInstance.arrPastTrades,
                viewerId: HulaUser.sharedInstance.userId
            )
            UIView.animate(withDuration: 0.3) {
                /*
                self.extraRoomBtn.alpha = 1
                self.extraRoomImage.alpha = 1
                self.nextTradeBtn.alpha = 1
                 */
                self.addTradeRoomBtn.alpha = lobby.addTradeRoomAlpha
                self.mainCentralLabel.alpha = lobby.centralLabelAlpha
                self.myUserView.frame.origin.x = -500
                self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                self.sendOfferBtn.alpha = lobby.sendAlpha
                self.otherOfferBtn.alpha = lobby.otherOfferAlpha
                //self.mainCentralLabel.text = "Available Table Rooms"
                self.chatButton.alpha = lobby.chatButtonAlpha
                self.remainingTimeLabel.alpha = lobby.remainingAlpha
                self.threeDotsView.isHidden = lobby.hidesThreeDots
                self.currentTradesBtn.alpha = lobby.currentTradesAlpha
                self.pastTradesBtn.alpha = lobby.pastTradesAlpha
                self.tradeModeLine.alpha = lobby.tradeModeLineAlpha
                self.pastChatCountLbl.isHidden = true
            }
            self.chatCountLbl.isHidden = lobby.hidesCurrentChatBadge
            
            if lobby.showsPastChatBadge {
                self.pastChatCountLbl.isHidden = false
                self.pastChatCountLbl.text = "\(lobby.pastChatCount)"
                print("chat_count")
                print(lobby.pastChatCount)
                print("other_user_id")
                print(lobby.pastChatPeerId)
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

/// Status-driven offer button on the trade-room bottom bar.
/// `hidesSend` sets the send alpha to 0. A nil alpha or dots flag means this
/// branch does not assign that view. Remaining time for the waiting label is
/// left nil so `remainingResponseHoursLabel` still owns that text.
struct BottomBarOfferChrome {
    let status: String
    let hidesSend: Bool
    let otherOfferAlpha: CGFloat?
    let centralLabelAlpha: CGFloat?
    let remainingAlpha: CGFloat?
    let hidesThreeDots: Bool?
    let sendTitle: String?
    let sendTag: Int?
    let showsAccept: Bool
    let showsWaiting: Bool
}

/// Agreement dimming on the trade-room bottom bar. A nil `otherOfferAlpha`
/// means this step does not assign the other offer button.
struct OtherAgreeOverlay {
    let otherUserAlpha: CGFloat
    let otherOfferAlpha: CGFloat?
}

/// Lobby page (`index == 0`) bottom bar. `addTradeRoomAlpha` is `0.3` at the
/// 50-room cap and `1` below it. The past-chat fields are the last
/// `arrPastTrades` row only. `pastChatPeerId` is not an image URL. This step
/// does not assign a send tag and does not apply the products-received hide.
struct LobbyPageChrome {
    let addTradeRoomAlpha: CGFloat
    let showsPastChatBadge: Bool
    let pastChatCount: Int
    let pastChatPeerId: String
    let hidesCurrentChatBadge: Bool
    let sendAlpha: CGFloat
    let otherOfferAlpha: CGFloat
    let centralLabelAlpha: CGFloat
    let chatButtonAlpha: CGFloat
    let remainingAlpha: CGFloat
    let hidesThreeDots: Bool
    let currentTradesAlpha: CGFloat
    let pastTradesAlpha: CGFloat
    let tradeModeLineAlpha: CGFloat
}

/// Empty trade room (`index != 0` and `resolvedTrade` is nil). The add-room
/// button is `0`, not the lobby `1` or `0.3`. The counterparty origin is
/// `initialOtherUserX + 500`. The viewer origin is `0`. Both chat badges are
/// hidden. This step does not assign a send tag. The products-received hide
/// still runs after it.
struct EmptyTradeRoomChrome {
    let addTradeRoomAlpha: CGFloat
    let centralLabelAlpha: CGFloat
    let myUserOriginX: CGFloat
    let otherUserOriginX: CGFloat
    let sendAlpha: CGFloat
    let otherOfferAlpha: CGFloat
    let chatButtonAlpha: CGFloat
    let remainingAlpha: CGFloat
    let hidesThreeDots: Bool
    let currentTradesAlpha: CGFloat
    let pastTradesAlpha: CGFloat
    let tradeModeLineAlpha: CGFloat
    let hidesCurrentChatBadge: Bool
    let hidesPastChatBadge: Bool
}

/// Opening animation on a trade-room page (`index != 0`), before the page
/// controller lookup. `otherUserOriginX` equals `initialOtherUserX`
/// (`viewWidth - otherUserWidth`). It is not `initialOtherUserX + 500`.
/// Send and the other offer are `1`. A nil chat, remaining, current-badge,
/// or send-tag field means this step does not assign that view. The
/// products-received hide still runs after it and can force the other offer
/// to `0` only when the leftover send tag is `90441`.
struct TradeRoomOpeningChrome {
    let centralLabelAlpha: CGFloat
    let myUserOriginX: CGFloat
    let otherUserOriginX: CGFloat
    let initialOtherUserX: CGFloat
    let sendAlpha: CGFloat
    let otherOfferAlpha: CGFloat
    let addTradeRoomAlpha: CGFloat
    let currentTradesAlpha: CGFloat
    let pastTradesAlpha: CGFloat
    let tradeModeLineAlpha: CGFloat
    let hidesPastChatBadge: Bool
    let hidesThreeDots: Bool
    let chatButtonAlpha: CGFloat?
    let remainingAlpha: CGFloat?
    let hidesCurrentChatBadge: Bool?
    let sendTag: Int?
}

/// Resolved trade laid over the opening animation. `offer` is assigned with
/// the same nil-means-do-not-touch rules as `bottomBarOfferChrome`. The
/// non-optional alphas are the opening values after that overwrite. A nil
/// `offer.sendTag` leaves a leftover products-received tag in place.
/// `agreedTradeAfterResolved` is the later step when a barter trade exists.
struct ResolvedTradeAfterOpening {
    let opening: TradeRoomOpeningChrome
    let offer: BottomBarOfferChrome
    let sendAlpha: CGFloat
    let otherOfferAlpha: CGFloat
    let centralLabelAlpha: CGFloat
    let hidesThreeDots: Bool
}

/// Agreement laid over a resolved trade after check marks replace the send
/// tag. `sendTag` is never nil: `closeDealTag` when the peer is ready, and
/// `justAcceptTag` otherwise. `appliedReceiptHide` is true only when that
/// tag is still exactly the products-received tag, which forces
/// `otherOfferAlpha` to 0. A nil agreement alpha leaves the resolved other
/// offer in place. Send alpha, frames, the chat button, and the three-dots
/// flag stay on `resolved`. `resolvedTradeChatChrome` is the next step.
struct AgreedTradeAfterResolved {
    let resolved: ResolvedTradeAfterOpening
    let agreement: OtherAgreeOverlay
    let sendTag: Int
    let otherUserAlpha: CGFloat
    let otherOfferAlpha: CGFloat
    let appliedReceiptHide: Bool
}

/// Chat badge and chat-button alpha after agreement. `currentChatText` is
/// nil when the badge hides, including a negative `unread`. A nil
/// `chatButtonAlpha` means this step does not assign the button. A nil
/// `otherOfferAlpha` means no agreed trade was passed, so this step does
/// not assign the other offer. `appliedPostChatReceiptHide` is true only
/// when the agreed send tag is still exactly the products-received tag.
struct ResolvedTradeChatChrome {
    let agreed: AgreedTradeAfterResolved?
    let peerId: String
    let unread: Int
    let hidesCurrentChatBadge: Bool
    let currentChatText: String?
    let chatButtonAlpha: CGFloat?
    let otherOfferAlpha: CGFloat?
    let appliedPostChatReceiptHide: Bool
}

/// Image and nick load after chat chrome. `shouldReload` is exact
/// `previousPeerId != peerId`. `storedPeerId` is the raw id written back to
/// `prevUser`. `imageURL` is nil when this step does not load, and `""` when
/// the static avatar builder returns nil. `nickURL` is nil when this step
/// does not GET, including a blank or whitespace-only peer.
struct ResolvedTradePeerRefresh {
    let previousPeerId: String
    let peerId: String
    let shouldReload: Bool
    let storedPeerId: String
    let imageURL: String?
    let nickURL: String?
}

/// Avatar tap after a peer id has been stored. `lookupUserId` is that raw
/// id, not the encoded path and not a trimmed copy. `profileURL` is nil when
/// `getUserProfile` returns before the callback. `presentsSellerSheet` and
/// `backFromChat` are true only for a real request whose body is
/// `[String: Any]`. The storyboard id stays `sellerHorizontal`.
struct SellerSheetFromStoredPeer {
    let storedPeerId: String
    let lookupUserId: String
    let profileURL: String?
    let shouldRequest: Bool
    let presentsSellerSheet: Bool
    let backFromChat: Bool
    let storyboardIdentifier: String
}

/// `viewDidAppear` bottom-bar decision. `shouldSetupBottomBar` is the
/// incoming flag inverted. `backFromChat` is the flag after the check and
/// is always false. `setupIndex` is the stored index, unchanged.
struct TradeRoomAppearChrome {
    let backFromChatBefore: Bool
    let shouldSetupBottomBar: Bool
    let setupIndex: Int
    let backFromChat: Bool
}

/// Turn checks compared IUO `turn_user_id` / `userId` with `!=` and `==`.
/// A nil id crashed Accept (the `&& false` gate is evaluated after that compare),
/// the bartering remaining-time bar, the barter room's empty turn branch, and
/// the first-bid chat dim.
/// Nil does not match anyone, including another nil. Empty strings still match.
/// The Accept gate and the waiting-turn label stay disabled until product turns them on.
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

    /// Bartering bottom bar used `turn != userId && false`. The compare ran
    /// first, so a nil viewer crashed even though waiting chrome never shows.
    /// While the gate is off the ids are not compared. When it is on, waiting
    /// shows only when the turn is not the viewer. Do not trim.
    static func showsWaitingForReply(
        turnUserId: String?,
        viewerId: String?,
        waitingTurnEnabled: Bool
    ) -> Bool {
        if !waitingTurnEnabled {
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
