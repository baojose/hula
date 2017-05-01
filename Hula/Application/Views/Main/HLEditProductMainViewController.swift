//
//  HLEditProductMainViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLEditProductMainViewController: BaseViewController {
    
    var productToDisplay:NSDictionary = [:]
    @IBOutlet var mainScrollVIew: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var numPicturesLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var productConditionLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData() {
        
    }
    func initView() {
        mainScrollVIew.contentSize = contentView.frame.size
        print(productToDisplay);
        if let mainProductImage = productToDisplay.object(forKey: "image_url") as? String {
            commonUtils.loadImageOnView(imageView: productImage, withURL: (mainProductImage))
        }
        productTitle.text = productToDisplay.object(forKey: "title") as? String
        productTitleLabel.text = productToDisplay.object(forKey: "title") as? String
        numPicturesLabel.text = "1"
        productConditionLabel.text = productToDisplay.object(forKey: "condition") as? String
        productDescriptionLabel.text = productToDisplay.object(forKey: "description") as? String
    }
    @IBAction func deleteProductAction(_ sender: Any) {
    }
}
