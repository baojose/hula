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
    let productImagesWidth: CGFloat = 35.0
    
    
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (HLDataManager.sharedInstance.arrTrades.count > 0){
            self.arrTrades = HLDataManager.sharedInstance.arrTrades
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.initialCoverView.center.y += 1000
            self.initialCoverView.transform = CGAffineTransform(rotationAngle: 0.8)
        }
        HLDataManager.sharedInstance.getTrades { (success) in
            if (success){
                self.arrTrades = HLDataManager.sharedInstance.arrTrades
                print("Trades ok")
                //print(self.arrTrades)
                self.mainCollectionView.reloadData()
            }
        }
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
        return max(self.arrTrades.count, 5)
    }
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row+1)"
        // Configure the cell
        if (self.arrTrades.count > indexPath.row){
            let thisTrade : NSDictionary = self.arrTrades.object(at: indexPath.row) as! NSDictionary
            cell.emptyRoomLabel.text = ""
            print(thisTrade)
            var otherUserId = thisTrade.object(forKey: "other_id") as? String
            if otherUserId == HulaUser.sharedInstance.userId {
                otherUserId = thisTrade.object(forKey: "owner_id") as? String
            }
            if( otherUserId != nil){
                cell.userImage.loadImageFromURL(urlString: HulaConstants.apiURL + "users/\(otherUserId!)/image")
            }
            if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                var counter:Int = 0;
                for img in other_products_arr {
                    let newImg = UIImageView()
                    
                    newImg.frame = CGRect(x: cell.frame.width/2 + ( CGFloat(counter) * (productImagesWidth * 10)) + 20, y: cell.frame.height/2 - productImagesWidth/2, width: productImagesWidth, height: productImagesWidth)
                    newImg.loadImageFromURL(urlString: HulaConstants.apiURL + "products/\(img)/image")
                    cell.addSubview(newImg)
                    counter += 1
                }
            }
            if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                var counter:Int = 0;
                for img in owner_products_arr {
                    let newImg = UIImageView()
                    
                    newImg.frame = CGRect(x: cell.frame.width/2 - ( CGFloat(counter) * (productImagesWidth * 10)) - 20, y: cell.frame.height/2 - productImagesWidth/2, width: productImagesWidth, height: productImagesWidth)
                    newImg.loadImageFromURL(urlString: HulaConstants.apiURL + "products/\(img)/image")
                    cell.addSubview(newImg)
                    counter += 1
                }
            }
            
            cell.middleArrows.isHidden = false
        } else {
            
            cell.userImage.image = nil
            cell.middleArrows.isHidden = true
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        print("Barter room clicked")
        print(indexPath.row)
        
        //mainCollectionView.collectionViewLayout.prepareForTransition(from: HLDashboardExpandedViewFlowLayout())
        
        //mainCollectionView.collectionViewLayout = HLDashboardExpandedViewFlowLayout()
        
        
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            selectedBarter = indexPath.row
            swappPageVC.goTo(page: selectedBarter + 1)
        }
        print(self.parent!)
 
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        mainCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}
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
