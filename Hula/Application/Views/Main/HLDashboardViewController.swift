//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import EasyTipView


class HLDashboardViewController: BaseViewController {
    
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var selectedBarter: Int = 0
    let productImagesWidth: CGFloat = 27.0
    let productImagesMargin: CGFloat = 10.0
    //var isExpandedFlowLayoutUsed:Bool = false
    var swappPageVC : HLSwappPageViewController?
    
    
    let sectionInsets = UIEdgeInsets(top: 4, left: 0, bottom: 30, right: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        mainCollectionView.collectionViewLayout = HLDashboardNormalViewFlowLayout()
        //refreshCollectionViewData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        mainCollectionView.frame = self.view.frame
        refreshCollectionViewData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
        mainCollectionView.collectionViewLayout.invalidateLayout()
        
        /*
        self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
        refreshCollectionViewData()
        
        self.mainCollectionView.reloadData()
        */
        
        
        
    }
    
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true) { 
            // After dismiss
        }
        
    }
    
    func rotated(){
        if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            mainCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func refreshCollectionViewData(){
        if let vc = self.parent as? HLSwappPageViewController {
            swappPageVC = vc
            if (HLDataManager.sharedInstance.arrCurrentTrades.count > 0){
                swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrCurrentTrades as [NSDictionary]
            }
            HLDataManager.sharedInstance.getTrades { (success) in
                if (success){
                    //print("Trades ok")
                    DispatchQueue.main.async {
                        self.swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrCurrentTrades as [NSDictionary]
                        self.mainCollectionView.reloadData()
                        self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
                    }
                    
                    
                    
                    // TUTORIAL
                    if let cell = self.mainCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HLTradesCollectionViewCell{  
                        if (HLDataManager.sharedInstance.arrCurrentTrades.count == 0){
                            // show empty rooms tutorial
                            if let _ = HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "dashboard_empty") as? String{
                                CommonUtils.sharedInstance.showTutorial(arrayTips: [
                                    HulaTip(delay: 1, view: cell.left_side, text: "You're in the Trade Room!\nto start trading, start exchanging."),
                                    HulaTip(delay: 0.5, view: self.mainCollectionView, text: "Need more trading rooms? tap here to add more spaces!")
                                ])
                                HLDataManager.sharedInstance.onboardingTutorials.setValue("done", forKey: "dashboard_empty")
                            }
                        } else {
                            // show full rooms tutorial
                            if let _ = HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "dashboard_full") as? String{
                                CommonUtils.sharedInstance.showTutorial(arrayTips: [
                                    HulaTip(delay: 1, view: cell.left_side, text: "Welcome to your first trade! Get some advice. Click on the Trade Room you used.")
                                    ])
                                HLDataManager.sharedInstance.onboardingTutorials.setValue("done", forKey: "dashboard_full")
                            }
                        }
                    }
                }
            }
            self.mainCollectionView.reloadData()
            //isExpandedFlowLayoutUsed = false
        } else {
            print("Error. Not detected parent parent vc")
        }
    }
    
    
    func closeTrade(_ tradeId: String){
        if (tradeId != ""){
            let queryURL = HulaConstants.apiURL + "trades/\(tradeId)"
            let status = HulaConstants.end_status
            let dataString:String = "status=\(status)"
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                if (ok){
                    //print(json!)
                    DispatchQueue.main.async {
                        /*
                        let alert = UIAlertController(title: "Your trade has been canceled",
                                                      message: "We have moved it to your trade history page, inside your profile section.",
                                                      preferredStyle: .alert )
                        let reportAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in
                            
                        })
                        alert.addAction(reportAction)
                        */
                        
                        
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                        
                        viewController.delegate = self
                        viewController.isCancelVisible = false
                        viewController.message = "Your trade is canceled.\nWe've moved it to your trade history section inside your profile."
                        
                        self.present(viewController, animated: true)
                        
                        
                        
                        
                        self.refreshCollectionViewData()
                    }
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
    
    func reportUser(_ userId:String){
        let queryURL = HulaConstants.apiURL + "users/report/\(userId)"
        //print(dataString)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                DispatchQueue.main.async {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self
                    viewController.isCancelVisible = false
                    viewController.message = "The user has been reported. We will review the user behavior and take necessary actions. Thanks for keeping Hula trustworthy."
                    
                    self.present(viewController, animated: true)
                    
                    
                    self.refreshCollectionViewData()
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
    
}

extension HLDashboardViewController: AlertDelegate{
    func alertResponded(response: String) {
        print("Response: \(response)")
        self.refreshCollectionViewData()
    }
}

extension HLDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max((swappPageVC?.arrTrades.count)!, HulaUser.sharedInstance.maxTrades)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row+1)"
        
        cell.dbDelegate = self
        
        //print(cell.frame)
        // Configure the cell
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){
            //print("Drawing row \(indexPath.row)")
            cell.isEmptyRoom = false
            let thisTrade : NSDictionary = (swappPageVC?.arrTrades[indexPath.row])!
            cell.emptyRoomLabel.text = ""
            //print(thisTrade)
            cell.tradeId = (thisTrade.object(forKey: "_id") as? String)!
            
            var otherUserId = thisTrade.object(forKey: "other_id") as? String
            if otherUserId == HulaUser.sharedInstance.userId {
                otherUserId = thisTrade.object(forKey: "owner_id") as? String
            }
            if( otherUserId != nil){
                cell.userImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: otherUserId!) )
                
            }
            
            cell.userId = otherUserId!;
            
            if (HulaUser.sharedInstance.userId == thisTrade.object(forKey: "other_id") as? String ){
                // i am the other of the trade
                if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: other_products_arr, side: "left")
                }
                if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: owner_products_arr, side: "right")
                }
            } else {
                if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: other_products_arr, side: "right")
                }
                if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: owner_products_arr, side: "left")
                }
            }
            
            cell.myImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: HulaUser.sharedInstance.userId))
            cell.myImage.isHidden = false
            cell.middleArrows.isHidden = false
            cell.tradeNumber.textColor = HulaConstants.appMainColor
            if let turnUser = thisTrade.object(forKey: "turn_user_id") as? String{
                if turnUser != HulaUser.sharedInstance.userId {
                    cell.myTurnView.isHidden = true
                    cell.otherTurnView.isHidden = false
                } else {
                    cell.myTurnView.isHidden = false
                    cell.otherTurnView.isHidden = true
                }
            } else {
                cell.myTurnView.isHidden = false
                cell.otherTurnView.isHidden = true
            }
            cell.boxView.layer.shadowColor = UIColor.black.cgColor
            cell.boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.boxView.layer.shadowOpacity = 0.2
            cell.boxView.layer.shadowRadius = 3
            cell.optionsDotsImage.alpha = 1
        } else {
            //print("Empty row \(indexPath.row)")
            cell.isEmptyRoom = true
            cell.tradeId = "";
            cell.emptyRoomLabel.text = "Empty Trade Room"
            cell.myImage.isHidden = true
            cell.userImage.image = nil
            cell.middleArrows.isHidden = true
            cell.left_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.right_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.tradeNumber.textColor = UIColor.gray
            cell.myTurnView.isHidden = true
            cell.otherTurnView.isHidden = true
            cell.boxView.layer.shadowColor = UIColor(red:1, green:1, blue:1, alpha: 0).cgColor
            cell.boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.boxView.layer.shadowOpacity = 0
            cell.boxView.layer.shadowRadius = 0
            cell.optionsDotsImage.alpha = 0.2
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        //print("Barter room clicked")
        //print(indexPath.row)
        
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){

            
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell", for: indexPath) as! HLTradesCollectionViewCell

            //isExpandedFlowLayoutUsed = !isExpandedFlowLayoutUsed
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                if let swappPageVC = self.parent as? HLSwappPageViewController{
                    self.selectedBarter = indexPath.row
                    let thisTrade: NSDictionary = swappPageVC.arrTrades[indexPath.row]
                    self.swappPageVC?.currentTrade = thisTrade
                    self.swappPageVC?.currentIndex = indexPath.row
                    //print(swappPageVC.currentTrade!)
                    
                    //always number 1
                    self.swappPageVC?.goTo(page: 1)
                }
                //print(self.parent!)
            }
            
        
        }
 
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //mainCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func drawProducts(inCell:HLTradesCollectionViewCell, fromArr: [String], side: String){
        var counter:Int = 0;
        if (side=="right"){
            inCell.right_side.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            inCell.left_side.subviews.forEach({ $0.removeFromSuperview() })
        }
        let verticalCenter:CGFloat = (59.0/2) - productImagesWidth/2;
        for img in fromArr {
            if (img != ""){
                let newImg = UIImageView()
                if (side=="right"){
                    newImg.frame = CGRect(x: ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) + productImagesMargin*2,
                                          y: verticalCenter,
                                          width: productImagesWidth,
                                          height: productImagesWidth)
                    inCell.right_side.addSubview(newImg)
                } else {
                    newImg.frame = CGRect(x: inCell.left_side.frame.width - ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) - (productImagesMargin) - productImagesWidth,
                                          y: verticalCenter,
                                          width: productImagesWidth,
                                          height: productImagesWidth)
                    inCell.left_side.addSubview(newImg)
                    
                    
                    /*
                    
                    let horizontalConstraint = NSLayoutConstraint(item: newImg, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: inCell.left_side, attribute: NSLayoutAttribute.right, multiplier: 1, constant:  -( ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) - (productImagesMargin) - productImagesWidth))
                    
                    NSLayoutConstraint.activate([horizontalConstraint])
                    */
                }
                
                let thumb = commonUtils.getThumbFor(url: HulaConstants.apiURL + "products/\(img)/image")
                newImg.loadImageFromURL(urlString: thumb)
                

                
                
                counter += 1
            }
        }
    }
    
}
/*
extension HLDashboardViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        return CGSize(width: availableWidth, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
 */
