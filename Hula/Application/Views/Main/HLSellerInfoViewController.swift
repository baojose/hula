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
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    @IBOutlet weak var sellerFeedbackLabel: UILabel!
    
    
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
    }
    func initView(){
        commonUtils.circleImageView(profileImage)
        lblOtherItemInStock.attributedText = commonUtils.attributedStringWithTextSpacing("OTHER ITEMS IN STOCK", 2.33)
        var newFrame: CGRect! = sellerProductTableView.frame
        newFrame.size.height = 10 * 129;
        sellerProductTableView.frame = newFrame
        mainScrollView.contentSize = CGSize(width: 0, height: sellerProductTableView.frame.origin.y + sellerProductTableView.frame.size.height)
        
        profileImage.loadImageFromURL(urlString: user.userPhotoURL)
        sellerNameLabel.text = user.userNick
        sellerLocationLabel.text = user.userLocationName
        
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
}
