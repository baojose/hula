//
//  HLPageControl.swift
//  Hula
//
//  Created by Juan Searle on 2/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLPageControl: UIPageControl {

    var homeIcon: UIImage?
    var homeSelIcon: UIImage?
    var pageCircle: UIImage?
    var pageSelCircle: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyCatalogImages()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyCatalogImages()
    }

    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
        applyCatalogImages()
    }

    func applyCatalogImages() {
        guard let images = PageControlPolicy.catalogImages(
            home: UIImage(named: "house-sel-icon"),
            homeSelected: UIImage(named: "home-icon"),
            page: UIImage(named: "page-icon"),
            pageSelected: UIImage(named: "page-sel-icon")
        ) else {
            homeIcon = nil
            homeSelIcon = nil
            pageCircle = nil
            pageSelCircle = nil
            return
        }
        homeIcon = images.home
        homeSelIcon = images.homeSelected
        pageCircle = images.page
        pageSelCircle = images.pageSelected
    }

    /// Per-dot icons used `imageView!` after creating the view. Missing dots
    /// must skip instead of crashing the trade-room pager.
    class func dotImage(
        index: Int,
        currentPage: Int,
        homeIcon: UIImage,
        homeSelIcon: UIImage,
        pageCircle: UIImage,
        pageSelCircle: UIImage
    ) -> UIImage {
        return PageControlPolicy.dotImage(
            index: index,
            currentPage: currentPage,
            homeIcon: homeIcon,
            homeSelIcon: homeSelIcon,
            pageCircle: pageCircle,
            pageSelCircle: pageSelCircle
        )
    }

    class func resolvedDotImageView(existing: UIImageView?) -> UIImageView {
        return PageControlPolicy.resolvedDotImageView(existing: existing)
    }

    func updateDots() {
        guard let homeIcon = homeIcon,
            let homeSelIcon = homeSelIcon,
            let pageCircle = pageCircle,
            let pageSelCircle = pageSelCircle else {
            return
        }
        var i = 0
        for view in self.subviews {
            let existing = self.imageView(forSubview: view)
            let imageView = HLPageControl.resolvedDotImageView(existing: existing)
            if existing == nil {
                imageView.center = view.center
                view.addSubview(imageView)
                view.clipsToBounds = false
            }
            imageView.image = HLPageControl.dotImage(
                index: i,
                currentPage: self.currentPage,
                homeIcon: homeIcon,
                homeSelIcon: homeSelIcon,
                pageCircle: pageCircle,
                pageSelCircle: pageSelCircle
            )
            i += 1
        }
    }

    fileprivate func imageView(forSubview view: UIView) -> UIImageView? {
        var dot: UIImageView?
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        return dot
    }

}
