//
//  HLProductDetailViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductDetailViewController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var productMainDetailView: UIView!
    @IBOutlet var sellerView: UIView!
    @IBOutlet var productTableView: UITableView!
    @IBOutlet var addToTradeBtn: UIButton!
    
    @IBOutlet var productsScrollView: UIScrollView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productDescriptionLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var sellerImageView: UIImageView!
    @IBOutlet var sellerNameLabel: UILabel!
    @IBOutlet var sellerFeedbackLabel: UILabel!
    @IBOutlet var sellerVerifiedMethodsView: UIView!

    @IBOutlet var sellerLabel: UILabel!
    @IBOutlet var userInventoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initData() {
        
    }
    func initView() {
        var newFrame: CGRect! = productTableView.frame
        newFrame.size.height = 10 * 129;
        productTableView.frame = newFrame
        mainScrollView.contentSize = CGSize(width: 0, height: productTableView.frame.origin.y + productTableView.frame.size.height)
        self.setUpProductImagesScrollView()
        commonUtils.setRoundedRectBorderButton(addToTradeBtn, 1.0, UIColor.white, addToTradeBtn.frame.size.height / 2.0)
        commonUtils.circleImageView(sellerImageView)
        sellerLabel.attributedText = commonUtils.attributedStringWithTextSpacing("SELLER", 2.33)
        userInventoryLabel.attributedText = commonUtils.attributedStringWithTextSpacing("USER'S INVENTORY", 2.33)
    }
    
    func setUpProductImagesScrollView() {
        for i in 0 ..< 5 {
            let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
            let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
            imgView.image = UIImage(named: "temp_product")
            productsScrollView.addSubview(imgView)
        }
        productsScrollView.contentSize = CGSize(width: 5 * productsScrollView.frame.size.width, height: 0.0)
        productsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeProductCell") as! HLProductTableViewCell
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if (scrollView == productsScrollView) {
            let xPos = productsScrollView.contentOffset.x / productsScrollView.frame.size.width
            pageControl.currentPage = Int(xPos)
        }
    }
}
