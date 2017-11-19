//
//  HLProductModalViewController.swift
//  Hula
//
//  Created by Juan Searle on 31/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import BRYXBanner

class HLProductModalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

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
    @IBOutlet weak var videoBtnHolder: UIView!
    
    let imagePicker = UIImagePickerController()
    var videoPath: NSURL? = nil
    var image_dismissing : Bool = false
    var hideVideoBtn: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainBoxView.layer.cornerRadius = 4
        titleLabel.text = product.productName
        productDistance.text = CommonUtils.sharedInstance.getDistanceFrom(loc: product.productLocation)
        productCategory.text = product.productCategory
        productCondition.text = product.productCondition
        if product.productDescription.count > 0 {
            productDescriptionLabel.text = product.productDescription
        } else {
            productDescriptionLabel.text = "No product description provided."
        }
        mainScrollView.clipsToBounds = true
        self.setupVideoButtons()
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if productsScrollView == scrollView {
            let page: Int = Int(round(productsScrollView.contentOffset.x / productsScrollView.frame.width))
            pageControl.currentPage = page
        }
    }
    
    func setUpProductImagesScrollView() {
        var num_images: CGFloat = 0;
        for i in 0 ..< product.arrProductPhotoLink.count {
            let img_url = product.arrProductPhotoLink[i]
            if (img_url.count > 0){
                let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
                let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
                //commonUtils.loadImageOnView(imageView: imgView, withURL: img_url)
                imgView.loadImageFromURL(urlString: img_url)
                //imgView.image = UIImage(named: "temp_product")
                imgView.contentMode = .scaleAspectFill
                imgView.tag = i + 1000
                
                productsScrollView.addSubview(imgView)
                num_images += 1
            }
        }
        
        productsScrollView.contentSize = CGSize(width: num_images * productsScrollView.frame.size.width, height: 0.0)
        pageControl.numberOfPages = Int(num_images)
        pageControl.currentPage = 0
        productsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    func setupVideoButtons(){
        
        if !hideVideoBtn {
            videoBtnHolder.isHidden = false
            if (product.productOwner != HulaUser.sharedInstance.userId){
                // not my product
                if (product.video_requested || product.video_url.count  > 0){
                    // video has been requested
                    if (product.video_url.count > 0){
                        // video was requested and is available
                        videoStatusImg.image = UIImage(named: "video-player-icon-red")
                        videoBtn.setTitle(" Play video", for: .normal)
                        videoBtn.setImage(UIImage(named: "video-player-icon-red"), for: .normal)
                        videoBtn.tag = 43909
                    } else {
                        // video is still pending recod
                        videoStatusImg.image = UIImage(named: "video-requested-red")
                        videoBtn.setTitle(" Waiting for video proof...", for: .normal)
                        videoBtn.tag = -43904
                    }
                } else {
                    // video has not been requested
                    videoBtn.setTitle(" Request video proof", for: .normal)
                    videoStatusImg.image = nil
                    videoBtn.tag = 1
                }
            } else {
                // it is my product
                if (product.video_url.count > 0){
                    // I've already recorded a video
                    videoStatusImg.image = UIImage(named: "video-player-icon-red")
                    videoBtn.setTitle(" Play video", for: .normal)
                    videoBtn.setImage(UIImage(named: "video-player-icon-red"), for: .normal)
                    videoBtn.tag = 43909
                } else {
                    // video is still pending recod
                    videoStatusImg.image = UIImage(named: "video-requested-red")
                    videoBtn.setTitle(" Record video proof", for: .normal)
                    videoBtn.tag = 43904
                }
            }
        } else {
            videoBtnHolder.isHidden = true
        }
    }
    
    @IBAction func videoAction(_ sender: Any) {
        let tag = (sender as! UIButton).tag
        if !product.video_requested {
            if (tag == 43904){
                if product.productOwner == HulaUser.sharedInstance.userId {
                    recordVideo()
                }
            } else {
                if (tag == 43909){
                    playVideo()
                } else {
                    let queryURL = HulaConstants.apiURL + "products/\(product.productId!)/requestvideo"
                    HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                        if (ok){
                            if let _ = json as? NSDictionary {
                                
                                DispatchQueue.main.async {
                                    let alert = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                                    alert.delegate = self as AlertDelegate
                                    alert.isCancelVisible = false
                                    alert.message = "You have requested a video for this product. You will receive a notification when the user uploads it."
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
        } else {
            DispatchQueue.main.async {
                let alert = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                alert.delegate = self as AlertDelegate
                alert.isCancelVisible = false
                alert.message = "This product is already waiting for a video proof. The owner will record a video and you will be notified."
                alert.trigger = "video_request"
                self.present(alert, animated: true)
            }
        }
    }
    func playVideo(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        let videoURL = URL(string: product.video_url)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    func recordVideo() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.allowRotation = true
            
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                HLDataManager.sharedInstance.onlyLandscapeView = true
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [ kUTTypeMovie as String ]
                imagePicker.allowsEditing = false
                imagePicker.videoQuality = .typeMedium
                imagePicker.videoMaximumDuration = 10
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: {})
            } else {
                print("Rear camera doesn't exist. Application cannot access the camera.")
            }
        } else {
            print("Camera inaccessable. Application cannot access the camera.")
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        HLDataManager.sharedInstance.onlyLandscapeView = false
        imagePicker.dismiss(animated: true, completion: {
            
        })
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
            notify("Uploading video...")
            
            HLDataManager.sharedInstance.uploadVideo(path, productId: product.productId, taskCallback: { (success, json) in
                print(json)
                self.notify("Video uploaded!")
                self.setupVideoButtons()
            })
        }
        
        HLDataManager.sharedInstance.onlyLandscapeView = false
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
            
            
        })
    }
    
    func videoWasSavedSuccessfully(_ data:Any){
        print(data)
        
    }
    
    func notify(_ txt: String){
        let banner = Banner(title: nil, subtitle: txt, backgroundColor: HulaConstants.appMainColor)
        banner.dismissesOnTap = true
        banner.show(duration: 0.7)
    }
    @IBAction func fsImageAction(_ sender: Any) {
        print("Fullingscreening")
        if let im = productsScrollView.viewWithTag(pageControl.currentPage + 1000) as? UIImageView{
            fullScreenImage(im.image!)
        }
    }
    
}

extension HLProductModalViewController: AlertDelegate{
    
    func alertResponded(response: String, trigger: String) {
        
    }

}


extension HLProductModalViewController {
    func fullScreenImage(_ image: UIImage) {
        print("Fullingscreening")
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 10, height:10)
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.alpha = 0.0
        newImageView.tag = 10001
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(optionsFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(swipe)
        self.view.addSubview(newImageView)
        image_dismissing = false
        UIView.animate(withDuration: 0.3, animations: {
            newImageView.frame = UIScreen.main.bounds
            newImageView.alpha = 1
        }) { (success) in
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
 
    }
    
    func dismissFullscreenImage(_ sender: UIGestureRecognizer) {
        if (!image_dismissing){
            guard let panRecognizer = sender as? UIPanGestureRecognizer else {
                return
            }
            let velocity = panRecognizer.velocity(in: self.view)
            
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                sender.view?.frame = CGRect(x: self.view.frame.width/2 + velocity.x/2, y: self.view.frame.height/2 + velocity.y/2, width: 30, height:30)
                sender.view?.alpha = 0
                sender.view?.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                sender.view?.removeFromSuperview()
            }
            image_dismissing = true
        }
    }
    func dismissFullscreenImageDirect() {
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        if let imageView = self.view.viewWithTag(10001) as? UIImageView {
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: self.view.frame.width/2 , y: self.view.frame.height/2, width: 30, height:30)
                imageView.alpha = 0
                imageView.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                imageView.removeFromSuperview()
            }
        }
        image_dismissing = true
    }
    func optionsFullscreenImage(_ sender: UIGestureRecognizer) {
        let alertController = UIAlertController(title: "Image options...", message: nil, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Close", style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
            self.dismissFullscreenImageDirect( )
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
}

extension UIImagePickerController{
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }
}
