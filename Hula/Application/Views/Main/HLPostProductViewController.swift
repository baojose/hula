//
//  HLPostProductViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLPostProductViewController: BaseViewController, UITextFieldDelegate {

    
    
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var secondImage: UIImageView!
    @IBOutlet var thirdImage: UIImageView!
    @IBOutlet var forthImage: UIImageView!
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var productTitleTxtField: UITextField!
    @IBOutlet var publishBtn: UIButton!
    
    var arrImageViews: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initData(){
        arrImageViews = NSMutableArray.init(capacity: 4)
        arrImageViews.add(mainImage)
        arrImageViews.add(secondImage)
        arrImageViews.add(thirdImage)
        arrImageViews.add(forthImage)
        
        if dataManager.newProduct.arrProductPhotos.count > 0 {
            for i in 0 ..< dataManager.newProduct.arrProductPhotos.count{
                let imgView: UIImageView! = arrImageViews.object(at: i) as! UIImageView
                imgView.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
            }
        }
    }
    func initView(){
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        commonUtils.setRoundedRectBorderImageView(mainImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(secondImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(thirdImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(forthImage, 1.0, UIColor.lightGray, 0.0)
        
        publishBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_enabled"), for: UIControlState.normal)
        publishBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_disabled"), for: UIControlState.disabled)
        publishBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        publishBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        productTitleTxtField.addTarget(self, action: #selector(textchange(_:)), for: UIControlEvents.editingChanged)
        self.changePublishBtnState("")
        let tapGesture: UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: #selector(onTapScreen))
        self.view.addGestureRecognizer(tapGesture)
    }
    func reDesignView(){
        
    }
    func changePublishBtnState(_ string: String){
        if dataManager.newProduct.arrProductPhotos.count != 0 && string.characters.count != 0  {
            publishBtn.isEnabled = true
        }else{
            publishBtn.isEnabled = false
        }
    }
    func onTapScreen(){
        productTitleTxtField.resignFirstResponder()
        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    //#MARK - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 60.0), animated: true)
        return true
    }
    func textchange(_ textField:UITextField) {
        self.changePublishBtnState(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        return textField.resignFirstResponder()
    }
    @IBAction func dismissToProductPage(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func publishNewProduct(_ sender: Any) {
        if productTitleTxtField.text?.characters.count != 0 {
            dataManager.newProduct.productName = productTitleTxtField.text
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
