//
//  HLProductModalViewController.swift
//  Hula
//
//  Created by Juan Searle on 31/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductModalViewController: UIViewController {

    var product: HulaProduct!
    
    @IBOutlet weak var mainBoxView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet weak var productDistance: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    
    @IBOutlet var productsScrollView: UIScrollView!
    @IBOutlet var productDescriptionLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainBoxView.layer.cornerRadius = 4
        titleLabel.text = product.productName
        productDistance.text = CommonUtils.sharedInstance.getDistanceFrom(loc: product.productLocation)
        productCategory.text = product.productCategory
        productCondition.text = product.productCondition
        productDescriptionLabel.text = product.productDescription
        
        
        // item height and position reset
        let h = CommonUtils.sharedInstance.heightString(width: productDescriptionLabel.frame.width, font: productDescriptionLabel.font! , string: productDescriptionLabel.text!) + 30
        productDescriptionLabel.frame.size = CGSize(width: productDescriptionLabel.frame.size.width, height: h)
        
        
        mainScrollView.contentSize = CGSize(width: 0, height: productDescriptionLabel.frame.origin.y + productDescriptionLabel.frame.size.height + 100)
        // seta product images
        self.setUpProductImagesScrollView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeModalAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func setUpProductImagesScrollView() {
        var num_images: CGFloat = 0;
        for i in 0 ..< product.arrProductPhotoLink.count {
            let img_url = product.arrProductPhotoLink[i]
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
    
}
