//
//  HLEditProductMainViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLEditProductMainViewController: BaseViewController, ProductPictureDelegate {
    
    var productToDisplay:NSDictionary = [:]
    var product = HulaProduct()
    @IBOutlet var mainScrollVIew: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var numPicturesLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var productConditionLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var prodImg1: UIImageView!
    @IBOutlet weak var prodImg2: UIImageView!
    @IBOutlet weak var prodImg3: UIImageView!
    @IBOutlet weak var prodImg4: UIImageView!
    
    var spinner: HLSpinnerUIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData() {
        product.populate(with: productToDisplay)
    }
    func initView() {
        mainScrollVIew.contentSize = contentView.frame.size
        //print(productToDisplay);
        productImage.loadImageFromURL(urlString: product.productImage)
        productTitle.text = product.productName
        productTitleLabel.text = product.productName
        categoryNameLabel.text = product.productCategory
        numPicturesLabel.text = "\(product.arrProductPhotoLink.count)"
        productConditionLabel.text = product.productCondition
        productDescriptionLabel.text = product.productDescription
        redrawProductImages()
    }
    @IBAction func deleteProductAction(_ sender: Any) {
        let alert = UIAlertController(title: "Delete product", message: "Are you sure you want to delete this product?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {UIAlertAction in
            //print("Deleting product")
            self.spinner = HLSpinnerUIView()
            self.view.addSubview(self.spinner)
            self.spinner.show(inView: self.view)
            
            
            let queryURL = HulaConstants.apiURL + "products/" + self.product.productId + "/delete"
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
            
        }))
        self.present(alert, animated: true, completion: {})
        
    }
    
    @IBAction func changeImageAction(_ sender: Any) {
        
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "productPictureEdit") as! HLProductPictureEditViewController
        cameraViewController.positionToReplace = (sender as! UIButton).tag
        cameraViewController.prodDelegate = self
        self.present(cameraViewController, animated: true)
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
            break
            
        case 10:
            // Title
            title = "Choose a title for your product"
            previous = product.productName
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
            previous = product.productDescription
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
            editViewController.product = self.product
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
    
    func redrawProductImages(){
        
        prodImg1.image = nil
        prodImg2.image = nil
        prodImg3.image = nil
        prodImg4.image = UIImage(named: "icon_camera_small")
        prodImg4.contentMode = .center
        
        if product.arrProductPhotoLink.count > 0 && product.arrProductPhotoLink[0].characters.count > 0 {
            prodImg1.loadImageFromURL(urlString: product.arrProductPhotoLink[0])
        }
        if product.arrProductPhotoLink.count > 1 && product.arrProductPhotoLink[1].characters.count > 0 {
            prodImg2.loadImageFromURL(urlString: product.arrProductPhotoLink[1])
        }
        if product.arrProductPhotoLink.count > 2 && product.arrProductPhotoLink[2].characters.count > 0 {
            prodImg3.loadImageFromURL(urlString: product.arrProductPhotoLink[2])
        }
        if product.arrProductPhotoLink.count > 3 && product.arrProductPhotoLink[3].characters.count > 0 {
            prodImg4.loadImageFromURL(urlString: product.arrProductPhotoLink[3])
            prodImg4.contentMode = .scaleAspectFill
        }
    }
    
    func imageUploaded(path: String, pos: Int){
        if (product.arrProductPhotoLink.count < pos ){
            product.arrProductPhotoLink.append(path)
        } else {
            product.arrProductPhotoLink[ pos - 1 ] = path
        }
        if (pos == 1){
            product.productImage = path
            self.productImage.loadImageFromURL(urlString: path)
        }
        redrawProductImages()
        product.updateServerData()
    }
}
