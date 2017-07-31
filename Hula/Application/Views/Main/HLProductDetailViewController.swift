//
//  HLProductDetailViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MapKit

class HLProductDetailViewController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var productMainDetailView: UIView!
    @IBOutlet var sellerView: UIView!
    @IBOutlet var productTableView: UITableView!
    @IBOutlet var addToTradeBtn: UIButton!
    @IBOutlet weak var addToTradeBg: UIImageView!
    @IBOutlet weak var productDistance: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    @IBOutlet weak var screenTitle: UILabel!
    
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
    
    var productData: NSDictionary!
    var currentProduct: HulaProduct!
    var sellerProducts: NSArray! = []
    var sellerFeedback: NSArray! = []
    var sellerUser: HulaUser!
    
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
        //print(productData);
        //print(productData);
        sellerUser = HulaUser()
        if (currentProduct != nil) && (currentProduct.productId.characters.count > 0) && (productData == nil) {
            // product does already exist!
        } else {
            currentProduct = HulaProduct(
                id: productData["_id"] as! String,
                name: productData["title"] as! String,
                image: productData["image_url"] as! String)
        
            currentProduct.productDescription = productData["description"] as! String
            currentProduct.productOwner = productData["owner_id"] as! String
            if let catName = productData["category_name"] as? String{
                currentProduct.productCategory = catName
            }
            if let catId = productData["category_id"] as? String {
                currentProduct.productCategoryId = catId
            }
            currentProduct.productCondition = productData["condition"] as! String
            if let loc_tmp = productData["location"] as? [Double] {
                currentProduct.productLocation = CLLocation(latitude: loc_tmp[0], longitude: loc_tmp[1])
            }
            var num_images = 0;
            if let img_arr = productData["images"] as? NSArray {
                currentProduct.arrProductPhotoLink = []
                for i in 0 ..< img_arr.count {
                    if let img_url = img_arr[i] as? String{
                        if (img_url.characters.count > 0){
                            currentProduct.arrProductPhotoLink.append(img_url)
                            num_images += 1
                        }
                    }
                }
            }
        }
    }
    func initView() {
        var newFrame: CGRect! = productTableView.frame
        newFrame.size.height = CGFloat(sellerProducts.count) * 129.0;
        productTableView.frame = newFrame
        
        // product details
        productNameLabel.text = currentProduct.productName
        productDescriptionLabel.text = currentProduct.productDescription
        productCategory.text = currentProduct.productCategory
        productCondition.text = currentProduct.productCondition
        productDistance.text = commonUtils.getDistanceFrom(loc: currentProduct.productLocation)
        
        // item height and position reset
        let h = commonUtils.heightString(width: productDescriptionLabel.frame.width, font: productDescriptionLabel.font! , string: productDescriptionLabel.text!) + 30
        productDescriptionLabel.frame.size = CGSize(width: productDescriptionLabel.frame.size.width, height: h)
        sellerView.frame.origin.y = productDescriptionLabel.frame.origin.y + productDescriptionLabel.frame.size.height
        mainScrollView.contentSize = CGSize(width: 0, height: sellerView.frame.origin.y + productTableView.frame.size.height + 300)
        
        // seta product images
        self.setUpProductImagesScrollView()
        
        // product owner image
        sellerLabel.attributedText = commonUtils.attributedStringWithTextSpacing("SELLER", 2.33)
        commonUtils.circleImageView(sellerImageView)
        sellerImageView.loadImageFromURL(urlString: HulaConstants.apiURL + "users/" + currentProduct.productOwner + "/image")
        
        
        // user inventory
        userInventoryLabel.attributedText = commonUtils.attributedStringWithTextSpacing("USER'S INVENTORY", 2.33)
        
        
        // start bartering item button
        commonUtils.setRoundedRectBorderButton(addToTradeBtn, 1.0, UIColor.white, addToTradeBtn.frame.size.height / 2.0)
        
        HLDataManager.sharedInstance.getUserProfile(userId: currentProduct.productOwner, taskCallback: {(user, prods) in
            self.sellerUser = user
            self.sellerNameLabel.text = user.userNick;
            self.sellerFeedbackLabel.text = user.userLocationName;
            self.sellerProducts = prods
            var newFrame: CGRect! = self.productTableView.frame
            newFrame.size.height = (CGFloat(self.sellerProducts.count) * 129.0);
            print(newFrame.size.height)
            self.productTableView.frame = newFrame
            self.mainScrollView.contentSize = CGSize(width: 0, height: self.sellerView.frame.origin.y + self.productTableView.frame.size.height + 300)
            self.productTableView.reloadData()
        })
        
        // button visible only on other users
        if (currentProduct.productOwner == HulaUser.sharedInstance.userId){
            // this is my own product, so i cannot swapp it with me
            addToTradeBtn.isHidden = true
            addToTradeBg.isHidden = true
        } else {
            addToTradeBtn.isHidden = false
            addToTradeBg.isHidden = false
        }
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sellerProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeProductCell") as! HLProductTableViewCell
        
        if let pr = sellerProducts[indexPath.row] as? [String:Any] as NSDictionary?{
        
            cell.productName.text = pr.object(forKey: "title") as? String
            
            if let im_ur = pr.object(forKey: "image_url") as? String {
                cell.productImage.loadImageFromURL(urlString:im_ur)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("selected")
        print(indexPath.row)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        
        let product = sellerProducts[indexPath.row] as! NSDictionary
        viewController.productData = product
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if (scrollView == productsScrollView) {
            let xPos = productsScrollView.contentOffset.x / productsScrollView.frame.size.width
            pageControl.currentPage = Int(xPos)
        }
    }
    
    
    
    // Custom functions for ViewController
    
    
    func setUpProductImagesScrollView() {
        var num_images: CGFloat = 0;
        /*
        if let img_arr = productData["images"] as? NSArray {
            
            for i in 0 ..< 4 {
                if let img_url = img_arr[i] as? String{
                    if (img_url.characters.count > 0){
                        let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
                        let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
                        //commonUtils.loadImageOnView(imageView: imgView, withURL: img_url)
                        imgView.loadImageFromURL(urlString: img_url)
                        //imgView.image = UIImage(named: "temp_product")
                        imgView.contentMode = .scaleAspectFill
                        productsScrollView.addSubview(imgView)
                        num_images += 1
                    }
                }
            }
        }
        */
        for i in 0 ..< currentProduct.arrProductPhotoLink.count {
            let img_url = currentProduct.arrProductPhotoLink[i]
            if (img_url.characters.count > 0){
                let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
                let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
                //commonUtils.loadImageOnView(imageView: imgView, withURL: img_url)
                imgView.loadImageFromURL(urlString: img_url)
                //imgView.image = UIImage(named: "temp_product")
                imgView.contentMode = .scaleAspectFill
                productsScrollView.addSubview(imgView)
                num_images += 1
            }
        }
        
        productsScrollView.contentSize = CGSize(width: num_images * productsScrollView.frame.size.width, height: 0.0)
        pageControl.numberOfPages = Int(num_images)
        pageControl.currentPage = 0
        productsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    func insertIfAvailable(label: UILabel, maybeText: Any){
        if let tx = maybeText as? String {
            label.text = tx
        }
    }
    
    @IBAction func gotoUserPage(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sellerInfoPage") as! HLSellerInfoViewController
        
        viewController.user = self.sellerUser
        viewController.userProducts = self.sellerProducts
        viewController.userFeedback = self.sellerFeedback
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addToTradeAction(_ sender: Any) {
        if let productId = productData["_id"] as? String{
            print(productId)
            let otherId = productData["owner_id"] as? String
            if (HulaUser.sharedInstance.userId.characters.count>0){
                // user is loggedin
                let queryURL = HulaConstants.apiURL + "trades/"
                let dataString:String = "product_id=\(productId)&other_id=\(otherId!)"
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
