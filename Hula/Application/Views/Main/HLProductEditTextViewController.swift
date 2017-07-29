//
//  HLProductEditTextViewController.swift
//  Hula
//
//  Created by Juan Searle on 30/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductEditTextViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var currentTextLabel: UILabel!
    @IBOutlet weak var editableTextView: UITextView!
    @IBOutlet weak var editPageTitleLabel: UILabel!
    @IBOutlet weak var lineSeparator: UILabel!
    @IBOutlet weak var saveButton: HLBouncingButton!
    
    var originalText: String = ""
    var label: String = ""
    var item: String = ""
    var pageTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        editPageTitleLabel.text = pageTitle
        currentTextLabel.text = "CURRENT: \(originalText)"
        editableTextView.text = originalText
    }
    override func viewDidAppear(_ animated: Bool) {
        editableTextView.becomeFirstResponder()
        textViewDidChange(editableTextView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func saveAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func textViewDidChange(_: UITextView){
        let w = self.view.frame.size.width-30
        let h = commonUtils.heightString(width: w, font: editableTextView.font! , string: editableTextView.text) + 40
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.editableTextView.frame.size = CGSize(width: self.view.frame.size.width-30, height: h)
            self.lineSeparator.frame.origin.y = self.editableTextView.frame.origin.y + h + 15
            self.saveButton.frame.origin.y = self.lineSeparator.frame.origin.y + 30
        }, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
