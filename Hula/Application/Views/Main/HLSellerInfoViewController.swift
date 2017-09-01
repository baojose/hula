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
    
    
    @IBOutlet weak var fbIcon: UIImageView!
    @IBOutlet weak var liIcon: UIImageView!
    @IBOutlet weak var twIcon: UIImageView!
    @IBOutlet weak var emIcon: UIImageView!
    
    
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    
    
    var user = HulaUser();
    var userProducts: NSArray = []
    var userFeedback: NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        
        profileImage.loadImageFromURL(urlString: user.userPhotoURL)
        sellerNameLabel.text = user.userNick
        sellerLocationLabel.text = user.userLocationName
        
        if (user.twToken.characters.count>1){
            twIcon.image = UIImage(named: "icon_twitter_on")
        }
        if (user.status == "verified"){
            emIcon.image = UIImage(named: "icon_mail_on")
        }
        if (user.fbToken.characters.count>1){
            fbIcon.image = UIImage(named: "icon_facebook_on")
        }
        if (user.liToken.characters.count>1){
            liIcon.image = UIImage(named: "icon_linkedin_on")
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
}
