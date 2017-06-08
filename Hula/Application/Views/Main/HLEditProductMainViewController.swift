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
            //commonUtils.loadImageOnView(imageView: productImage, withURL: (mainProductImage))
            
            productImage.loadImageFromURL(urlString: mainProductImage)
        }
        productTitle.text = productToDisplay.object(forKey: "title") as? String
        productTitleLabel.text = productToDisplay.object(forKey: "title") as? String
        numPicturesLabel.text = "1"
        productConditionLabel.text = productToDisplay.object(forKey: "condition") as? String
        productDescriptionLabel.text = productToDisplay.object(forKey: "description") as? String
    }
    @IBAction func deleteProductAction(_ sender: Any) {
    }
    @IBAction func editItemAction(_ sender: Any) {
        //let userData = HulaUser.sharedInstance
        print((sender as! UIButton).tag)
        var title = "";
        var previous = "";
        var label = ""
        var item_toUpdate = "";
        switch (sender as! UIButton).tag {
        case 0:
            // image update
            let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectPictureGeneral") as! HLPictureSelectViewController
            self.present(cameraViewController, animated: true)
            
        case 10:
            // Title
            title = "Choose a title for your product"
            previous = productTitle.text!
            label = "Title"
            item_toUpdate = "title"
        case 20:
            // Category
            title = "Select a category"
            previous = categoryNameLabel.text!
            label = "Category"
            item_toUpdate = "category"
        case 30:
            // Condition
            title = "Change your product condition"
            previous = productConditionLabel.text!
            label = "Condition"
            item_toUpdate = "condition"
        case 40:
            // Description
            title = "Change description"
            previous = productDescriptionLabel.text!
            label = "Description"
            item_toUpdate = "description"
        default:
            // nada
            break
        }
        if ((sender as! UIButton).tag != 0 ){
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "fieldEditor") as! HLEditFieldViewController
            editViewController.field_label = label
            editViewController.field_title = title
            editViewController.field_previous_val = previous
            editViewController.field_key = item_toUpdate
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}
