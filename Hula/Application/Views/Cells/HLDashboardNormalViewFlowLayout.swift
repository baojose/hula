//
//  HLDashboardNormalViewFlowLayout.swift
//  Hula
//
//  Created by Juan Searle on 17/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDashboardNormalViewFlowLayout: UICollectionViewFlowLayout {
    let itemHeight: CGFloat = 70
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    /**
     Sets up the layout for the collectionView. 1pt distance between each cell and 1pt distance between each row plus use a vertical layout
     */
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .vertical
    }
    
    func itemWidth() -> CGFloat {
        return collectionView!.frame.width - 1
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width:itemWidth(), height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight)
        }
    }
    /*
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
 */
    
    override func prepare() {
        self.scrollDirection = .vertical
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: self.minimumLineSpacing, right: 0)
        let collectionViewWidth = self.collectionView?.bounds.size.width ?? 0
        self.headerReferenceSize = CGSize(width: collectionViewWidth, height: 5)
        
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return true
    }
}
