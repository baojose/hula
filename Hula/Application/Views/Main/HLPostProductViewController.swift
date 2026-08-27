//
//  HLPostProductViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLPostProductViewController: BaseViewController {

    
    
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var secondImage: UIImageView!
    @IBOutlet var thirdImage: UIImageView!
    @IBOutlet var forthImage: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainImageLabel: UILabel!
    
    @IBOutlet weak var categoriesTable: UITableView!
    
    @IBOutlet weak var cameraButton1: UIButton!
    @IBOutlet weak var cameraButton2: UIButton!
    @IBOutlet weak var cameraButton3: UIButton!
    @IBOutlet weak var cameraButton4: UIButton!
    @IBOutlet weak var imgFrameView1: UIView!
    @IBOutlet weak var imgFrameView2: UIView!
    @IBOutlet weak var imgFrameView3: UIView!
    @IBOutlet weak var imgFrameView4: UIView!
    
    @IBOutlet weak var deleteImageButton1: UIButton!
    @IBOutlet weak var deleteImageButton2: UIButton!
    @IBOutlet weak var deleteImageButton3: UIButton!
    @IBOutlet weak var deleteImageButton4: UIButton!
    
    
    var arrImageViews: NSMutableArray!
    var arrImageFrameViews: NSMutableArray!
    var image_dismissing = false
    var currentEditingIndex:Int = 0

    /// Soft-read create-flow photo slot chrome. Extra photos or mismatched arrays
    /// previously crashed via `as! UIImageView` / `as! UIButton`.
    class func photoSlotViews(
        at index: Int,
        images: NSArray?,
        cameras: NSArray?,
        deletes: NSArray?,
        frames: NSArray?
    ) -> (image: UIImageView, camera: UIButton, delete: UIButton, frame: UIView)? {
        guard let images = images, let cameras = cameras, let deletes = deletes, let frames = frames,
            index >= 0,
            index < images.count,
            index < cameras.count,
            index < deletes.count,
            index < frames.count,
            let image = images.object(at: index) as? UIImageView,
            let camera = cameras.object(at: index) as? UIButton,
            let delete = deletes.object(at: index) as? UIButton,
            let frame = frames.object(at: index) as? UIView else {
                return nil
        }
        return (image, camera, delete, frame)
    }

    class func controlTag(from sender: Any?) -> Int? {
        if let control = sender as? UIControl {
            return control.tag
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.categoriesTable.delaysContentTouches = false;
        HLDataManager.sharedInstance.ga("product_create")
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
        
        setupImagesBoxes()
        
        
        //productTitleTxtField.text = self.dataManager.newProduct.productName
    }
    func setupImagesBoxes(){
        let arrCameraButtons = NSMutableArray.init(capacity: 4)
        let arrDeleteButtons = NSMutableArray.init(capacity: 4)
        
        cameraButton1.isHidden = false;
        cameraButton2.isHidden = false;
        cameraButton3.isHidden = false;
        cameraButton4.isHidden = false;
        
        deleteImageButton1.isHidden = true;
        deleteImageButton2.isHidden = true;
        deleteImageButton3.isHidden = true;
        deleteImageButton4.isHidden = true;
        
        arrCameraButtons.add(cameraButton1)
        arrCameraButtons.add(cameraButton2)
        arrCameraButtons.add(cameraButton3)
        arrCameraButtons.add(cameraButton4)
        
        arrDeleteButtons.add(deleteImageButton1)
        arrDeleteButtons.add(deleteImageButton2)
        arrDeleteButtons.add(deleteImageButton3)
        arrDeleteButtons.add(deleteImageButton4)
        
        mainImage.image = nil;
        secondImage.image = nil;
        thirdImage.image = nil;
        forthImage.image = nil;
        
        if dataManager.newProduct.arrProductPhotos.count > 0 {
            for i in 0 ..< dataManager.newProduct.arrProductPhotos.count{
                guard let slot = HLPostProductViewController.photoSlotViews(
                    at: i,
                    images: arrImageViews,
                    cameras: arrCameraButtons,
                    deletes: arrDeleteButtons,
                    frames: arrImageFrameViews
                ) else {
                    continue
                }
                let imgView = slot.image
                let buttonView = slot.camera
                let deleteButtonView = slot.delete
                let frameView = slot.frame
                frameView.isUserInteractionEnabled = true
                let recognizer = UITapGestureRecognizer()
                //recognizer.cancelsTouchesInView = false
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
                    deleteButtonView.isHidden = false
                } else {
                    buttonView.isHidden = false;
                    deleteButtonView.isHidden = true
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
        
        //productTitleTxtField.addTarget(self, action: #selector(textchange(_:)), for: UIControlEvents.editingChanged)
        //publishBtn.setup()
        self.changePublishBtnState("")
        //let tapGesture: UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: #selector(onTapScreen))
        //self.view.addGestureRecognizer(tapGesture)
    }
    
    func selectedImageTapped(_ sender: UITapGestureRecognizer){
        //print("Touches began")
        guard let tappedIndex = sender.view?.tag else {
            return
        }
        
        if (dataManager.newProduct.arrProductPhotos.count > tappedIndex ){
            print(dataManager.newProduct.arrProductPhotos[tappedIndex])
            if let imageView = dataManager.newProduct.arrProductPhotos[tappedIndex] as? UIImage {
                fullScreenImage(image:imageView, index: tappedIndex)
            }
        }
    }
    
    func fullScreenImage(image: UIImage, index: Int) {
        print("opening full screen...")
        currentEditingIndex = index
        
        
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
            
            self.navigationController?.isNavigationBarHidden = false
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
            
        self.navigationController?.isNavigationBarHidden = false
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
        let alertController = UIAlertController(title:  NSLocalizedString("Image options...", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        
        let editButton = UIAlertAction(title:  NSLocalizedString("Try another image", comment: ""), style: .default, handler: { (action) -> Void in
            print("Close")
            self.dataManager.newProduct.arrProductPhotos.removeObject(at: self.currentEditingIndex);
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(editButton)
        
        
        if (self.currentEditingIndex != 0){
            let setDefaultButton = UIAlertAction(title:  NSLocalizedString("Set as featured image", comment: ""), style: .default, handler: { (action) -> Void in
                swap(&self.dataManager.newProduct.arrProductPhotos[0], &self.dataManager.newProduct.arrProductPhotos[self.currentEditingIndex])
                self.dismissFullscreenImageDirect( )
                self.setupImagesBoxes()
            })
            alertController.addAction(setDefaultButton)
        }
        
        
        let  deleteButton = UIAlertAction(title:  NSLocalizedString("Delete image", comment: ""), style: .destructive, handler: { (action) -> Void in
            //print("Delete button tapped")
            self.dataManager.newProduct.arrProductPhotos.removeObject(at: self.currentEditingIndex);
            self.dismissFullscreenImageDirect( )
            self.setupImagesBoxes()
        })
        alertController.addAction(deleteButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func deleteImageAction(_ sender: Any) {
        guard let tag = HLPostProductViewController.controlTag(from: sender) else {
            return
        }
        if (self.dataManager.newProduct.arrProductPhotos.count > tag){
            self.dataManager.newProduct.arrProductPhotos.removeObject(at: tag);
            self.setupImagesBoxes()
        }
    }
    
    func changePublishBtnState(_ string: String){
        self.dataManager.newProduct.productName = string
        /*
        if dataManager.newProduct.arrProductPhotos.count != 0 && string.count != 0  {
            publishBtn.isEnabled = true
            //publishBtn.startAnimation()
        }else{
            publishBtn.isEnabled = false
            //publishBtn.stopAnimation()
        }
         */
    }
    func onTapScreen(){
        //productTitleTxtField.resignFirstResponder()
        
    }
    @IBAction func cameraButtonTap(_ sender: Any) {
        print((sender as AnyObject).tag)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //#MARK - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    func textchange(_ textField:UITextField) {
        self.changePublishBtnState(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField.resignFirstResponder()
    }
    @IBAction func dismissToProductPage(_ sender: Any) {
        HLDataManager.sharedInstance.uploadMode = false
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func publishNewProduct(_ sender: Any) {
        guard dataManager.newProduct.arrProductPhotos.firstObject as? UIImage != nil else {
            let alert = UIAlertController(
                title: NSLocalizedString("Add a photo", comment: ""),
                message: NSLocalizedString("Please add at least one photo before publishing.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        dataManager.newProduct.productName = NSLocalizedString("Untitled product", comment: "")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension HLPostProductViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.arrCategories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "completeProductProfileCategoryCell") as! HLHomeCategoryTableViewCell
        guard let category = HLHomeViewController.categoryDictionary(at: indexPath.row, in: dataManager.arrCategories) else {
            return cell
        }
        if let presentation = HLHomeViewController.categoryPresentation(from: category) {
            cell.categoryName.attributedText = commonUtils.attributedStringWithTextSpacing(presentation.name, CGFloat(2.33))
            if presentation.icon.count > 0 {
                cell.categoryImage.image = UIImage.init(named: presentation.icon)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Publishing with zero photos creates an orphan listing then crashes when
        // the complete-profile sheet force-casts arrProductPhotos[0].
        guard dataManager.newProduct.arrProductPhotos.firstObject as? UIImage != nil else {
            let alert = UIAlertController(
                title: NSLocalizedString("Add a photo", comment: ""),
                message: NSLocalizedString("Please add at least one photo before publishing.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        guard let category = HLHomeViewController.categoryDictionary(at: indexPath.row, in: dataManager.arrCategories) else {
            return
        }
        print(category)
        guard let selection = HLHomeViewController.categorySelection(from: category) else {
            return
        }
        dataManager.newProduct.productCategory = selection.name
        dataManager.newProduct.productCategoryId = selection.id

        dataManager.newProduct.productName = NSLocalizedString("Untitled product", comment: "")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)

        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

