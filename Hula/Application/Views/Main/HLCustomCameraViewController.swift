//
//  HLCustomCameraViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class HLCustomCameraViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var navView: UIView!
    @IBOutlet var controlView: UIView!
    @IBOutlet var viewCamera: UIView!
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    
    @IBOutlet weak var imgOverlay: UIImageView!
    @IBOutlet weak var btnCapture: UIButton!
    
    @IBOutlet var cameraOptionButton: UIButton!
    @IBOutlet var cameraOptionView: UIView!
    @IBOutlet var selectFromCameraButton: UIButton!
    
    
    // vars related with Camera
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    
    // vars related with Photo Albums
    var arrAlbumPhotos: NSMutableArray!
    var arrSelectedIndexs: NSMutableArray!
    fileprivate let imageManager = PHCachingImageManager()
    
    let picker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        self.initView()
        self.initData()
        self.initCamera()
        self.beginSession()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView(){
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        commonUtils.setRoundedRectBorderImageView(imageView1, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView2, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView3, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView4, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        
        
    }
    func initData(){
        arrAlbumPhotos = NSMutableArray.init()
        arrSelectedIndexs = NSMutableArray.init()
        //self.fetchAlbumPhotosAndShow()
        if dataManager.newProduct.arrProductPhotos.count > 0 {
            for i in 0 ..< dataManager.newProduct.arrProductPhotos.count{
                if i == 0 {
                    imageView1.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 1 {
                    imageView2.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 2 {
                    imageView3.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 3 {
                    imageView4.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
            }
        }
    }

    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        showImages(chosenImage)
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func openImagePicker(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    // IB Actions
    
    @IBAction func goNextPage(_ sender: UIButton) {
        dataManager.newProduct.arrProductPhotos = NSMutableArray.init()
        if imageView1.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView1.image! as UIImage)}
        if imageView2.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView2.image! as UIImage)}
        if imageView3.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView3.image! as UIImage)}
        if imageView4.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView4.image! as UIImage)}
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "postProductPage") as! HLPostProductViewController
        self.present(viewController, animated: true)
    }
    // #MARK - Camera Options
    @IBAction func cameraOption(_ sender: Any) {
        //changeTakePhotoWithMode(0)
    }
    
    @IBAction func showAlbum(_ sender: Any) {
        //changeTakePhotoWithMode(1)
        openImagePicker()
    }
    
    @IBAction func actionCameraCapture(_ sender: AnyObject) {
        saveToCamera()
    }
    
    
    
    
    // custom functions on VC
    
    func initCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.back) {
                        captureDevice = device
                    }
                }
            }
        }
    }
    func beginSession() {
        if captureDevice == nil {
            return
        }
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
            print("no preview layer")
            return
        }
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        viewCamera.layer.addSublayer(previewLayer)
        previewLayer.frame = viewCamera.layer.frame
        captureSession.startRunning()
        
        self.view.addSubview(navView)
        self.view.addSubview(imgOverlay)
        self.view.addSubview(controlView)
    }
    
    func saveToCamera() {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        self.showImages(self.commonUtils.cropImage(cameraImage, self.imgOverlay.frame.size))
                        //self.imageView1.image = self.commonUtils.cropImage(cameraImage, self.imgOverlay.frame.size)
                        self.selectFromCameraButton.isHidden = false
                    }
                }
            })
        }
    }
    
    func isSelectedImage(_ index: Int!) -> Int{
        var isSelected = -1
        for i in 0 ..< arrSelectedIndexs.count{
            if arrSelectedIndexs.object(at: i) as! Int == index {
                isSelected = i
                break
            }
        }
        return isSelected
    }
    //
    func showImages(_ image: UIImage){
        if imageView1.image != nil{
            if imageView2.image != nil{
                if imageView3.image != nil{
                    if imageView4.image != nil{
                    }else{
                        imageView4.image = image
                    }
                }else{
                    imageView3.image = image
                }
            }else{
                imageView2.image = image
            }
        }else{
            imageView1.image = image
        }
    }
    func hideImages(_ image: UIImage){
        if imageView1.image == image{
            imageView1.image = nil
        }
        if imageView2.image == image{
            imageView2.image = nil
        }
        if imageView3.image == image{
            imageView3.image = nil
        }
        if imageView4.image == image{
            imageView4.image = nil
        }
    }
    
    func productImagesPreViews(){
        
    }
}
