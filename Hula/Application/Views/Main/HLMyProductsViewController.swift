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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
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
        let titleHeight: CGFloat! = commonUtils.heightString(width: cell.productDescription.frame.size.width, font: cell.productDescription.font, string: cell.productDescription.text!)
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


    func newPostModeDesign(_ notification: NSNotification) {
        //print("NewPostMode")
        //print(HLDataManager.sharedInstance.newProduct.productId)
        //print(dataManager.uploadMode)
        if dataManager.uploadMode == true {
            // just if we are coming back from product creation
            if HLDataManager.sharedInstance.newProduct.productId.count > 0 && self.arrayProducts.count > 0{
                // item already exists and is being updated
                // this should not happen
                let updatingProduct = dataManager.newProduct
                self.arrayProducts[self.arrayProducts.count - 1] = updatingProduct
                updateProduct(for: updatingProduct)

                productTableView.reloadData()
                productTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            } else {


                let creatingProduct = HLDataManager.sharedInstance.newProduct
                let heroPhoto = ProductCreateSession.firstLocalPhoto(on: creatingProduct)
                self.arrayProducts.append(creatingProduct)
                // start of uploading and saving product; pin callbacks to this object
                uploadImages(for: creatingProduct)
                uploadProduct(for: creatingProduct)

                // wait 2 seconds and open the details view
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let current = HLDataManager.sharedInstance.newProduct
                    guard ProductCreateSession.shouldPresentCompleteProfile(captured: creatingProduct, current: current) else {
                        return
                    }
                    guard let heroPhoto = heroPhoto else {
                        return
                    }
                    guard self.presentedViewController == nil else {
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
            let queryURL = HulaConstants.apiURL + "products/user/" + HulaUser.sharedInstance.userId
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(json)
                if (ok){
                    DispatchQueue.main.async {
                        self.spinner.hide()

                        if let dictionary = json as? [Any] {
                            let products_arr = dictionary

                            self.arrayProducts = []
                            for pr in products_arr {
                                if let tmp = pr as? NSDictionary{
                                    let prod = HulaProduct()
                                    prod.populate(with: tmp)
                                    self.arrayProducts.append(prod)
                                }
                            }
                            HulaUser.sharedInstance.numProducts = self.arrayProducts.count


                            HulaUser.sharedInstance.arrayProducts = dictionary
                            if (self.arrayProducts.count != 0){
                                self.noProductsView.isHidden = true
                            } else {
                                self.noProductsView.isHidden = false
                            }
                        } else {
                            let alert = UIAlertController(title: "User token expired", message: "Your Hula session is expired. Please log in again.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: {
                                //print("going to login page")
                                self.openUserIdentification()
                            })
                        }
                        self.productTableView.reloadData()
                        HLDataManager.sharedInstance.writeUserData()
                    }
                } else {
                    // connection error
                    //print("Connection error")
                    self.noProductsView.isHidden = true
                }
            })
        }
    }
    func uploadProduct(for product: HulaProduct) {
        //print("Saving product...")
        if (HulaUser.sharedInstance.userId.count>0){
            let queryURL = HulaConstants.apiURL + "products/"
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
            let queryURL = HulaConstants.apiURL + "products/" + product.productId
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

    func updateProductDataString(for product: HulaProduct) -> String{
        //print(product.arrProductPhotoLink)
        let product_images_array = product.arrProductPhotoLink.joined(separator: ",")
        var dataString:String = "title=" + product.productName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&description=" + product.productDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&condition=" + product.productCondition.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&category_id=" + product.productCategoryId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&images=" + product_images_array.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        dataString += "&lat=\(HulaUser.sharedInstance.location.coordinate.latitude)"
        dataString += "&lng=\(HulaUser.sharedInstance.location.coordinate.longitude)"
        //print(dataString)
        return dataString
    }

    func uploadImages(for product: HulaProduct) {
        let progress = ProductCreateUploadProgress()
        product.arrProductPhotoLink = ProductCreateSession.preparedPhotoSlots()
        //print(product.arrProductPhotos)
        if (HulaUser.sharedInstance.userId.count>0){
            // user is logged in
            for i in 0 ..< 4{
                if ( product.arrProductPhotos.count>i ){
                    if let photo = product.arrProductPhotos[i] as? UIImage {
                        progress.toUpload += 1
                        dataManager.uploadImage(photo, itemPosition:i, taskCallback: { (ok, json) in
                            if (ok){
                                DispatchQueue.main.async {
                                    if let dictionary = json as? [String: Any] {
                                        if let filePath:String = dictionary["path"] as? String {
                                            if let pos = dictionary["position"] as? String, let position = Int(pos) {
                                                progress.uploaded += 1
                                                let url = HulaConstants.staticServerURL + filePath
                                                _ = ProductCreateSession.applyPhotoLink(url, at: position, to: product)
                                                if (progress.uploaded == progress.toUpload){
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
