//
//  HLSellerInfoViewController.swift
//  Hula
//
//  Created by Star on 3/17/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSellerInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var lblOtherItemInStock: UILabel!
    @IBOutlet var sellerProductTableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    @IBOutlet weak var sellerFeedbackLabel: UILabel!
    
    @IBOutlet weak var tradeWithUserButton: UIButton!
    
    @IBOutlet weak var fbIcon: UIImageView!
    @IBOutlet weak var liIcon: UIImageView!
    @IBOutlet weak var twIcon: UIImageView!
    @IBOutlet weak var emIcon: UIImageView!
    
    @IBOutlet weak var addToTradeViewContainer: UIImageView!
    
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    
    
    var user = HulaUser();
    var userProducts: NSArray = []
    var userFeedback: NSArray = []
    var initialTradeFrame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
        self.initialTradeFrame = self.addToTradeViewContainer.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addToTradeViewContainer.frame = self.initialTradeFrame
    }
    func initData(){
        
        let thumb = CommonUtils.sharedInstance.getThumbFor(url: user.userPhotoURL)
        profileImage.loadImageFromURL(urlString: thumb)
        sellerNameLabel.text = user.userNick
        sellerLocationLabel.text = user.userLocationName
        tradeWithUserButton.layer.cornerRadius = 19
        tradeWithUserButton.layer.borderColor = UIColor.white.cgColor
        tradeWithUserButton.layer.borderWidth = 1.0
        
        if (user.twToken.characters.count>1){
            twIcon.image = UIImage(named: "icon_twitter_on")
        }
        if (user.fbToken.characters.count>1){
            fbIcon.image = UIImage(named: "icon_facebook_on")
        }
        if (user.liToken.characters.count>1){
            liIcon.image = UIImage(named: "icon_linkedin_on")
        }
        if (user.status == "verified"){
            emIcon.image = UIImage(named: "icon_mail_on")
        }
        
        sellerFeedbackLabel.text = user.getFeedback()
    }
    func initView(){
        commonUtils.circleImageView(profileImage)
        
        lblOtherItemInStock.attributedText = commonUtils.attributedStringWithTextSpacing("OTHER ITEMS IN STOCK", 2.33)
        
        var newFrame: CGRect! = sellerProductTableView.frame
        newFrame.size.height = CGFloat(userProducts.count) * 129 + 200;
        sellerProductTableView.frame = newFrame
        let totalHeight = sellerProductTableView.frame.origin.y + sellerProductTableView.frame.size.height
        mainScrollView.contentSize = CGSize(width: 0, height: totalHeight)
        
        containerView.frame.size.height = totalHeight
        
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellerProductCell") as! HLProductTableViewCell
        if let pr = userProducts[indexPath.row] as? [String:Any] as NSDictionary?{
            
            cell.productName.text = pr.object(forKey: "title") as? String
            
            if let im_ur = pr.object(forKey: "image_url") as? String {
                cell.productImage.loadImageFromURL(urlString:im_ur)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        
        if let product = userProducts[indexPath.row] as? [String:Any] as NSDictionary?{
            let hproduct = HulaProduct();
            hproduct.populate(with: product)
            viewController.productData = hproduct
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func addToTradeAction(_ sender: Any) {
        //print(productId)
        if (HulaUser.sharedInstance.numProducts == 0){
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            
            viewController.isCancelVisible = false
            viewController.message = "Go to your stock section to upload something you don't need so you can start trading."
            self.present(viewController, animated: true)
            
        } else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            viewController.isCancelVisible = true
            viewController.okButtonText = "Accept"
            viewController.delegate = self
            viewController.message = "You're about to start a trade. One room will be reserved for this negotiation until it's finished."
            self.present(viewController, animated: true)
            
        }
    }
}

extension HLSellerInfoViewController: AlertDelegate{
    func alertResponded(response: String, trigger: String) {
        if response == "ok" {
            let otherId = user.userId
            if(HulaUser.sharedInstance.userId != otherId){
                if (HulaUser.sharedInstance.userId.characters.count>0){
                    // user is loggedin
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.addToTradeViewContainer.frame = self.view.frame
                        })
                    }
                    
                    let queryURL = HulaConstants.apiURL + "trades/"
                    let dataString:String = "product_id=&other_id=\(otherId!)"
                    HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                        if (ok){
                            // show barter screen
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let myModalViewController = storyboard.instantiateViewController(withIdentifier: "swappView")
                                myModalViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                                myModalViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.present(myModalViewController, animated: true, completion: nil)
                            }
                        } else {
                            // connection error
                            print("Connection error")
                        }
                    })
                }
            }
        }
    }
}
