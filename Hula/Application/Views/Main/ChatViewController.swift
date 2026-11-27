//
//  ChatViewController.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatTextField: UITextField!

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatTextFrame: UIView!
    var chat:[NSDictionary] = [];
    var trade_id:String = "";
    
    var sortedChat:NSMutableDictionary = [:]
    var sectionKeys:[String] = []
    
    var keyboardHeight:CGFloat = 150
    var timer: Timer!

    static let maxChatMessageLength = 300

    /// Returns a sendable message, or nil when over the limit (do not silently truncate).
    class func validatedChatMessage(_ text: String?) -> String? {
        let tx = (text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard tx.count > 0 else {
            return nil
        }
        if tx.count > maxChatMessageLength {
            return nil
        }
        return tx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateData(forze: true)
        //print(sortedChat)
        
        chatTextFrame.layer.cornerRadius = 15
        chatTextFrame.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        chatTextFrame.layer.masksToBounds = true
        chatTextFrame.layer.borderWidth = 1.0
        
        let tapper = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        view.addGestureRecognizer(tapper)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.refreshChat), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.refreshChat), userInfo: nil, repeats: true)
        
        HLDataManager.sharedInstance.ga("chat")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        
        timer.invalidate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /// Chat POST body. `&`/`=`/`+` in the message must not split the form.
    class func chatPostString(message: String) -> String {
        return "message=" + CommonUtils.formEncodedValue(message)
    }

    /// Chat load/send path. Empty trade_id must not hit `trades//chat`.
    /// Reserved characters in the id must not invent extra path or query parts.
    static func chatRequestURL(apiBase: String, tradeId: String) -> String? {
        return CommonUtils.tradeResourceURL(apiBase: apiBase, tradeId: tradeId, extra: ["chat"])
    }

    /// Chat poll replacement. `refreshChat` replaces `self.chat` only when
    /// `chatRequestURL` is non-nil, the request is ok, and
    /// `json as? [NSDictionary]` succeeds, then calls `updateData`. A nil
    /// URL, a failed request, nil, `NSNull`, a dictionary, a string, a
    /// number, a bool, or a non-dictionary array keeps the seed from
    /// `chatConfiguration`, including a present message array and a missing
    /// `chat` that was seeded as `[]`. An empty dictionary array does
    /// replace the seed. Do not unwrap `json!`. The `print(json!)` in
    /// `refreshChat` stays inside a comment. A blank `trade_id` (`""`,
    /// `" "`, `"   "`, `"\n"`, `"\t"`) still makes `chatRequestURL` nil, so
    /// this refresh does not GET and does not replace. `tradeId` is echoed
    /// raw. Do not trim it. `" bike "` is not `"bike"`. `"a&b"` is not
    /// `"a%26b"`. `"P1"` is not `"p1"`. `" "` is not `""` and is not `"\n"`.
    /// Encoding stays in `chatRequestURL`. Do not change
    /// `tradeResourceURL`. Do not fold this into `chatSegueBadgeHide`. Do
    /// not filter dates here. `updateData` still skips a message whose date
    /// is not a string section key, and that filter stays there.
    /// `filtersDates` stays false. `clearsTextField` stays false. The send
    /// clear lives in `chatSendClear` and must not be folded into this
    /// helper. Do not change `manageCheckMarks`. Do not enable
    /// `waitingTurnEnabled`.
    class func chatRefreshReplacement(
        apiBase: String,
        tradeId: String,
        seededChat: [NSDictionary],
        httpOk: Bool,
        json: Any?
    ) -> ChatRefreshReplacement {
        let requestURL = chatRequestURL(apiBase: apiBase, tradeId: tradeId)
        let requestsChat = requestURL != nil
        var chat = seededChat
        var replacesChat = false
        if requestsChat && httpOk {
            if let dictionary = json as? [NSDictionary] {
                chat = dictionary
                replacesChat = true
            }
        }
        return ChatRefreshReplacement(
            tradeId: tradeId,
            requestsChat: requestsChat,
            requestURL: requestURL,
            replacesChat: replacesChat,
            chat: chat,
            updatesData: replacesChat,
            filtersDates: false,
            clearsTextField: false,
            unwrapsJSON: false
        )
    }

    /// Send callback. After `validatedChatMessage` and `chatRequestURL` both
    /// succeed, the composer clears and `refreshChat(forze: true)` runs only
    /// when `httpOk` and `json as? NSDictionary` succeed. An empty dictionary
    /// still clears. A failed request, nil, `NSNull`, a dictionary array
    /// (including one `chatRefreshReplacement` would apply), a string array,
    /// a string, a number, or a bool keeps the draft. Do not unwrap `json`.
    /// Do not fold this clear into `chatRefreshReplacement`. `replacesChat`
    /// stays false. `filtersDates` stays false. A blank `trade_id` (`""`,
    /// `" "`, `"   "`, `"\n"`, `"\t"`) still makes `chatRequestURL` nil, so
    /// this send does not POST and does not clear. `tradeId` is echoed raw.
    /// Do not trim it. `" bike "` is not `"bike"`. `"a&b"` is not `"a%26b"`.
    /// `"P1"` is not `"p1"`. Encoding stays in `chatRequestURL`. The
    /// untrimmed draft longer than 300 characters still shows the length
    /// alert and does not POST, even when trimming would fit. Do not trim
    /// before that count. `validatedChatMessage` still trims and rejects
    /// blank text before the request. Do not reimplement that trim here.
    /// Do not change `chatPostString`. The refresh after a clear stays a
    /// separate `refreshChat` call. `getTrades` still runs for every POST
    /// callback, including when the draft stays. That reload lives in
    /// `chatSendTradeReload` and is not this helper. Do not fold the reload
    /// into `clearsTextField`. Do not dismiss the chat from this helper.
    class func chatSendClear(
        apiBase: String,
        tradeId: String,
        draft: String?,
        httpOk: Bool,
        json: Any?
    ) -> ChatSendClear {
        let draftText = draft ?? ""
        let showsLengthAlert = draftText.characters.count > maxChatMessageLength
        let message = showsLengthAlert ? nil : validatedChatMessage(draftText)
        let requestURL = chatRequestURL(apiBase: apiBase, tradeId: tradeId)
        let posts = (message != nil) && (requestURL != nil)
        var postString: String? = nil
        if posts, let message = message {
            postString = chatPostString(message: message)
        }
        let clearsTextField = posts && httpOk && ((json as? NSDictionary) != nil)
        return ChatSendClear(
            tradeId: tradeId,
            draft: draftText,
            message: message,
            showsLengthAlert: showsLengthAlert,
            posts: posts,
            requestURL: requestURL,
            postString: postString,
            clearsTextField: clearsTextField,
            refreshesChat: clearsTextField,
            keptDraft: clearsTextField ? "" : draftText,
            replacesChat: false,
            filtersDates: false,
            unwrapsJSON: false
        )
    }

    /// Trade reload after a chat POST. `sendChatTextAction` calls
    /// `getTrades` for every callback once a post was issued, including when
    /// the composer stays (failed request, nil, `NSNull`, a dictionary
    /// array, a string array, a string, a number, or a bool). It does not
    /// run when the send never posts: a blank trade id (`""`, `" "`,
    /// `"   "`, `"\n"`, `"\t"`), a blank or whitespace draft, or an
    /// untrimmed draft longer than 300 characters. `reloadsTrades` follows
    /// `posts`, not `clearsTextField`. Do not fold this reload into
    /// `chatSendClear`. Do not dismiss the chat from this helper.
    /// `dismissesChat` stays false. `refreshesChat` stays false; the clear
    /// path still refreshes through `chatSendClear`. `replacesChat` stays
    /// false. Do not filter dates. Do not unwrap `json`. `chatCloseDismiss`
    /// still reloads trades and then dismisses without a dictionary check.
    /// Do not fold that dismiss into this helper. Do not trim `tradeId`.
    /// `" bike "` is not `"bike"`. `"a&b"` is not `"a%26b"`. `"P1"` is not
    /// `"p1"`. Encoding stays in `chatRequestURL` and `chatPostString`.
    class func chatSendTradeReload(
        apiBase: String,
        tradeId: String,
        draft: String?,
        httpOk: Bool,
        json: Any?
    ) -> ChatSendTradeReload {
        let send = chatSendClear(
            apiBase: apiBase,
            tradeId: tradeId,
            draft: draft,
            httpOk: httpOk,
            json: json
        )
        return ChatSendTradeReload(
            tradeId: send.tradeId,
            draft: send.draft,
            showsLengthAlert: send.showsLengthAlert,
            posts: send.posts,
            requestURL: send.requestURL,
            clearsTextField: send.clearsTextField,
            reloadsTrades: send.posts,
            keptDraft: send.keptDraft,
            dismissesChat: false,
            refreshesChat: false,
            replacesChat: false,
            filtersDates: false,
            unwrapsJSON: false
        )
    }

    /// Close button. `closeChatAction` calls `getTrades` and then dismisses
    /// on the main queue. It does not wait for that callback, and it does
    /// not read `succ`. A blank trade id (`""`, `" "`, `"   "`, `"\n"`,
    /// `"\t"`), a blank or whitespace draft, a nil draft, 300 spaces, and
    /// an untrimmed draft longer than 300 characters still reload and still
    /// dismiss. There is no length alert and no POST. A dictionary, a
    /// dictionary array, a string, a number, a bool, nil, and `NSNull` do
    /// not change that. `httpOk` is ignored. Do not fold this dismiss into
    /// `chatSendTradeReload` (`dismissesChat` stays false there). Do not
    /// skip the reload because the draft is still present or the body is
    /// not an `NSDictionary`. Do not require `validatedChatMessage`. Do not
    /// clear the composer. `keptDraft` stays the raw draft, including
    /// `" hello "`. Do not refresh the thread. Do not replace the polled
    /// chat. Do not filter dates. Do not unwrap `json`. `tradeId` stays
    /// raw. Do not trim it. `" bike "` is not `"bike"`. `"a&b"` is not
    /// `"a%26b"`. `"P1"` is not `"p1"`. This helper does not build
    /// `chatRequestURL`. Encoding stays on the send and poll paths.
    class func chatCloseDismiss(
        tradeId: String,
        draft: String?,
        httpOk: Bool,
        json: Any?
    ) -> ChatCloseDismiss {
        let draftText = draft ?? ""
        // httpOk and json stay in the signature so callers can pass the
        // send callback's status and body. Neither one gates the close.
        return ChatCloseDismiss(
            tradeId: tradeId,
            draft: draftText,
            showsLengthAlert: false,
            posts: false,
            requestURL: nil,
            postString: nil,
            clearsTextField: false,
            reloadsTrades: true,
            keptDraft: draftText,
            dismissesChat: true,
            waitsForReload: false,
            requiresReloadSuccess: false,
            refreshesChat: false,
            replacesChat: false,
            filtersDates: false,
            unwrapsJSON: false
        )
    }

    func refreshChat(forze: Bool){
        //print("refreshing...")
        //print("trade id: \(trade_id)")
        if let queryURL = ChatViewController.chatRequestURL(apiBase: HulaConstants.apiURL, tradeId: trade_id) {
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print("done")
                //print(ok)
                //print(json!)
                // Replace only for an ok dictionary array. Any other body
                // keeps the seeded chat. Do not unwrap json. Do not filter
                // dates here. Do not clear the text field.
                let replacement = ChatViewController.chatRefreshReplacement(
                    apiBase: HulaConstants.apiURL,
                    tradeId: self.trade_id,
                    seededChat: self.chat,
                    httpOk: ok,
                    json: json
                )
                if replacement.replacesChat {
                    DispatchQueue.main.async(execute: {
                        self.chat = replacement.chat
                        self.updateData(forze: forze)
                    })
                }
            })
        }
        
        
        // Portrait auto-dismiss used to live here and in rotated(). rotated() was disabled;
        // keep the poll path consistent so composing drafts are not wiped by orientation flicker.
        if ChatViewController.shouldAutoDismissForOrientation(UIDevice.current.orientation) {
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }

    /// Chat is landscape-first; do not auto-dismiss on portrait polls (draft loss).
    /// Explicit close remains via `closeChatAction`.
    class func shouldAutoDismissForOrientation(_ orientation: UIDeviceOrientation) -> Bool {
        return false
    }

    /// Section header. Missing HelveticaNeue must not assign a nil font.
    class func sectionHeaderFont() -> UIFont {
        return CatalogFontPolicy.font(named: "HelveticaNeue", size: 12)
    }

    /// Chat row height used `font!`. Nil cell font / non-string messages must not crash the table.
    class func messageRowHeight(width: CGFloat, font: UIFont?, message: Any?) -> CGFloat {
        return LabelMetricsPolicy.layoutHeight(
            width: width,
            font: font,
            text: message as? String,
            extra: 30,
            scale: 1.3
        )
    }

    /// Chat table sections. Reloads that shrink `sectionKeys` must not OOB-crash
    /// `numberOfRows` / `cellForRow` / header title lookups.
    class func sectionKey(_ sectionKeys: [String], section: Int) -> String? {
        guard section >= 0 && section < sectionKeys.count else {
            return nil
        }
        return sectionKeys[section]
    }

    class func comments(in sortedChat: NSDictionary, sectionKeys: [String], section: Int) -> [NSDictionary]? {
        guard let key = sectionKey(sectionKeys, section: section) else {
            return nil
        }
        return sortedChat.object(forKey: key) as? [NSDictionary]
    }

    class func comment(in sortedChat: NSDictionary, sectionKeys: [String], section: Int, row: Int) -> NSDictionary? {
        guard let comments = comments(in: sortedChat, sectionKeys: sectionKeys, section: section),
              row >= 0 && row < comments.count else {
            return nil
        }
        return comments[row]
    }
    
    func updateData(forze: Bool){
        let prev_co = self.chatTableView.contentOffset
        let prev_sect = self.sectionKeys.count
        let prev_chats = self.sortedChat.hashValue
        self.sectionKeys = []
        self.sortedChat = [:]
        for message in self.chat{
            if let date = message.object(forKey: "date") as? String,
                let date_extract = CommonUtils.chatDateSectionKey(date) {
                //print(date_extract)
                if var exists = self.sortedChat.object(forKey: date_extract) as? [NSDictionary]{
                    exists.append(message)
                    self.sortedChat.setValue(exists, forKey: date_extract)
                } else {
                    self.sortedChat.setValue([message], forKey: date_extract)
                    self.sectionKeys.append(date_extract)
                }
            }
        }
        self.chatTableView.reloadData()
        if (prev_sect != self.sectionKeys.count) || (prev_chats != self.sortedChat.hashValue) || forze {
            print("refreshing chat...")
            
            DispatchQueue.main.async(execute: {
                self.chatTableView.setContentOffset(prev_co, animated: false)
                self.chatTableView.setContentOffset(CGPoint(x:0, y:self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
            })
        }
    }
    
    
    @IBAction func sendChatTextAction(_ sender: Any) {
        let raw = self.chatTextField.text ?? ""
        let tradeId = self.trade_id
        let decision = ChatViewController.chatSendClear(
            apiBase: HulaConstants.apiURL,
            tradeId: tradeId,
            draft: raw,
            httpOk: false,
            json: nil
        )
        if decision.showsLengthAlert {
            let alert = UIAlertController(
                title: NSLocalizedString("Message too long", comment: ""),
                message: NSLocalizedString("Please keep trade chat messages to 300 characters or fewer.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard decision.posts,
            let queryURL = decision.requestURL,
            let postBody = decision.postString else {
            return
        }
        //print("Sending...")
        //print("trade id: \(self.trade_id)")
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: postBody, isPut: false, taskCallback: { (ok, json) in
            //print("done")
            //print(ok)
            // Clear only for an ok dictionary. Do not unwrap json. A
            // dictionary array is a poll body and must keep the draft.
            let outcome = ChatViewController.chatSendClear(
                apiBase: HulaConstants.apiURL,
                tradeId: tradeId,
                draft: raw,
                httpOk: ok,
                json: json
            )
            if outcome.clearsTextField {
                DispatchQueue.main.async(execute: {
                    self.chatTextField.text = ""
                    self.refreshChat(forze:true)
                })
            }
            // Reload trades for every POST callback, including when the
            // draft stays. Do not dismiss. Do not refresh the thread from
            // this reload. chatCloseDismiss still reloads and then dismisses.
            let reload = ChatViewController.chatSendTradeReload(
                apiBase: HulaConstants.apiURL,
                tradeId: tradeId,
                draft: raw,
                httpOk: ok,
                json: json
            )
            if reload.reloadsTrades {
                HLDataManager.sharedInstance.getTrades {(succ) in
                    // trades refreshed
                    print("Trades loaded from chat")
                }
            }
        })
    }
    
    
    @IBAction func closeChatAction(_ sender: Any) {
        // Reload and dismiss even when the composer still holds text, the
        // trade id is blank, or there is no chat response. Do not POST, do
        // not clear, do not refresh the thread, and do not wait for
        // getTrades. The send callback still does not dismiss.
        var draft: String? = nil
        if let field = self.chatTextField {
            draft = field.text
        }
        let close = ChatViewController.chatCloseDismiss(
            tradeId: self.trade_id,
            draft: draft,
            httpOk: false,
            json: nil
        )
        if close.reloadsTrades {
            HLDataManager.sharedInstance.getTrades{(succ) in
                // trades refreshed
                print("Trades loaded from chat")
            }
        }
        if close.dismissesChat && !close.waitsForReload {
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    func rotated() {
        /*
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            self.presentingViewController?.dismiss(animated: true)
            self.dismiss(animated: true)
        }
 */
    }
 
}
extension ChatViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
    }
    func endEditing(){
        self.animateTextField(textField: UITextField(), up:false)
        chatTextField.resignFirstResponder()
    }
    
    func animateTextField(textField: UITextField, up: Bool){
        let movementDistance:CGFloat = -keyboardHeight
        var movementDuration: Double = 0.2
        //print(keyboardHeight)
        var newFrame:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: self.view.frame.size)
        if up {
            newFrame = newFrame.offsetBy(dx: 0, dy: movementDistance)
            movementDuration = 0.3
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = newFrame
        UIView.commitAnimations()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.animateTextField(textField: chatTextField, up:true)
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionKeys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatViewController.comments(in: sortedChat, sectionKeys: sectionKeys, section: section)?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 25
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel(frame: CGRect(x: 20, y:1, width: tableView.frame.size.width, height: 23))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        label.font = ChatViewController.sectionHeaderFont()
        
        var sectionTitle = ChatViewController.sectionKey(sectionKeys, section: section) ?? ""
        if let comments = ChatViewController.comments(in: sortedChat, sectionKeys: sectionKeys, section: section), comments.count > 0 {
            let lastDate = comments[0].object(forKey: "date") as? String
            let relative = CommonUtils.sharedInstance.relativeDateLabel(fromISO: lastDate, numericDates: true)
            if !relative.isEmpty {
                sectionTitle = relative
            }
        }
        label.text = sectionTitle
        label.textAlignment = .center
        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        if let data = ChatViewController.comment(
            in: sortedChat,
            sectionKeys: sectionKeys,
            section: indexPath.section,
            row: indexPath.row
        ) {
            
            let h = ChatViewController.messageRowHeight(
                width: cell.messageText.frame.width,
                font: cell.messageText.font,
                message: data.object(forKey: "message")
            )
            return h
        }
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        if let data = ChatViewController.comment(
            in: sortedChat,
            sectionKeys: sectionKeys,
            section: indexPath.section,
            row: indexPath.row
        ) {
            
            cell.userNameLabel.text = NSLocalizedString("You", comment: "")
            let message = data.object(forKey: "message") as? String ?? ""
            cell.messageText.text = message
            let user_id = ChatMessageOwnershipPolicy.authorId(data.object(forKey: "user_id"))
            if ChatMessageOwnershipPolicy.isOwnMessage(authorId: user_id, viewerId: HulaUser.sharedInstance.userId) {
                // my message
                cell.userNameLabel.text = HulaUser.sharedInstance.userNick
                cell.userNameLabel.textAlignment = .left
                cell.messageText.textAlignment = .left
                cell.mainHolder.backgroundColor = HulaConstants.appMainColor
                cell.messageText.textColor = UIColor.white
                cell.leftUserImage.isHidden = false
                cell.rightUserImage.isHidden = true
                cell.leftUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: user_id))
                cell.mainHolder.frame.origin.x = 121
                //print(user_id)
                //print("+++++ my message")
                //print("+++++ pos: \(cell.mainHolder.frame.origin.x)")
            } else {
                // other's message
                cell.mainHolder.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                cell.userNameLabel.textAlignment = .right
                cell.messageText.textAlignment = .right
                cell.messageText.textColor = UIColor.darkGray
                cell.leftUserImage.isHidden = true
                cell.rightUserImage.isHidden = false
                cell.rightUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: user_id))
                
                
                cell.mainHolder.frame.origin.x = 182
                //print("+++++ others message")
                
            }
        }
        return cell
    }
}

/// Chat poll decision. `replacesChat` is true only for an ok dictionary
/// array after a real request URL. The returned `chat` is that array, or
/// the seed when the response does not apply. `updatesData` follows the
/// replace. This step does not filter dates, clear the composer, or unwrap
/// JSON.
struct ChatRefreshReplacement {
    let tradeId: String
    let requestsChat: Bool
    let requestURL: String?
    let replacesChat: Bool
    let chat: [NSDictionary]
    let updatesData: Bool
    let filtersDates: Bool
    let clearsTextField: Bool
    let unwrapsJSON: Bool
}

/// Send decision. `posts` requires a validated message and a real chat URL.
/// `clearsTextField` and `refreshesChat` are true only for an ok dictionary
/// after that post. The returned `keptDraft` is empty when the composer
/// clears, otherwise the original draft, including surrounding spaces.
/// This step does not replace the chat array, filter dates, or unwrap JSON.
struct ChatSendClear {
    let tradeId: String
    let draft: String
    let message: String?
    let showsLengthAlert: Bool
    let posts: Bool
    let requestURL: String?
    let postString: String?
    let clearsTextField: Bool
    let refreshesChat: Bool
    let keptDraft: String
    let replacesChat: Bool
    let filtersDates: Bool
    let unwrapsJSON: Bool
}

/// Trade reload after a chat POST. `reloadsTrades` is true only when the
/// send posts, including when `clearsTextField` is false. This step does
/// not dismiss the chat, refresh the thread, replace the polled array,
/// filter dates, or unwrap JSON.
struct ChatSendTradeReload {
    let tradeId: String
    let draft: String
    let showsLengthAlert: Bool
    let posts: Bool
    let requestURL: String?
    let clearsTextField: Bool
    let reloadsTrades: Bool
    let keptDraft: String
    let dismissesChat: Bool
    let refreshesChat: Bool
    let replacesChat: Bool
    let filtersDates: Bool
    let unwrapsJSON: Bool
}

/// Close button. `reloadsTrades` and `dismissesChat` are both true with no
/// post, dictionary, or length check. `waitsForReload` and
/// `requiresReloadSuccess` stay false: dismiss is scheduled outside the
/// `getTrades` callback. This step does not clear the composer, post,
/// refresh the thread, replace the polled array, filter dates, or unwrap
/// JSON. `requestURL` and `postString` stay nil.
struct ChatCloseDismiss {
    let tradeId: String
    let draft: String
    let showsLengthAlert: Bool
    let posts: Bool
    let requestURL: String?
    let postString: String?
    let clearsTextField: Bool
    let reloadsTrades: Bool
    let keptDraft: String
    let dismissesChat: Bool
    let waitsForReload: Bool
    let requiresReloadSuccess: Bool
    let refreshesChat: Bool
    let replacesChat: Bool
    let filtersDates: Bool
    let unwrapsJSON: Bool
}

/// Chat rows compared `user_id == userId`. A nil viewer id force-unwrapped on
/// every visible message. Missing and non-string authors stay "" so they still
/// match an empty viewer id. A nil viewer matches nobody, including "".
/// Do not trim.
struct ChatMessageOwnershipPolicy {
    static func authorId(_ authorValue: Any?) -> String {
        return authorValue as? String ?? ""
    }

    static func isOwnMessage(authorId: String?, viewerId: String?) -> Bool {
        return TradeTurnPolicy.idsMatch(authorId, viewerId)
    }
}
