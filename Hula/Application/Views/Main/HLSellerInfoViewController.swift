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
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellerProductCell") as! HLProductTableViewCell
        
        return cell
    }
}
