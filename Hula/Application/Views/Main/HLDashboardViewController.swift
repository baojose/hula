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
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var selectedBarter: Int = 0
    let productImagesWidth: CGFloat = 27.0
    let productImagesMargin: CGFloat = 10.0
    var isExpandedFlowLayoutUsed:Bool = false
    var swappPageVC : HLSwappPageViewController?
    
    
    let sectionInsets = UIEdgeInsets(top: 4, left: 0, bottom: 30, right: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCollectionViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainCollectionView.frame = self.view.frame
        self.mainCollectionView.reloadData()
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
        
        self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
        //self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: false)
        isExpandedFlowLayoutUsed = false
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
        refreshCollectionViewData()
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
    
    func refreshCollectionViewData(){
        if let vc = self.parent as? HLSwappPageViewController {
            swappPageVC = vc
            if (HLDataManager.sharedInstance.arrTrades.count > 0){
                swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrTrades as [NSDictionary]
            }
            HLDataManager.sharedInstance.getTrades { (success) in
                if (success){
                    //print("Trades ok")
                    DispatchQueue.main.async {
                        if (self.swappPageVC?.arrTrades.count != HLDataManager.sharedInstance.arrTrades.count){
                            self.swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrTrades as [NSDictionary]
                            self.mainCollectionView.reloadData()
                        } else {
                            self.swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrTrades as [NSDictionary]
                        }
                    }
                }
            }
            //mainCollectionView.collectionViewLayout = HLDashboardNormalViewFlowLayout()
            isExpandedFlowLayoutUsed = false
        } else {
            print("Error. Not detected parent parent vc")
        }
    }
}



extension HLDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max((swappPageVC?.arrTrades.count)!, HulaUser.sharedInstance.maxTrades)
    }
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row+1)"
        
        // Configure the cell
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){
            //print("Drawing row \(indexPath.row)")
            cell.isEmptyRoom = false
            let thisTrade : NSDictionary = (swappPageVC?.arrTrades[indexPath.row])!
            cell.emptyRoomLabel.text = ""
            //print(thisTrade)
            var otherUserId = thisTrade.object(forKey: "other_id") as? String
            if otherUserId == HulaUser.sharedInstance.userId {
                otherUserId = thisTrade.object(forKey: "owner_id") as? String
            }
            if( otherUserId != nil){
                cell.userImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: otherUserId!) )
                
            }
            
            // Todo: switch sides if i am not the owner!
            if (HulaUser.sharedInstance.userId == otherUserId){
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
            //CommonUtils.sharedInstance.loadImageOnView(imageView:cell.myImage, withURL:HulaUser.sharedInstance.userPhotoURL)
            
            cell.myImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
            //print(HulaUser.sharedInstance.userPhotoURL)
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
            cell.awakeFromNib()
        } else {
            //print("Empty row \(indexPath.row)")
            cell.isEmptyRoom = true
            cell.emptyRoomLabel.text = "Empty Trade Room"
            cell.myImage.isHidden = true
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
        
        
        //print("Barter room clicked")
        //print(indexPath.row)
        
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){

            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                          for: indexPath) as! HLTradesCollectionViewCell
            cell.layer.zPosition = 100;
            
            isExpandedFlowLayoutUsed = !isExpandedFlowLayoutUsed
            let when = DispatchTime.now() + 0.3
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
        let verticalCenter:CGFloat = (70.0/2) - productImagesWidth/2;
        for img in fromArr {
            if (img != ""){
                let newImg = UIImageView()
                if (side=="right"){
                    newImg.frame = CGRect(x: ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) + productImagesMargin,
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
                newImg.loadImageFromURL(urlString: HulaConstants.apiURL + "products/\(img)/image")
                

                
                
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
