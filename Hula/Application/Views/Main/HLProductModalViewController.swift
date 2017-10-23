//
//  HLProductModalViewController.swift
//  Hula
//
//  Created by Juan Searle on 31/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MobileCoreServices

class HLProductModalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var product: HulaProduct!
    
    @IBOutlet weak var mainBoxView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet weak var productDistance: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    
    @IBOutlet weak var productDescriptionLabel: UITextView!
    @IBOutlet var productsScrollView: UIScrollView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var videoStatusImg: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var videoPath: NSURL? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainBoxView.layer.cornerRadius = 4
        titleLabel.text = product.productName
        productDistance.text = CommonUtils.sharedInstance.getDistanceFrom(loc: product.productLocation)
        productCategory.text = product.productCategory
        productCondition.text = product.productCondition
        productDescriptionLabel.text = product.productDescription
        
        if (product.video_requested){
            videoStatusImg.image = UIImage(named: "video-requested-red")
            videoBtn.setTitle(" Recording pending...", for: .normal)
            videoBtn.tag = 43904
        } else {
            videoStatusImg.image = nil
            videoBtn.tag = 1
        }
        
        
        // item height and position reset
        let h = CommonUtils.sharedInstance.heightString(width: productDescriptionLabel.frame.width, font: productDescriptionLabel.font! , string: productDescriptionLabel.text!) + 30
        productDescriptionLabel.frame.size = CGSize(width: productDescriptionLabel.frame.size.width, height: h)
        
        
        mainScrollView.contentSize = CGSize(width: 0, height: productDescriptionLabel.frame.origin.y + productDescriptionLabel.frame.size.height + 100)
        // seta product images
        self.setUpProductImagesScrollView()
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
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
    
    @IBAction func videoAction(_ sender: Any) {
        let tag = (sender as! UIButton).tag
        if (tag == 43904){
            recordVideo()
        } else {
            let queryURL = HulaConstants.apiURL + "products/\(product.productId!)/requestvideo"
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    if let _ = json as? [NSDictionary] {
                        
                        DispatchQueue.main.async {
                            let alert = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                            alert.delegate = self as AlertDelegate
                            alert.isCancelVisible = false
                            alert.message = "You have requested a video for this product. You will receive a notification when the user upload it."
                            alert.trigger = "video_request"
                            self.present(alert, animated: true)
                        }
                    } else {
                       print("Error connecting")
                    }
                }
            })
        }
    }
    
 func recordVideo() {
    if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [ kUTTypeMovie as String ]
            imagePicker.allowsEditing = false
            imagePicker.videoQuality = .typeMedium
            imagePicker.delegate = self
                
            present(imagePicker, animated: true, completion: {})
            } else {
                print("Rear camera doesn't exist. Application cannot access the camera.")
            }
        } else {
            print("Camera inaccessable. Application cannot access the camera.")
        }
    }

    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        print("Got a video")
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            // Save video to the main photo album
            //print(pickedVideo.relativePath)
            /*
            let selectorToCall = #selector(HLProductModalViewController.videoWasSavedSuccessfully)
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            
             */
            // Save the video to the app directory so we can play it later
            let videoData = NSData(contentsOf: pickedVideo as URL)
            
            
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory = paths[0] as! NSString
            let path = documentsDirectory.appendingPathComponent("testvideo.mov")
            videoPath = NSURL(string: path )
            videoData?.write(toFile: path, atomically: false)
            //self.dismiss(animated: true, completion: nil)
            
            
            HLDataManager.sharedInstance.uploadVideo(path, productId: product.productId, taskCallback: { (success, json) in
                print(json)
            })
        }
        
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
            
            
        })
    }
    
    func videoWasSavedSuccessfully(_ data:Any){
        print(data)
        
    }
    
    func uploadMedia(){
        if videoPath == nil {
            return
        }
        
        
    }
}

extension HLProductModalViewController: AlertDelegate{
    
    func alertResponded(response: String, trigger: String) {
        
    }

}
