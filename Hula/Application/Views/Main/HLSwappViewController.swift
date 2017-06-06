//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSwappViewController: UIViewController {
    
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var initialCoverView: UIImageView!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var hisProfileImage: UIImageView!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var hisProfileLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var hisTableView: UITableView!
    @IBOutlet weak var mainPageControl: UIPageControl!
    @IBOutlet weak var myMoneyBtn: UIButton!
    @IBOutlet weak var hisMoneyBtn: UIButton!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        CommonUtils.sharedInstance.circleImageView(myProfileImage)
        CommonUtils.sharedInstance.circleImageView(hisProfileImage)
        myProfileLabel.text = HulaUser.sharedInstance.userNick
        CommonUtils.sharedInstance.loadImageOnView(imageView:myProfileImage, withURL:HulaUser.sharedInstance.userPhotoURL)
        
        rotated()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.initialCoverView.center.y += 1000
            self.initialCoverView.transform = CGAffineTransform(rotationAngle: 0.8)
        }
        myTableView.center.x = -300
        hisTableView.center.x = 1000
        myMoneyBtn.isHidden = true
        hisMoneyBtn.isHidden = true
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
    @IBAction func closeSwappInterfaceAction(_ sender: Any) {
        portraitView.isHidden = false
        landscapeView.isHidden = true
        
    }
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("portrait")
            portraitView.isHidden = false
            landscapeView.isHidden = true
            self.dismiss(animated: true) {
                // After dismiss
            }
        } else {
            print("landscape")
            portraitView.isHidden = true
            landscapeView.isHidden = false
        }
    }
}


extension HLSwappViewController: UITableViewDelegate, UITableViewDataSource {
    //#MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 110.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HulaUser.sharedInstance.arrayProducts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HLSwappProductTableViewCell;
        if (tableView.dequeueReusableCell(withIdentifier: "swappcell") as? HLSwappProductTableViewCell) != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "swappcell") as! HLSwappProductTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "swappcell2") as! HLSwappProductTableViewCell
        }
        
        let product : NSDictionary = HulaUser.sharedInstance.arrayProducts[indexPath.row] as! NSDictionary
        //print(product)
        if let productTitle = product.object(forKey: "title") as? String {
            cell.productName.text = productTitle
        } else {
            cell.productName.text = "Untitled product"
        }
        
        if let productImage = product.object(forKey: "image_url") as? String {
            CommonUtils.sharedInstance.loadImageOnView(imageView:cell.productImage, withURL:productImage)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension HLSwappViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row)"
        // Configure the cell
        return cell
    }
}
extension HLSwappViewController : UICollectionViewDelegateFlowLayout {
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
