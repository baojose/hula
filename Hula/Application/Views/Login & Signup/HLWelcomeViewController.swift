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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
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
        
        if CLLocationManager.locationServicesEnabled() {
            print("Location services are enabled")
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted:
                print("Pending...")
                locationManager.requestWhenInUseAuthorization()
                self.closeIdentification()
            case .denied:
                print("Not authorized")
                let alert = UIAlertController(title: "Location unavailable", message: "Sorry but we do not have access to your current location and we will not be able to have the location of your products. Please change the permissions on the Settings app", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.closeIdentification()
                })
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorized")
                self.closeIdentification()
                
            }
        } else {
            print("Location services are not enabled")
            
            self.closeIdentification()
        }
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("changedAuth")
        print(status)
        if status == .authorizedWhenInUse {
            //self.closeIdentification()
        }
    }
}
