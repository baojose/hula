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
    
    
    var spinner: HLSpinnerUIView!

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
        let alert = UIAlertController(title: "Delete product", message: "Are you sure you want to delete this product?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {UIAlertAction in
            //print("Deleting product")
            if let prodId = self.productToDisplay.object(forKey: "_id") as? String{
                self.spinner = HLSpinnerUIView()
                self.view.addSubview(self.spinner)
                self.spinner.show(inView: self.view)
                
                
                let queryURL = HulaConstants.apiURL + "products/" + prodId + "/delete"
                //print(queryURL)
                HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                    //print(json)
                    if (ok){
                        self.spinner.hide()
                        DispatchQueue.main.async {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
            
        }))
        self.present(alert, animated: true, completion: {})
        
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
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "productTextEditor") as! HLProductEditTextViewController
            editViewController.originalText = previous
            editViewController.label = label
            editViewController.item = item_toUpdate
            editViewController.pageTitle = title
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}
