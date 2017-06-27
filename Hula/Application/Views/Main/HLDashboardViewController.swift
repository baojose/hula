//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDashboardViewController: UIViewController {
    
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var initialCoverView: UIImageView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var selectedBarter: Int = 0
    var arrTrades: NSMutableArray = []
    let productImagesWidth: CGFloat = 27.0
    var isExpandedFlowLayoutUsed:Bool = false
    
    
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (HLDataManager.sharedInstance.arrTrades.count > 0){
            self.arrTrades = HLDataManager.sharedInstance.arrTrades
        }
        HLDataManager.sharedInstance.getTrades { (success) in
            if (success){
                //print("Trades ok")
                if (self.arrTrades.count != HLDataManager.sharedInstance.arrTrades.count){
                    self.arrTrades = HLDataManager.sharedInstance.arrTrades
                    self.mainCollectionView.reloadData()
                } else {
                    self.arrTrades = HLDataManager.sharedInstance.arrTrades
                }
            }
        }
        mainCollectionView.collectionViewLayout = HLDashboardNormalViewFlowLayout()
        isExpandedFlowLayoutUsed = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.initialCoverView.center.y += 1000
            self.initialCoverView.transform = CGAffineTransform(rotationAngle: 0.8)
        }
        self.mainCollectionView.reloadData()
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
        self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
        self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: false)
        isExpandedFlowLayoutUsed = false
    }
    override func viewDidAppear(_ animated: Bool) {
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
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
}



extension HLDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(self.arrTrades.count, HulaUser.sharedInstance.maxTrades)
    }
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row+1)"
        
        // Configure the cell
        if (self.arrTrades.count > indexPath.row){
            //print("Drawing row \(indexPath.row)")
            let thisTrade : NSDictionary = self.arrTrades.object(at: indexPath.row) as! NSDictionary
            cell.emptyRoomLabel.text = ""
            //print(thisTrade)
            var otherUserId = thisTrade.object(forKey: "other_id") as? String
            if otherUserId == HulaUser.sharedInstance.userId {
                otherUserId = thisTrade.object(forKey: "owner_id") as? String
            }
            if( otherUserId != nil){
                cell.userImage.loadImageFromURL(urlString: HulaConstants.apiURL + "users/\(otherUserId!)/image")
                
            }
            if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                drawProducts(inCell: cell, fromArr: other_products_arr, side: "right")
            }
            if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                drawProducts(inCell: cell, fromArr: owner_products_arr, side: "left")
            }
            //CommonUtils.sharedInstance.loadImageOnView(imageView:cell.myImage, withURL:HulaUser.sharedInstance.userPhotoURL)
            
            cell.myImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
            print(HulaUser.sharedInstance.userPhotoURL)
            cell.myImage.isHidden = false
            cell.middleArrows.isHidden = false
            cell.optionsDotsImage.isHidden = false
            cell.tradeNumber.textColor = HulaConstants.appMainColor
            if let turnUser = thisTrade.object(forKey: "turn_user_id") as? String{
                if turnUser == otherUserId {
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
        } else {
            //print("Empty row \(indexPath.row)")
            cell.emptyRoomLabel.text = "Empty Trade Room"
            cell.myImage.isHidden = true
            cell.optionsDotsImage.isHidden = true
            cell.userImage.image = nil
            cell.middleArrows.isHidden = true
            cell.left_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.right_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.tradeNumber.textColor = UIColor.gray
            cell.myTurnView.isHidden = true
            cell.otherTurnView.isHidden = true
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        print("Barter room clicked")
        //print(indexPath.row)
        
        if (self.arrTrades.count > indexPath.row){
        
            
            isExpandedFlowLayoutUsed = !isExpandedFlowLayoutUsed
            
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.mainCollectionView.collectionViewLayout.invalidateLayout()
                UIScreen.main.snapshotView(afterScreenUpdates: true)
                if(self.isExpandedFlowLayoutUsed){
                    self.mainCollectionView.setCollectionViewLayout(HLDashboardExpandedViewFlowLayout(), animated: false)
                } else {
                    self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
                }
                self.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            })
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                if let swappPageVC = self.parent as? HLSwappPageViewController{
                    self.selectedBarter = indexPath.row
                    let thisTrade = self.arrTrades.object(at: indexPath.row) as? NSDictionary
                    swappPageVC.currentTrade = thisTrade
                    print(swappPageVC.currentTrade!)
                    swappPageVC.goTo(page: self.selectedBarter + 1)
                }
                //print(self.parent!)
            }
            
        
        }
 
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        mainCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    func drawProducts(inCell:HLTradesCollectionViewCell, fromArr: [String], side: String){
        var counter:Int = 0;
        
        if (side=="right"){
            inCell.right_side.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            inCell.left_side.subviews.forEach({ $0.removeFromSuperview() })
        }
        for img in fromArr {
            let newImg = UIImageView()
            if (side=="right"){
                newImg.frame = CGRect(x: ( CGFloat(counter) * (productImagesWidth * 10)) + 20, y: 70.0/2 - productImagesWidth/2, width: productImagesWidth, height: productImagesWidth)
                inCell.right_side.addSubview(newImg)
            } else {
                newImg.frame = CGRect(x: inCell.left_side.frame.width - ( CGFloat(counter) * (productImagesWidth * 10)) - 20, y: 70.0/2 - productImagesWidth/2, width: productImagesWidth, height: productImagesWidth)
                inCell.left_side.addSubview(newImg)
            }
            newImg.loadImageFromURL(urlString: HulaConstants.apiURL + "products/\(img)/image")
            counter += 1
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
