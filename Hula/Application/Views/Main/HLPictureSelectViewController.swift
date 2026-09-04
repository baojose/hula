//
//  HLPictureSelectViewController.swift
//  Hula
//
//  Created by Juan Searle on 08/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class HLPictureSelectViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var controlView: UIView!

    // vars related with Camera
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var resultingImage: String = ""
    var backCam:Bool = true
    
    var originalSettingsVC:HLSettingViewController?
    var originalProfileVC:HLProfileViewController?
    
    // vars related with Photo Albums
    var arrAlbumPhotos: NSMutableArray!
    var arrSelectedIndexs: NSMutableArray!
    fileprivate let imageManager = PHCachingImageManager()
    
    let picker = UIImagePickerController()
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker.delegate = self
        
        
        self.initView()
        self.initCamera()
        self.beginSession()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
        
    }
    func initView(){
        titleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(titleLabel.text, 2.33)
    }
    func initCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if (backCam){
                        if(device.position == AVCaptureDevicePosition.back) {
                            captureDevice = device
                        }
                    } else {
                        if(device.position == AVCaptureDevicePosition.front) {
                            captureDevice = device
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let chosenImage = CommonUtils.pickedOriginalImage(from: info) else {
            dismiss(animated: true, completion: nil)
            return
        }
        let croppedImage:UIImage = self.commonUtils.cropImage(chosenImage, HulaConstants.product_image_thumb_size)
        // Album flow already dismisses here; camera capture dismisses from uploadImage.
        uploadImage(croppedImage, shouldDismiss: false)
        //dismiss(animated:true, completion: nil) //5
        dismissToPreviousPage(croppedImage)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        viewCamera.layer.addSublayer(previewLayer)
        previewLayer.frame = CGRect(x:0, y:0,  width: viewCamera.layer.frame.width, height:viewCamera.layer.frame.height);
        captureSession.startRunning()
        
        self.view.addSubview(navView)
        //self.view.addSubview(imgOverlay)
        self.view.addSubview(controlView)
    }
    func stopSession() {
        
        captureSession.stopRunning()
        
        
        for i in CommonUtils.captureDeviceInputs(from: self.captureSession.inputs) {
            self.captureSession.removeInput(i)
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeCameraTapped(_ sender: Any) {
        self.dismissToPreviousPage(sender)
    }
    @IBAction func selectFromAlbumAction(_ sender: Any) {
        openImagePicker()
    }

    @IBAction func switchCamAction(_ sender: Any) {
        backCam = !backCam
        stopSession()
        initCamera()
        beginSession()
    }
    @IBAction func takePhotoAction(_ sender: Any) {
        
        let flashView = UIView()
        flashView.frame = self.view.frame
        flashView.backgroundColor = UIColor.white
        flashView.alpha = 1.0
        self.view.addSubview(flashView)
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 0.0
        }) { (success) in
            flashView.removeFromSuperview()
        }
        
        
        saveToCamera(sender)
        //dismissToPreviousPage(sender)
    }
    func openImagePicker(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        // Images only — availableMediaTypes includes video and picking one
        // crashed in didFinishPickingMediaWithInfo via as! UIImage.
        picker.mediaTypes = CommonUtils.photoLibraryImageMediaTypes()
        present(picker, animated: true, completion: nil)
    }
    
    /// Still-image completions must hop to main before session/UI work.
    static func performCameraUIUpdate(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }

    func saveToCamera(_ sender: Any) {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        let croppedImage:UIImage = self.commonUtils.cropImage(cameraImage, HulaConstants.product_image_thumb_size)
                        // captureStillImageAsynchronously completes off the main thread.
                        HLPictureSelectViewController.performCameraUIUpdate {
                            self.stopSession()
                            self.uploadImage(croppedImage)
                        }
                    }
                }
            })
        }
    }
    
    
    /// Build the public profile photo URL from an upload response.
    /// Position is unused for avatars and may arrive as String or Number — do not gate on it.
    class func profileImageURL(fromUploadJSON json: Any?) -> String? {
        guard let dictionary = json as? [String: Any],
              let filePath = dictionary["path"] as? String, filePath.characters.count > 0 else {
            return nil
        }
        return HulaConstants.staticServerURL + filePath
    }

    /// Camera path stops the capture session before upload; always leave this screen
    /// when `shouldDismiss` is true, even if the payload is unusable.
    class func shouldDismissAfterProfileUpload(shouldDismiss: Bool, appliedPhoto: Bool) -> Bool {
        return shouldDismiss
    }

    func uploadImage(_ image:UIImage, shouldDismiss: Bool = true) {
        //print("Getting user info...")
        //print("Uploading images...")
        dataManager.uploadImage(image, itemPosition:10, taskCallback: { (ok, json) in
            DispatchQueue.main.async {
                var applied = false
                if ok, let imageURL = HLPictureSelectViewController.profileImageURL(fromUploadJSON: json) {
                    self.resultingImage = imageURL
                    HulaUser.sharedInstance.userPhotoURL = self.resultingImage

                    HulaUser.sharedInstance.updateServerData()
                    HLDataManager.sharedInstance.writeUserData()
                    self.originalSettingsVC?.smallProfileImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
                    self.originalProfileVC?.profileImageView.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
                    applied = true
                    if shouldDismiss {
                        self.dismissToPreviousPage(self.resultingImage)
                    }
                } else {
                    print("Connection error or unexpected upload payload")
                }
                if HLPictureSelectViewController.shouldDismissAfterProfileUpload(
                    shouldDismiss: shouldDismiss,
                    appliedPhoto: applied
                ) && !applied {
                    self.dismissToPreviousPage(self)
                }
            }
        });
    }

}
