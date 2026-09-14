//
//  HLDragableImage.swift
//  Hula
//
//  Created by Juan Searle on 28/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDragableImage: UIImageView {
    
    var dragStartPositionRelativeToCenter : CGPoint?
    var initialPoint: CGPoint?
    var item: Int = 0
    
    weak var delegate:DraggableProductDelegate?
    
    override init(image: UIImage!) {
        super.init(image: image)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.isUserInteractionEnabled = true   //< w00000t!!!1
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(nizer:))))

        initialPoint = self.center
    }

    class func relativeOffset(location: CGPoint, center: CGPoint) -> CGPoint {
        return CashChipDragPolicy.relativeOffset(location: location, center: center)
    }

    class func shouldSnapBack(isEnded: Bool, alpha: CGFloat) -> Bool {
        return CashChipDragPolicy.shouldSnapBack(isEnded: isEnded, alpha: alpha)
    }

    class func snapBackCenter(initialPoint: CGPoint?) -> CGPoint? {
        return CashChipDragPolicy.snapBackCenter(initialPoint: initialPoint)
    }

    class func shouldDrop(center: CGPoint, initialPoint: CGPoint?) -> Bool {
        return CashChipDragPolicy.shouldDrop(center: center, initialPoint: initialPoint)
    }

    class func movedCenter(location: CGPoint, relativeToCenter: CGPoint?) -> CGPoint? {
        return CashChipDragPolicy.movedCenter(location: location, relativeToCenter: relativeToCenter)
    }
    
    func handlePan(nizer: UIPanGestureRecognizer!) {
        let locationInView = nizer.location(in: superview)
        if nizer.state == UIGestureRecognizerState.began {
            dragStartPositionRelativeToCenter = CashChipDragPolicy.relativeOffset(
                location: locationInView,
                center: center
            )
            return
        }
        
        if CashChipDragPolicy.shouldSnapBack(
            isEnded: nizer.state == UIGestureRecognizerState.ended,
            alpha: self.alpha
        ) {
            dragStartPositionRelativeToCenter = nil
            if let origin = CashChipDragPolicy.snapBackCenter(initialPoint: self.initialPoint) {
                UIView.animate(withDuration: 0.2) {
                    self.center = origin
                }
            }
            return
        }
        
        if CashChipDragPolicy.shouldDrop(center: self.center, initialPoint: self.initialPoint) {
            if let origin = CashChipDragPolicy.snapBackCenter(initialPoint: self.initialPoint) {
                UIView.animate(withDuration: 0.2) {
                    self.center = origin
                    self.alpha = 0
                }
            } else {
                self.alpha = 0
            }
            delegate?.productDropped(image: self, item: item)
            return
        }
        
        if let nextCenter = CashChipDragPolicy.movedCenter(
            location: locationInView,
            relativeToCenter: dragStartPositionRelativeToCenter
        ) {
            UIView.animate(withDuration: 0.1) {
                self.center = nextCenter
            }
        }
    }
 
 
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol DraggableProductDelegate: class {
    func productDropped(image: HLDragableImage, item: Int)
}

/// Cash-chip pan used `initialPoint!` and `dragStartPositionRelativeToCenter!`.
/// A `.changed` without `.began`, or an ended gesture after those optionals
/// were cleared, crashed and could leave trade cash stuck on screen.
struct CashChipDragPolicy {
    static let dropDistance: CGFloat = 15

    static func relativeOffset(location: CGPoint, center: CGPoint) -> CGPoint {
        return CGPoint(x: location.x - center.x, y: location.y - center.y)
    }

    static func shouldSnapBack(isEnded: Bool, alpha: CGFloat) -> Bool {
        return isEnded || alpha == 0
    }

    static func snapBackCenter(initialPoint: CGPoint?) -> CGPoint? {
        return initialPoint
    }

    static func shouldDrop(center: CGPoint, initialPoint: CGPoint?) -> Bool {
        guard let initialPoint = initialPoint else {
            return false
        }
        return abs(center.x - initialPoint.x) > dropDistance
    }

    static func movedCenter(location: CGPoint, relativeToCenter: CGPoint?) -> CGPoint? {
        guard let relativeToCenter = relativeToCenter else {
            return nil
        }
        return CGPoint(x: location.x - relativeToCenter.x, y: location.y - relativeToCenter.y)
    }
}
