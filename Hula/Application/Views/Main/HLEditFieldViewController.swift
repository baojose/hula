//
//  HLEditFieldViewController.swift
//  Hula
//
//  Created by Juan Searle on 04/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HLEditFieldViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    var userData:HulaUser = HulaUser.sharedInstance
    var locationManager = CLLocationManager()
    
    var field_title:String = "Change data"
    var field_label: String = "not selected"
    var field_previous_val: String = ""
    var field_new_val: String = ""
    var field_key: String = "userNick"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var newValueTextView: UITextView!
    @IBOutlet weak var lineSeparator: UILabel!
    @IBOutlet weak var saveButton: HLBouncingButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //titleLabel.text = "Change \(field_label)"
        // Do any additional setup after loading the view.
        newValueTextView.delegate = self
        
        
        // location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        
        titleLabel.text = field_title
        currentValueLabel.text = "CURRENT: \(field_previous_val)"
        newValueTextView.text = field_previous_val
        newValueTextView.isScrollEnabled = false
        textViewDidChange(newValueTextView)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        newValueTextView.becomeFirstResponder()
        textViewDidChange(newValueTextView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func textViewDidChange(_: UITextView){
        let w = self.view.frame.size.width-30
        let h = commonUtils.heightString(width: w, font: newValueTextView.font! , string: newValueTextView.text) + 40
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.newValueTextView.frame.size = CGSize(width: self.view.frame.size.width-30, height: h)
            self.lineSeparator.frame.origin.y = self.newValueTextView.frame.origin.y + h + 15
            self.saveButton.frame.origin.y = self.lineSeparator.frame.origin.y + 30
        }, completion: nil)
    
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        
        //print(long, lat)
        userData.location = CGPoint(x:long, y:lat);
        if (field_key == "userLocationName"){
            setUsersClosestCity(userLocation: userLocation)
        }
        locationManager.stopUpdatingLocation()
        //Do What ever you want with it
    }
    func setUsersClosestCity(userLocation: CLLocation){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary)
            let country = placeMark.addressDictionary?["Country"] as? String
            let city = placeMark.addressDictionary?["City"] as? String
   
            self.newValueTextView.text = city! + ", " + country!
        }
    }
    
    @IBAction func saveNewValueAction(_ sender: Any) {
        field_new_val = newValueTextView.text!
        userData.setValue(field_new_val, forKey: field_key)
        userData.updateServerData()
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func goBackAction(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}
