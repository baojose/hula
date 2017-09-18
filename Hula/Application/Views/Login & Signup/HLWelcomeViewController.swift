//
//  HLWelcomeViewController.swift
//  Hula
//
//  Created by Juan Searle on 04/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HLWelcomeViewController: UserBaseViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!

    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var messagesView: UIView!
    
    var step: Int = 0;
    var title1:String = "Accept notifications"
    var title2:String = "Allow location"
    var description1:String = "Do you want to be notified when another user sends you a message?"
    var description2:String = "Do you want to see products near you?"
    var button1:String = "Notify me"
    var button2:String = "Use my location"
    var messagesViewPosition:CGPoint = CGPoint(x:0, y:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messagesViewPosition = self.mobileImage.frame.origin
        mobileImage.alpha = 0
        self.mobileImage.frame.offsetBy(dx: 0, dy: 400)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func okButtonTapped(_ sender: Any) {
        
        switch step {
        case 0:
            showNotificationsScreen()
        case 1:
            askPushNotificationPermissions()
        case 2:
            askLocationPermission()
        default:
            self.closeIdentification()
            self.dismiss(animated: true)
            self.presentingViewController?.dismiss(animated: true)
        }
        step += 1
    }
    
    func showNotificationsScreen(){
        titleLabel.text = title1
        descriptionLabel.text = description1
        continueButton.setTitle(button1, for: .normal)
        UIView.animate(withDuration: 0.4) {
            self.messagesView.frame.size.height = self.view.frame.height - 100
            self.messagesView.frame.origin.y = 70
            self.mobileImage.frame.origin.y = 190
            self.mobileImage.alpha = 1
            self.backgroundImage.alpha = 0
        }
    }
    
    func askPushNotificationPermissions(){
        let app = UIApplication.shared.delegate as! AppDelegate
        app.registerForPushNotifications()
        
        
        showLocationScreen()
    }
    func askLocationPermission(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        if CLLocationManager.locationServicesEnabled() {
            print("Location services are enabled")
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted:
                print("Pending...")
                locationManager.requestWhenInUseAuthorization()
            //self.closeIdentification()
            case .denied:
                print("Not authorized")
                let alert = UIAlertController(title: "Allow HULA to access your location while you use the app?", message: "HULA uses this to help you to find stuff you like nearby, connect to other users and more. Go to Settings and turn on location for Hula.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.closeIdentification()
                })
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorized")
                self.closeIdentification()
                self.dismiss(animated: true)
                self.presentingViewController?.dismiss(animated: true)
                
                
            }
        } else {
            print("Location services are not enabled")
            self.closeIdentification()
        }
    }
    
    func showLocationScreen(){
        self.messagesViewPosition.x = self.messagesView.frame.origin.x
        UIView.animate(withDuration: 0.4, animations: { 
            self.messagesView.frame.origin.x = -500
        }) { (result) in
            self.titleLabel.text = self.title2
            self.descriptionLabel.text = self.description2
            self.continueButton.setTitle(self.button2, for: .normal)
            self.messagesView.frame.origin.x = 1000
            UIView.animate(withDuration: 0.4) {
                self.messagesView.frame.origin.x = self.messagesViewPosition.x
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print("changedAuth")
        //print(status)
        
        if status == .authorizedWhenInUse {
            self.closeIdentification()
            self.dismiss(animated: true)
        }
 
    }
}
