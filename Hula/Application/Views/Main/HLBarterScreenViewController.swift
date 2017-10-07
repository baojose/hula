//
//  HLBarterScreenViewController.swift
//  Hula
//
//  Created by Juan Searle on 13/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLBarterScreenViewController: BaseViewController {
    
    
    @IBOutlet weak var moneyBtn: UIButton!
    
    @IBOutlet weak var sectionCover: UIButton!
    @IBOutlet weak var otherProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var otherSelectedProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var myProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var mySelectedProductsCollection: KDDragAndDropCollectionView!
    
    @IBOutlet weak var ChatFakeView: UIView!
    
    @IBOutlet weak var rightBackground: UIView!
    @IBOutlet weak var leftBackground: UIView!
    @IBOutlet weak var otherProductsDragView: UIImageView!
    @IBOutlet weak var myProductsDragView: UIImageView!
    
    @IBOutlet weak var addMoneyBtn2: UIButton!
    @IBOutlet weak var addMoneyBtn1: UIButton!
    @IBOutlet weak var sendOfferFakeView: UIView!
    
    @IBOutlet weak var otherProductsLabel: UILabel!
    @IBOutlet weak var myProductsLabel: UILabel!
    
    var myProducts : [HulaProduct] = []
    var otherProducts : [HulaProduct] = []
    var myTradedProducts : [HulaProduct] = []
    var otherTradedProducts : [HulaProduct] = []
    var myProductsDiff : [String] = []
    var otherProductsDiff : [String] = []
    var myTradeIndex: Int = 1
    
    var mainSwapViewHolder: HLSwappViewController?
    
    var thisTrade: HulaTrade = HulaTrade()
    
    let arrowImagesName = ["","icon-product-added", "icon-product-removed", "icon-product-multipledeals"]
    
    var otherUserId: String = ""
    
    var didTradeMutate:Bool = false
    
    var dragAndDropManager1 : KDDragAndDropManager?
    var dragAndDropManager2 : KDDragAndDropManager?
    var alreadyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        otherProductsLabel.isHidden = true
        myProductsLabel.isHidden = true
        otherProductsDragView.isHidden = true
        myProductsDragView.isHidden = true
        
        
        
        
        
        // draw borders on collectionviews
        let border = UIView()
        border.frame = CGRect(x:myProductsCollection.frame.width-1, y: 0, width: 1, height: self.view.frame.height)
        border.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.view.addSubview(border)
        let border2 = UIView()
        border2.frame = CGRect(x: self.view.frame.width - otherProductsCollection.frame.width, y: 0, width: 1, height: self.view.frame.height)
        border2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.view.addSubview(border2)
        
        
        // tag each collectionview
        otherSelectedProductsCollection.currentSide = "otherSide"
        mySelectedProductsCollection.currentSide = "mySide"
        myProductsCollection.currentSide = "-"
        otherProductsCollection.currentSide = "-"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProductsArrays(){
        alreadyLoaded = true
        var mtp:[String] = []
        var otp:[String] = []
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            
            //print(swappPageVC.parent)
            
            myTradeIndex = min(swappPageVC.currentIndex, swappPageVC.arrTrades.count)
            
            let ct = swappPageVC.arrTrades[swappPageVC.currentIndex]
            //print("ct \(ct)")
            thisTrade.loadFrom(dict: ct)
            if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                // I am the owner
                mtp = thisTrade.owner_products
                otp = thisTrade.other_products
                otherUserId = thisTrade.other_id
                
            } else {
                // I am the other
                otp = thisTrade.owner_products
                mtp = thisTrade.other_products
                otherUserId = thisTrade.owner_id
            }
            
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId{
                // my turn
                self.sectionCover.isHidden = true
                self.myProductsCollection.isUserInteractionEnabled = true
                self.mySelectedProductsCollection.isUserInteractionEnabled = true
                self.otherProductsCollection.isUserInteractionEnabled = true
                self.otherSelectedProductsCollection.isUserInteractionEnabled = true
                self.addMoneyBtn1.isUserInteractionEnabled = true
                self.addMoneyBtn2.isUserInteractionEnabled = true
                
                
            } else {
                self.sectionCover.isHidden = false
                self.myProductsCollection.isUserInteractionEnabled = false
                self.mySelectedProductsCollection.isUserInteractionEnabled = false
                self.otherProductsCollection.isUserInteractionEnabled = false
                self.otherSelectedProductsCollection.isUserInteractionEnabled = false
                self.addMoneyBtn1.isUserInteractionEnabled = false
                self.addMoneyBtn2.isUserInteractionEnabled = false
                
            }
            //print(otp)
            //print(mtp)
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
            HulaTrade.sharedInstance.owner_products = thisTrade.owner_products
            HulaTrade.sharedInstance.other_products = thisTrade.other_products
            
            
            
            
            print(thisTrade.other_money)
            print(thisTrade.owner_money)
            
            
            if (self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId && thisTrade.num_bids == 1){
                // first turn
                self.addMoneyBtn1.alpha = 0
                self.addMoneyBtn2.alpha = 0
                self.myProductsCollection.isUserInteractionEnabled = false
                self.mySelectedProductsCollection.isUserInteractionEnabled = false
            } else {
                self.addMoneyBtn1.alpha = 1
                self.addMoneyBtn2.alpha = 1
            }
            
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId && thisTrade.num_bids != 1 {
                // my draganddrop
                self.dragAndDropManager2 = KDDragAndDropManager(canvas: self.view, collectionViews: [myProductsCollection, mySelectedProductsCollection ])
            }
            
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId {
                // other draganddrop
                self.dragAndDropManager1 = KDDragAndDropManager(canvas: self.view, collectionViews: [otherProductsCollection, otherSelectedProductsCollection ])
            }
            
            
            // TUTORIAL
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId{
                // my turn
                if let _ = HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "barter_my_turn") as? String{
                } else {
                    CommonUtils.sharedInstance.showTutorial(arrayTips: [
                        HulaTip(delay: 2, view: self.otherProductsCollection, text: "Here is their stuff. Drag & drop what you want. Click on the product to get more info."),
                        HulaTip(delay: 0.4, view: self.myProductsCollection, text: "Here is your stuff."),
                        HulaTip(delay: 0.4, view: self.sendOfferFakeView, text: "Once you select what you want, find out if the other trader interested. Click the button below to send a notification!")
                        ])
                    print(HLDataManager.sharedInstance.onboardingTutorials)
                    HLDataManager.sharedInstance.onboardingTutorials.setObject("done", forKey: "barter_my_turn" as NSCopying)
                }
            } else {
                // other's turn
                if let _ = HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "barter_other_turn") as? String{
                } else {
                    CommonUtils.sharedInstance.showTutorial(arrayTips: [
                        HulaTip(delay: 2, view: self.myProductsCollection, text: "This trading is waiting for the other user to select the items he wants. As soon as the offer is ready you will be notified"),
                        HulaTip(delay: 0.4, view: self.moneyBtn, text: "Add money here"),
                        HulaTip(delay: 0.4, view: self.ChatFakeView, text: "Start chat here")
                        ])
                    HLDataManager.sharedInstance.onboardingTutorials.setValue("done", forKey: "barter_other_turn")
                }
            }
            
            
            if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                self.mainSwapViewHolder = thisHolderScreen
                self.mainSwapViewHolder?.barterDelegate = self
                self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
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
        
        //print(thisTrade.last_bid_diff)
        for pr_id in list{
            for pr in reference_list{
                if pr.productId == pr_id{
                    
                    final_arr.append(pr)
                }
            }
            
            if (self.otherProducts.count > 0){
                for i in 0 ... (self.otherProducts.count - 1) {
                    if (self.otherProducts[i].productId == pr_id){
                        self.otherProducts.remove( at: i)
                    }
                    if (i >= self.otherProducts.count - 1){
                        break
                    }
                }
            }
            if (self.myProducts.count > 0){
                for i in 0 ... (self.myProducts.count - 1) {
                    if (self.myProducts[i].productId == pr_id){
                        self.myProducts.remove( at: i)
                    }
                    if (i >= self.myProducts.count - 1){
                        break
                    }
                }
            }
        }
        
        
        switch type {
        case "other":
            if thisTrade.other_money > 0 {
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.other_money)))", image: "")
                final_arr.append(moneyProd)
            }
            otherTradedProducts = final_arr
        default:
            if thisTrade.owner_money > 0 {
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\( Int(round(thisTrade.owner_money)) )", image: "")
                final_arr.append(moneyProd)
            }
            myTradedProducts = final_arr
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !alreadyLoaded{
            loadProductsArrays();
        }
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                thisHolderScreen.last_index_setup = 1
            }
        }
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
                            
                            //print(self.thisTrade.last_bid_diff)
                            
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
                                    newProd.populate(with: product_data as NSDictionary)
                                    
                                    for difprod in self.thisTrade.last_bid_diff {
                                        if (difprod == newProd.productId!){
                                            // recently added
                                            newProd.tradeStatus = 1
                                        }
                                        if (difprod == "-\(newProd.productId!)"){
                                            // recently removed
                                            newProd.tradeStatus = 2
                                        }
                                    }
                                    
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
    
    func generateProductArray(from:[HulaProduct]) -> [String]{
        var final_arr = [String]();
        
        for prod in from {
            if (prod.productId != "xmoney"){
                final_arr.append(prod.productId)
            }
        }
        //print(final_arr)
        return final_arr
    }
    
    @IBAction func addMoneyToOther(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "calculatorView") as! HLCalculatorViewController
        
        viewController.calculatorDelegate = self
        viewController.side = "other"
        
        self.present(viewController, animated: true)
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
    }
    
    @IBAction func addMonewToOwner(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "calculatorView") as! HLCalculatorViewController
        
        viewController.calculatorDelegate = self
        viewController.side = "owner"
        self.present(viewController, animated: true)
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection: \(collectionView.tag) item \(indexPath.item)")
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
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
        }
        //print(product)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProductModal") as! HLProductModalViewController
        
        viewController.product = product
        viewController.modalPresentationStyle = .overCurrentContext
        
        self.present(viewController, animated: true)
        print("presented vc")
        
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: HLProductCollectionViewCell
    
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell1", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "left"
            cell.type = "user"
        case 2:
            product = myTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell2", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "left"
            cell.type = "select"
        case 3:
            product = otherTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell3", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "right"
            cell.type = "select"
        case 4:
            
            product = otherProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "right"
            cell.type = "user"
        default:
            print("Error: no product found")
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
        }
        
        cell.label.text = product.productName
        //print(product.productImage)
        
        let thumb = commonUtils.getThumbFor(url: product.productImage)
        cell.image.loadImageFromURL(urlString: thumb)
        //print(product.tradeStatus)
        if (product.tradeStatus != 0){
            
            
            //cell.statusImage.image = UIImage.init(named: arrowImagesName[product.tradeStatus])
            
            if (product.tradeStatus == 1){
                cell.is_added()
            } else {
                cell.is_removed()
            }
            
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
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
        
        
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
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
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
        
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
        
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
            size = CGSize(width: collectionView.frame.size.width, height: 122)
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

extension HLBarterScreenViewController: HLBarterScreenDelegate{
    func getCurrentTradeStatus() -> HulaTrade{
        let trade = HulaTrade();
        //print(myTradedProducts)
        if thisTrade.owner_id == HulaUser.sharedInstance.userId {
            // my trade
            trade.other_products = generateProductArray(from: otherTradedProducts)
            trade.owner_products = generateProductArray(from: myTradedProducts)
            
        } else {
            // other user trade
            trade.other_products = generateProductArray(from: myTradedProducts)
            trade.owner_products = generateProductArray(from: otherTradedProducts)
        }
        
        trade.turn_user_id = thisTrade.turn_user_id
        trade.tradeId = thisTrade.tradeId
        trade.owner_money = thisTrade.owner_money
        trade.other_money = thisTrade.other_money
        return trade
    }
    
    func isTradeMutated() -> Bool!{
        return self.didTradeMutate
    }
    
    func reloadTrade(){
        self.alreadyLoaded = false
    }
}

extension HLBarterScreenViewController: CalculatorDelegate{
    
    func amountSelected(amount:Int, side:String){
        print("Calculator amount: \(amount)")
        if (amount > 0){
            if (side == "owner"){
                thisTrade.owner_money = Float((amount))
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\( Int(round(thisTrade.owner_money)) )", image: HulaConstants.transparentImg)
                self.myTradedProducts.append(moneyProd)
                self.mySelectedProductsCollection.reloadData()
            } else {
                thisTrade.other_money = Float((amount))
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\( Int(round(thisTrade.other_money)) )", image: HulaConstants.transparentImg)
                self.otherTradedProducts.append(moneyProd)
                self.otherSelectedProductsCollection.reloadData()
            }
        }
    }
}
