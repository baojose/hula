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
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainImageLabel: UILabel!
    
    @IBOutlet var productTitleTxtField: UITextField!
    @IBOutlet var publishBtn: HLRoundedNextButton!
    @IBOutlet weak var cameraButton1: UIButton!
    @IBOutlet weak var cameraButton2: UIButton!
    @IBOutlet weak var cameraButton3: UIButton!
    @IBOutlet weak var cameraButton4: UIButton!
    @IBOutlet weak var imgFrameView1: UIView!
    @IBOutlet weak var imgFrameView2: UIView!
    @IBOutlet weak var imgFrameView3: UIView!
    @IBOutlet weak var imgFrameView4: UIView!
    
    var arrImageViews: NSMutableArray!
    var arrImageFrameViews: NSMutableArray!
    
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
        
        
        arrImageFrameViews = NSMutableArray.init(capacity: 4)
        arrImageFrameViews.add(imgFrameView1)
        arrImageFrameViews.add(imgFrameView2)
        arrImageFrameViews.add(imgFrameView3)
        arrImageFrameViews.add(imgFrameView4)
        
        let arrCameraButtons = NSMutableArray.init(capacity: 4)
        arrCameraButtons.add(cameraButton1)
        arrCameraButtons.add(cameraButton2)
        arrCameraButtons.add(cameraButton3)
        arrCameraButtons.add(cameraButton4)
        
        if dataManager.newProduct.arrProductPhotos.count > 0 {
            for i in 0 ..< dataManager.newProduct.arrProductPhotos.count{
                let imgView: UIImageView! = arrImageViews.object(at: i) as! UIImageView
                let buttonView: UIButton! = arrCameraButtons.object(at: i) as! UIButton
                let frameView: UIView! = arrImageFrameViews.object(at: i) as! UIView
                frameView.isUserInteractionEnabled = true
                let recognizer = UITapGestureRecognizer()
                recognizer.addTarget(self, action: #selector(HLPostProductViewController.selectedImageTapped))
                frameView.addGestureRecognizer(recognizer)
                if (i == 0){
                    frameView.backgroundColor = HulaConstants.appMainColor
                } else {
                    frameView.backgroundColor = .white
                }
                if let selectedImage = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage {
                    imgView.image = selectedImage
                    buttonView.isHidden = true;
                } else {
                    buttonView.isHidden = false;
                }
            }
        }
    }
    func initView(){
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        commonUtils.setRoundedRectBorderImageView(mainImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(secondImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(thirdImage, 1.0, UIColor.lightGray, 0.0)
        commonUtils.setRoundedRectBorderImageView(forthImage, 1.0, UIColor.lightGray, 0.0)
        
        //publishBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_enabled"), for: UIControlState.normal)
        //publishBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_disabled"), for: UIControlState.disabled)
        //publishBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        //publishBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        productTitleTxtField.addTarget(self, action: #selector(textchange(_:)), for: UIControlEvents.editingChanged)
        publishBtn.setup()
        self.changePublishBtnState("")
        let tapGesture: UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: #selector(onTapScreen))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func selectedImageTapped(_ sender: UITapGestureRecognizer){
        //print("Touches began")
        for i in 0 ..< 4{
            let imgView: UIView! = arrImageFrameViews.object(at: i) as! UIView
            UIView.animate(withDuration: 0.2, animations: {
                imgView.backgroundColor = .white
            })
        }
        UIView.animate(withDuration: 0.5, animations: {
            sender.view?.backgroundColor = HulaConstants.appMainColor
            self.mainImageLabel.center.x = (sender.view?.center.x)!
        })
        let tappedIndex: Int = (sender.view?.tag)!
        if (tappedIndex != 0){
            print(tappedIndex)
            swap(&dataManager.newProduct.arrProductPhotos[0], &dataManager.newProduct.arrProductPhotos[tappedIndex])
        }
    }
    func reDesignView(){
        
    }
    func changePublishBtnState(_ string: String){
        if dataManager.newProduct.arrProductPhotos.count != 0 && string.characters.count != 0  {
            publishBtn.isEnabled = true
            publishBtn.startAnimation()
        }else{
            publishBtn.isEnabled = false
            publishBtn.stopAnimation()
        }
    }
    func onTapScreen(){
        productTitleTxtField.resignFirstResponder()
        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    @IBAction func cameraButtonTap(_ sender: Any) {
        print((sender as AnyObject).tag)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //#MARK - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 195.0), animated: true)
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
