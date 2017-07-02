//
//  HLBarterScreenViewController.swift
//  Hula
//
//  Created by Juan Searle on 13/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLBarterScreenViewController: UIViewController {

    @IBOutlet weak var otherProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var otherSelectedProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var myProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var mySelectedProductsCollection: KDDragAndDropCollectionView!
    
    
    @IBOutlet weak var otherProductsDragView: UIImageView!
    @IBOutlet weak var myProductsDragView: UIImageView!
    
    
    @IBOutlet weak var otherProductsLabel: UILabel!
    @IBOutlet weak var myProductsLabel: UILabel!
    
    var myProducts : [HulaProduct] = []
    var otherProducts : [HulaProduct] = []
    var myTradedProducts : [HulaProduct] = []
    var otherTradedProducts : [HulaProduct] = []
    var myProductsDiff : [String] = []
    var otherProductsDiff : [String] = []
    var myTradeIndex: Int = 1
    var firstLoad: Bool = true
    
    let arrowImagesName = ["","added-arrow", "removed-arrow", "eliminated_trade_icon"]
    
    var otherUserId: String = ""
    
    
    var dragAndDropManager1 : KDDragAndDropManager?
    var dragAndDropManager2 : KDDragAndDropManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.dragAndDropManager1 = KDDragAndDropManager(canvas: self.view, collectionViews: [otherProductsCollection, otherSelectedProductsCollection ])
        self.dragAndDropManager2 = KDDragAndDropManager(canvas: self.view, collectionViews: [myProductsCollection, mySelectedProductsCollection ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProductsArrays(){
        myTradeIndex = 0
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            print(swappPageVC.orderedViewControllers )
            if let firstViewController = swappPageVC.viewControllers?.first,
                let index = swappPageVC.orderedViewControllers.index(of: firstViewController) {
                print(firstViewController )
                print("Current Index: \(index)" )
                myTradeIndex = index - 1
                
            }
        }
        myTradeIndex = max(0, myTradeIndex);
        //myProducts
        var mtp:[String] = []
        var otp:[String] = []
        if firstLoad {
            firstLoad = false
            if let swappPageVC = self.parent as? HLSwappPageViewController{
                if let ct = swappPageVC.arrTrades[myTradeIndex] as? NSDictionary {
                    if (ct.object(forKey: "owner_id") as? String == HulaUser.sharedInstance.userId){
                        // I am the owner
                        if let mtp_temp = ct.object(forKey: "owner_products") as? [String]{
                            mtp = mtp_temp
                        }
                        if let otp_temp = ct.object(forKey: "other_products") as? [String]{
                            otp = otp_temp
                        }
                        myProductsDiff = (ct.object(forKey: "owner_products") as? [String])!
                        otherProductsDiff = (ct.object(forKey: "other_products") as? [String])!
                        otherUserId = (ct.object(forKey: "other_id") as? String)!
                        
                    } else {
                        // I am the other
                        if let mtp_temp = ct.object(forKey: "other_products") as? [String]{
                            mtp = mtp_temp
                        }
                        if let otp_temp = ct.object(forKey: "owner_products") as? [String]{
                            otp = otp_temp
                        }
                        otherUserId = (ct.object(forKey: "owner_id") as? String)!
                    }
                    
                    getUserProducts(user: otherUserId, taskCallback: {(result) in
                        //print (self.otherProducts)
                        self.otherProducts = result
                        self.populateTradedProducts(list:otp, type:"other")
                        self.otherProductsCollection.reloadData()
                        self.otherSelectedProductsCollection.reloadData()
                        
                    })
                    
                    getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
                        //print (self.myProducts)
                        self.myProducts = result
                        self.populateTradedProducts(list:mtp, type:"owner")
                        self.myProductsCollection.reloadData()
                        self.mySelectedProductsCollection.reloadData()
                    })
     
                }
                
            }
        }
    }
    
    func populateTradedProducts(list: [String], type: String){
        let reference_list: [HulaProduct]
        var final_arr: [HulaProduct] = []
        switch type {
        case "other":
            reference_list = self.otherProducts
        default:
            reference_list = self.myProducts
        }
        for pr_id in list{
            for pr in reference_list{
                if pr.productId == pr_id{
                    final_arr.append(pr)
                }
            }
        }
        switch type {
        case "other":
            otherTradedProducts = final_arr
        default:
            myTradedProducts = final_arr
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadProductsArrays();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /*
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            //print("viewWillAppear" )
            if let ct = swappPageVC.currentTrade {
                if (ct.object(forKey: "owner_id") as? String == HulaUser.sharedInstance.userId){
                    // I am the owner
                    myTradedProducts = (ct.object(forKey: "owner_products") as? [String])!
                    otherTradedProducts = (ct.object(forKey: "other_products") as? [String])!
                    otherUserId = (ct.object(forKey: "other_id") as? String)!
                    
                } else {
                    // I am the other
                    myTradedProducts = (ct.object(forKey: "other_products") as? [String])!
                    otherTradedProducts = (ct.object(forKey: "owner_products") as? [String])!
                    otherUserId = (ct.object(forKey: "owner_id") as? String)!
                }
                
                getUserProducts(user: otherUserId, taskCallback: {(result) in
                    self.otherProducts = result
                    print (self.otherProducts)
                    self.otherProductsCollection.reloadData()
                    
                })
                getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
                    self.myProducts = result
                    //print (self.myProducts)
                    self.myProductsTable.reloadData()
                })
            }
        }
 */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getUserProducts(user: String, taskCallback: @escaping ([HulaProduct]) -> ()) {
        //print("Getting user info...")
        if (HulaUser.sharedInstance.userId.characters.count>0){
            let queryURL = HulaConstants.apiURL + "products/user/" + user
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            //print(dictionary)
                            var productList: [HulaProduct] = []
                            for item in dictionary{
                                //print("item")
                                //print(item)
                                if let product_data = item as? [String : Any]{
                                    let id = product_data["_id"] as! String
                                    let name = product_data["title"] as! String
                                    var image = product_data["image_url"] as? String
                                    if (image == nil){
                                        image = "https://api.hula.trading/v1/products/0/image"
                                    }
                                    let newProd = HulaProduct(id : id, name : name, image: image!)
                                    productList.append(newProd)
                                }
                            }
                            taskCallback(productList)
                        } else {
                            taskCallback([])
                        }
                    }
                } else {
                    // connection error
                    taskCallback([])
                }
            })
        }
    }
    
}

extension HLBarterScreenViewController: KDDragAndDropCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return myProducts.count
        case 2:
            return myTradedProducts.count
        case 3:
            return otherTradedProducts.count
        case 4:
            return otherProducts.count
        default:
            return 0
        }
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: HLProductCollectionViewCell
        
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell1", for: indexPath) as! HLProductCollectionViewCell
        case 2:
            product = myTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell2", for: indexPath) as! HLProductCollectionViewCell
        case 3:
            product = otherTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell3", for: indexPath) as! HLProductCollectionViewCell
        case 4:
            product = otherProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
        default:
            print("Error: no product found")
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
        }
        
        cell.label.text = product.productName
        //print(product.productImage)
        cell.image.loadImageFromURL(urlString: product.productImage)
        if (product.tradeStatus != 0){
            cell.statusImage.image = UIImage.init(named: arrowImagesName[product.tradeStatus])
        } else {
            cell.statusImage.image = nil
        }
        cell.isHidden = false
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.isHidden = true
                    
                }
            }
        }
        
        return cell
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
        case 2:
            product = myTradedProducts[indexPath.item]
        case 3:
            product = otherTradedProducts[indexPath.item]
        case 4:
            product = otherProducts[indexPath.item]
        default:
            product = HulaProduct(id : "nada", name : "Test product", image: "https://hula.trading/v1/products/59400e5ce8825609f281bc68/image")
        }
        return product
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? HulaProduct {
            switch collectionView.tag {
            case 1:
                myProducts.insert(di, at: indexPath.item)
            case 2:
                myTradedProducts.insert(di, at: indexPath.item)
            case 3:
                otherTradedProducts.insert(di, at: indexPath.item)
            case 4:
                otherProducts.insert(di, at: indexPath.item)
            default: break
            }
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {
        switch collectionView.tag {
        case 1:
            myProducts.remove( at: indexPath.item)
        case 2:
            myTradedProducts.remove( at: indexPath.item)
        case 3:
            otherTradedProducts.remove( at: indexPath.item)
        case 4:
            otherProducts.remove( at: indexPath.item)
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        let fromDataItem: HulaProduct
        switch collectionView.tag {
        case 1:
            fromDataItem = myProducts[from.item]
            myProducts.remove(at: from.item)
            myProducts.insert(fromDataItem, at: to.item)
        case 2:
            fromDataItem = myTradedProducts[from.item]
            myTradedProducts.remove(at: from.item)
            myTradedProducts.insert(fromDataItem, at: to.item)
        case 3:
            fromDataItem = otherTradedProducts[from.item]
            otherTradedProducts.remove(at: from.item)
            otherTradedProducts.insert(fromDataItem, at: to.item)
        case 4:
            fromDataItem = otherProducts[from.item]
            otherProducts.remove(at: from.item)
            otherProducts.insert(fromDataItem, at: to.item)
        default:
            print("No product found!")
            fromDataItem = myProducts[from.item]
            myProducts.remove(at: from.item)
            myProducts.insert(fromDataItem, at: to.item)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        if let candidate : HulaProduct = dataItem as? HulaProduct {
            let dataArr: [HulaProduct]
            switch collectionView.tag {
            case 1:
                dataArr = myProducts
            case 2:
                dataArr = myTradedProducts
            case 3:
                dataArr = otherTradedProducts
            case 4:
                dataArr = otherProducts
            default:
                dataArr = []
                
            }
            
            
            for item : HulaProduct in dataArr {
                if candidate  == item {
                    
                    let position = dataArr.index(of: item)! // ! if we are inside the condition we are guaranteed a position
                    let indexPath = IndexPath(item: position, section: 0)
                    return indexPath
                }
            }
        }
        
        return nil
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size: CGSize
        switch collectionView.tag {
        case 1:
            size = CGSize(width: collectionView.frame.size.width, height: 118)
        case 2:
            size = CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.width/3)
        case 3:
            size = CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.width/3)
        case 4:
            size = CGSize(width: collectionView.frame.size.width, height: 122)
        default:
            size = CGSize(width: collectionView.frame.size.width, height: 122)
        }
        return size
    }
    
}

