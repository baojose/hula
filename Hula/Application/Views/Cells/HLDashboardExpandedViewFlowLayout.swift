//
//  HLDashboardExpandedViewFlowLayout.swift
//  Hula
//
//  Created by Juan Searle on 17/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDashboardExpandedViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        
        self.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0)
        
        let collectionViewWidth =
            self.collectionView?.bounds.size.width
        
        let itemWidth : CGFloat = collectionViewWidth!
        
        self.itemSize = CGSize(width:itemWidth,
                               height: self.collectionView!.frame.height * 0.80)
        
    }
}
