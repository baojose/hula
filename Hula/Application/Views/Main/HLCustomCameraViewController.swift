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

class HLCustomCameraViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

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
    @IBOutlet var selectFromLibraryButton: UIButton!
    @IBOutlet var selectFromCameraButton: UIButton!
    @IBOutlet var albumContainView: UIView!
    @IBOutlet var photoCollectionView: UICollectionView!
    
    
    // vars related with Camera
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    
    // vars related with Photo Albums
    var arrAlbumPhotos: NSMutableArray!
    var arrSelectedIndexs: NSMutableArray!
    fileprivate let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        changeTakePhotoWithMode(0)
        changeSelectBtnStatus(0)
        
        let num: CGFloat! = 3.0;
        let flowLayout = self.photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidthForCells: CGFloat! = self.photoCollectionView.frame.size.width
        let cellWidth: CGFloat! = availableWidthForCells / num
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    func initData(){
        arrAlbumPhotos = NSMutableArray.init()
        arrSelectedIndexs = NSMutableArray.init()
        self.fetchAlbumPhotosAndShow()
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
//#MARK - Photo Library Options
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrAlbumPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! HLPhotoAlbumCollectionViewCell
        let image = arrAlbumPhotos.object(at: indexPath.row) as! UIImage
        cell.photo.image = image
        if self.isSelectedImage(indexPath.row) != -1 {
            cell.selectedMarkImage.image = UIImage.init(named: "icon_photo_album_selected")
        }else{
            cell.selectedMarkImage.image = UIImage.init(named: "icon_photo_album_unselected")
        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let alreadySelected = self.isSelectedImage(indexPath.row)
        if alreadySelected != -1 {
            self.hideImages(arrAlbumPhotos.object(at: indexPath.row) as! UIImage)
            arrSelectedIndexs.removeObject(at: alreadySelected)
        }else{
            arrSelectedIndexs.add( indexPath.row as Int)
            self.showImages(arrAlbumPhotos.object(at: indexPath.row) as! UIImage)
            changeSelectBtnStatus(1)
        }
        collectionView.reloadData()
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
        changeTakePhotoWithMode(0)
    }
    
    @IBAction func showAlbum(_ sender: Any) {
        changeTakePhotoWithMode(1)
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
    
    
    func fetchAlbumPhotosAndShow(){
        arrAlbumPhotos = NSMutableArray.init()
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) images")
                let thumbnailSize: CGSize! = self.imgOverlay.frame.size
                let maxPhotoAlbumSize = 5;
                let visiblePhotos = min(maxPhotoAlbumSize, allPhotos.count)
                for i in 0 ..< visiblePhotos{
                    let asset = allPhotos.object(at: i)
                    self.imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                        self.arrAlbumPhotos.add(image! as UIImage)
                    })
                }
                self.photoCollectionView.reloadData()
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
    
    func changeTakePhotoWithMode(_ mode: Int!){
        if mode == 0 {
            albumContainView.isHidden = true
            viewCamera.isHidden = false
            selectFromLibraryButton.isHidden = true
            cameraOptionButton.isHidden = true
            cameraOptionView.isHidden = false
            imgOverlay.isHidden = false
        }else{
            albumContainView.isHidden = false
            viewCamera.isHidden = true
            selectFromLibraryButton.isHidden = false
            cameraOptionButton.isHidden = false
            cameraOptionView.isHidden = true
            imgOverlay.isHidden = true
        }
    }
    func changeSelectBtnStatus(_ mode: Int!) {
        if mode == 0 {
            selectFromLibraryButton.isHidden = true
            selectFromCameraButton.isHidden = true
        }else{
            selectFromLibraryButton.isHidden = false
            selectFromCameraButton.isHidden = false
        }
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
