//
//  HLMyProductsViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import BRYXBanner
import CoreLocation

class HLMyProductsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var addProductHolder: UIView!
    @IBOutlet var productTableView: UITableView!
    @IBOutlet weak var noProductsView: UIView!
    var locationManager = CLLocationManager()
    var arrayProducts: [HulaProduct] = []
    var spinner: HLSpinnerUIView!
    var last_logged_user:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HLMyProductsViewController.newPostModeDesign(_:)), name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
        setupView()
        
        
        
        // geolocate product
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if last_logged_user != HulaUser.sharedInstance.userId {
            last_logged_user = HulaUser.sharedInstance.userId
            setupView()
        }
        
        self.getUserProducts()
        
        if dataManager.uploadMode == false {
            self.productTableView.reloadData()
        }
        
        var tabbarHeight : CGFloat = 50
        if Device.IS_IPHONE_X {
            tabbarHeight = 84
        }
        addProductHolder.frame.origin.y = self.view.frame.height - addProductHolder.frame.height - tabbarHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        
        HLDataManager.sharedInstance.ga("my_products")
    }
    
    func setupView(){
        noProductsView.isHidden = true
        
        //self.getUserProducts()
        
    }
    
    func initView(){
    }
    
    /// Empty Core Location callbacks used `locations[0]` and crashed inventory GPS persist.
    class func firstUpdatedLocation(from locations: [CLLocation]) -> CLLocation? {
        return LocationUpdatePolicy.firstLocation(from: locations)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = HLMyProductsViewController.firstUpdatedLocation(from: locations) else {
            return
        }
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        
        //print(long, lat)
        HulaUser.sharedInstance.location = CLLocation(latitude:lat, longitude:long);
        locationManager.stopUpdatingLocation()
        
        HLDataManager.sharedInstance.writeUserData()
        //Do What ever you want with it
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.arrayProducts.count != 0){
            return self.arrayProducts.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myProductTableViewCell") as! HLMyProductTableViewCell
        var order_sorted = self.arrayProducts.count - indexPath.row - 1
        if(order_sorted > self.arrayProducts.count){
            order_sorted = self.arrayProducts.count - 1
        }
        if(order_sorted < 0){
            order_sorted = 0
        }
        
        let product : HulaProduct = self.arrayProducts[order_sorted]
        //print(product)
        cell.productDescription.text = product.productName
        if product.trading_count > 1 {
            cell.isMultipleTrades.isHidden = false
        } else {
            cell.isMultipleTrades.isHidden = true
        }
        if (product.productImage.count == 0){
            if (dataManager.newProduct.arrProductPhotos.count>0){
                if let img = dataManager.newProduct.arrProductPhotos.object(at: 0) as? UIImage {
                    cell.productImage.image = img
                } else {
                    cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
                }
            } else {
                cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
            }
        } else {
            let thumb = commonUtils.getThumbFor(url: product.productImage)
            cell.productImage.loadImageFromURL(urlString: thumb)
        }
        
        cell.warningView.isHidden = true
        /*
        if (product.productDescription != ""){
            cell.warningView.isHidden = true
        }
         */
        let titleHeight: CGFloat! = HLMyProductsViewController.productTitleHeight(
            width: cell.productDescription.frame.size.width,
            font: cell.productDescription.font,
            text: cell.productDescription.text
        )
        cell.productDescription.frame = CGRect(x: cell.productDescription.frame.origin.x, y:(cell.contentView.frame.size.height - titleHeight) / 2.0, width: cell.productDescription.frame.size.width, height: titleHeight)
        

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        var order_sorted = self.arrayProducts.count - indexPath.row - 1
        if(order_sorted > self.arrayProducts.count){
            order_sorted = self.arrayProducts.count - 1
        }
        if(order_sorted < 0){
            order_sorted = 0
        }
        
        let product : HulaProduct = self.arrayProducts[order_sorted]
        if (product.productName == NSLocalizedString("Untitled product", comment: "") ) {
            // product is incomplete
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeProductProfilePage") as! HLCompleteProductProfileViewController
            self.dataManager.newProduct = product
            self.present(viewController, animated: true)
            
            HLDataManager.sharedInstance.uploadMode = false
        } else {
            goEditProductPage(index: order_sorted)
        }
    }
    
    private var finishedLoadingInitialTableCells = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var lastInitialDisplayableCell = false
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if self.arrayProducts.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        if !finishedLoadingInitialTableCells {
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.rowHeight/2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    // IB Actions
    
    @IBAction func presentAddNewProductPage(_ sender: UIButton) {
        // add new product button presed. Lets open the camera vc
        dataManager.uploadMode = true
        dataManager.newProduct = HulaProduct.init()
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "customCameraPage") as! HLCustomCameraViewController
        self.present(cameraViewController, animated: true)
    }
    
    
    // Custom functions for ViewController

    /// Locate a product by id so Complete Profile Done updates the edited row, not always the last row.
    class func indexOfProduct(withId productId: String, in products: [HulaProduct]) -> Int? {
        guard productId.count > 0 else { return nil }
        for (idx, product) in products.enumerated() {
            if product.productId == productId {
                return idx
            }
        }
        return nil
    }

    /// Inventory listing. Blank userId must not hit `products/user/`.
    class func userProductsURL(apiBase: String, userId: String?) -> String? {
        return CommonUtils.productsForUserURL(apiBase: apiBase, userId: userId)
    }

    /// Inventory title height used `cell.productDescription.text!`.
    class func productTitleHeight(width: CGFloat, font: UIFont?, text: String?) -> CGFloat {
        return LabelMetricsPolicy.layoutHeight(width: width, font: font, text: text, extra: 0)
    }

    /// Product create POST historically hits `products/` (trailing slash).
    class func productsCreateURL(apiBase: String) -> String? {
        return CommonUtils.apiCollectionURL(apiBase: apiBase, resource: "products", trailingSlash: true)
    }

    /// `products/user/{id}` must return an array. Object/error JSON must not force re-login.
    class func isProductsListPayload(_ json: Any?) -> Bool {
        return json is [Any]
    }

    /// Soft-parse upload callback `position` (String or numeric JSON). Invalid/out-of-range → nil.
    class func uploadSlotIndex(from position: Any?, maxSlots: Int = 4) -> Int? {
        let idx: Int?
        if let s = position as? String {
            idx = Int(s)
        } else if let i = position as? Int {
            idx = i
        } else if let d = position as? Double {
            idx = Int(d)
        } else if let n = position as? NSNumber {
            let objCType = String(cString: n.objCType)
            if objCType == "c" || objCType == "B" {
                idx = nil
            } else {
                idx = n.intValue
            }
        } else {
            idx = nil
        }
        guard let slot = idx, slot >= 0, slot < maxSlots else {
            return nil
        }
        return slot
    }

    /// Create flow posts product + uploads images in parallel. Attach images only once both sides are ready.
    class func shouldAttachUploadedImages(productId: String?, imagesToUpload: Int, imagesAlreadyUploaded: Int) -> Bool {
        guard let productId = productId, productId.count > 0 else {
            return false
        }
        if imagesToUpload <= 0 {
            return true
        }
        return imagesAlreadyUploaded >= imagesToUpload
    }
    
    func newPostModeDesign(_ notification: NSNotification) {
        //print("NewPostMode")
        //print(HLDataManager.sharedInstance.newProduct.productId)
        //print(dataManager.uploadMode)
        if dataManager.uploadMode == true {
            // just if we are coming back from product creation
            let newProduct = HLDataManager.sharedInstance.newProduct
            var existingIndex = self.arrayProducts.index(where: { $0 === newProduct })
            if existingIndex == nil && newProduct.productId.count > 0 {
                // After getUserProducts refresh, instances differ but productId matches.
                existingIndex = HLMyProductsViewController.indexOfProduct(
                    withId: newProduct.productId,
                    in: self.arrayProducts
                )
            }

            if let idx = existingIndex {
                // Already tracking this create/update — never start a second create.
                // Complete-profile "Done" re-enters here while productId may still be empty.
                self.arrayProducts[idx] = newProduct
                if newProduct.productId.count > 0 {
                    updateProduct(for: newProduct)
                }
                productTableView.reloadData()
                productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            } else if newProduct.productId.count > 0 {
                // Known product id with no matching row: do not clobber the last inventory slot.
                // Keep local list intact and persist via updateProduct only.
                updateProduct(for: newProduct)
                productTableView.reloadData()
                productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            } else {
                let creatingProduct = newProduct
                let heroPhoto = ProductCreateSession.firstLocalPhoto(on: creatingProduct)
                let progress = ProductCreateUploadProgress()
                self.arrayProducts.append(creatingProduct)
                // Pin POST/upload callbacks to this object; a later Add Product must not retarget IDs.
                uploadImages(for: creatingProduct, progress: progress)
                uploadProduct(for: creatingProduct, progress: progress)

                // wait 2 seconds and open the details view
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let current = HLDataManager.sharedInstance.newProduct
                    guard ProductCreateSession.shouldPresentCompleteProfile(
                        captured: creatingProduct,
                        current: current,
                        alreadyPresenting: self.presentedViewController != nil
                    ) else {
                        return
                    }
                    guard let heroPhoto = heroPhoto else {
                        // No local photo to preview; keep uploadMode so a later update can still persist.
                        return
                    }
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeProductProfilePage") as! HLCompleteProductProfileViewController
                    viewController.productImage = heroPhoto
                    self.present(viewController, animated: true)

                    // next time coming to this VC, go straight to the update process
                    if HLDataManager.sharedInstance.newProduct === creatingProduct {
                        HLDataManager.sharedInstance.uploadMode = false
                    }
                }
                // refresh table
                productTableView.reloadData()
                productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)

                if let newCell = productTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HLMyProductTableViewCell{
                    newCell.alpha = 0
                    let when = DispatchTime.now() + 0.3 // change 2 to desired number of seconds
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        newCell.alpha = 1
                        newCell.animateAsNew()
                    }
                }
            }
        }
    }
    
    func getUserProducts() {
        //print("Getting product info...")
        if (HulaUser.sharedInstance.userId.count>0){
            guard let queryURL = HLMyProductsViewController.userProductsURL(
                apiBase: HulaConstants.apiURL,
                userId: HulaUser.sharedInstance.userId
            ) else {
                spinner.hide()
                return
            }
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                let payloadUsable = HLMyProductsViewController.isProductsListPayload(json)
                let ui = BlockingNetworkLoadUI.outcome(ok: ok, payloadUsable: payloadUsable)
                DispatchQueue.main.async {
                    if ui.hideSpinner {
                        self.spinner.hide()
                    }

                    if ui.applyPayload, let products_arr = json as? [Any] {
                        self.arrayProducts = []
                        for pr in products_arr {
                            if let tmp = pr as? NSDictionary{
                                let prod = HulaProduct()
                                prod.populate(with: tmp)
                                self.arrayProducts.append(prod)
                            }
                        }
                        HulaUser.sharedInstance.numProducts = self.arrayProducts.count
                        HulaUser.sharedInstance.arrayProducts = products_arr
                        if (self.arrayProducts.count != 0){
                            self.noProductsView.isHidden = true
                        } else {
                            self.noProductsView.isHidden = false
                        }
                    }
                    // Inventory error JSON is not /me expiry — never force re-login here.
                    if ok {
                        self.productTableView.reloadData()
                        HLDataManager.sharedInstance.writeUserData()
                    }
                }
            })
        } else {
            spinner.hide()
        }
    }
    func uploadProduct(for product: HulaProduct, progress: ProductCreateUploadProgress) {
        //print("Saving product...")
        if (HulaUser.sharedInstance.userId.count>0){
            guard let queryURL = HLMyProductsViewController.productsCreateURL(apiBase: HulaConstants.apiURL) else {
                return
            }
            let dataString:String = updateProductDataString(for: product)
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        //print("Saved")
                        if let dictionary = json as? [String:Any] {
                            //print(dictionary)
                            if let product_id = dictionary["product_id"] as? String {
                                ProductCreateSession.applyCreatedProductId(product_id, to: product)
                                // Images may have finished before create returned; attach them only when both sides are ready.
                                // Also persists title/description set while create was in flight (complete-profile Done).
                                if HLMyProductsViewController.shouldAttachUploadedImages(
                                    productId: product.productId,
                                    imagesToUpload: progress.toUpload,
                                    imagesAlreadyUploaded: progress.uploaded
                                ) {
                                    self.updateProduct(for: product)
                                }
                            }
                        }

                        if (self.arrayProducts.count > 0){
                            self.noProductsView.isHidden = true
                            self.productTableView.reloadData()
                        }
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
    func updateProduct(for product: HulaProduct) {
        //print("Updating product...")
        if (product.productId.count>0){
            guard let queryURL = HulaProduct.updateURL(apiBase: HulaConstants.apiURL, productId: product.productId) else {
                return
            }
            let dataString:String = updateProductDataString(for: product)
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if json as? [String:Any] != nil {
                            //print(dictionary)
                        }
                        if HLDataManager.sharedInstance.newProduct === product {
                            HLDataManager.sharedInstance.uploadMode = false
                        }

                        if (self.arrayProducts.count > 0){
                            self.noProductsView.isHidden = true
                        }
                        HLDataManager.sharedInstance.getCategories()
                        self.productTableView.reloadData()
                        self.getUserProducts()
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }

    class func productFormPostString(for product: HulaProduct, latitude: Double, longitude: Double) -> String {
        let product_images_array = (product.arrProductPhotoLink ?? []).joined(separator: ",")
        // urlHostAllowed leaves &=+ unescaped and corrupts adjacent form fields.
        return CommonUtils.productFormPostString(
            title: product.productName ?? "",
            description: product.productDescription ?? "",
            condition: product.productCondition ?? "",
            categoryId: product.productCategoryId ?? "",
            imagesCSV: product_images_array,
            latitude: latitude,
            longitude: longitude
        )
    }

    func updateProductDataString(for product: HulaProduct) -> String {
        return HLMyProductsViewController.productFormPostString(
            for: product,
            latitude: HulaUser.sharedInstance.location.coordinate.latitude,
            longitude: HulaUser.sharedInstance.location.coordinate.longitude
        )
    }

    func uploadImages(for product: HulaProduct, progress: ProductCreateUploadProgress) {
        product.arrProductPhotoLink = ProductCreateSession.preparedPhotoSlots()
        //print(product.arrProductPhotos)
        if (HulaUser.sharedInstance.userId.count>0){
            // user is logged in
            for i in 0 ..< 4{
                if let image = CommonUtils.uiImage(at: i, in: product.arrProductPhotos) {
                        progress.toUpload += 1
                        dataManager.uploadImage(image, itemPosition:i, taskCallback: { (ok, json) in
                            if (ok){
                                DispatchQueue.main.async {
                                    if let dictionary = json as? [String: Any] {
                                        if let filePath:String = dictionary["path"] as? String {
                                            if let slot = HLMyProductsViewController.uploadSlotIndex(
                                                from: dictionary["position"]
                                            ) {
                                                progress.uploaded += 1
                                                let url = HulaConstants.staticServerURL + filePath
                                                _ = ProductCreateSession.applyPhotoLink(url, at: slot, to: product)
                                                // Only PUT when create has assigned productId; otherwise uploadProduct will attach.
                                                if HLMyProductsViewController.shouldAttachUploadedImages(
                                                    productId: product.productId,
                                                    imagesToUpload: progress.toUpload,
                                                    imagesAlreadyUploaded: progress.uploaded
                                                ) {
                                                    self.updateProduct(for: product)
                                                }
                                                self.notify("Uploaded image \(progress.uploaded) of \(progress.toUpload).")
                                            }
                                        }
                                    }
                                }
                            } else {
                                // connection error
                                print("Connection error")
                            }
                        });
                }
            }
            self.notify("Uploading \(progress.toUpload) images...")
        }
    }
    func notify(_ txt: String){
        let banner = Banner(title: nil, subtitle: txt, backgroundColor: HulaConstants.appMainColor)
        banner.dismissesOnTap = true
        banner.show(duration: 0.7)
    }
    func goEditProductPage(index: Int){
        //print(sender.tag)
        //let productToDisplay : HulaProduct = self.arrayProducts[index]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "editProductMainPage") as! HLEditProductMainViewController
        //viewController.productToDisplay = productToDisplay
        viewController.product = self.arrayProducts[index]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
