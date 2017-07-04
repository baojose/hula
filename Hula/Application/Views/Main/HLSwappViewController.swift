//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 14/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSwappViewController: UIViewController {

    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var swappPageControl: HLPageControl!
    @IBOutlet weak var nextTradeBtn: UIButton!
    @IBOutlet weak var extraRoomBtn: UIButton!
    @IBOutlet weak var extraRoomImage: UIImageView!
    @IBOutlet weak var mainCentralLabel: UILabel!
    
    var selectedScreen = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        
        
        rotated()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let swappPageViewController = segue.destination as? HLSwappPageViewController {
            swappPageViewController.swappDelegate = self
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
    
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            self.portraitView.frame.origin.y = 0
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            portraitView.isHidden = false
            self.dismiss(animated: true) {
                // After dismiss
            }
        } else {
            //portraitView.isHidden = true
            print("animating..,")
            UIView.animate(withDuration: 0.9) {
                self.portraitView.frame.origin.y = 1000
                self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                print(self.portraitView.frame.origin.y)
            }
        }
    }
    
    @IBAction func extraRoomAction(_ sender: Any) {
    }
    
    @IBAction func nextTradeAction(_ sender: Any) {
        print(mainContainer)
        
    }
    
}

extension HLSwappViewController: SwappPageViewControllerDelegate {
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageCount count: Int) {
        swappPageControl.numberOfPages = count
    }
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageIndex index: Int) {
        swappPageControl.currentPage = index
        if (index != 0){
            extraRoomBtn.isHidden = true
            extraRoomImage.isHidden = true
            nextTradeBtn.isHidden = true
        }
    }
    
}
