//
//  HLCompleteProductProfileViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLCompleteProductProfileViewController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var perkContainView: UIView!
    @IBOutlet var perkScrollView: UIScrollView!
    @IBOutlet var desciptionTxtField: UITextField!
    @IBOutlet var conditionNewBtn: UIButton!
    @IBOutlet var conditionUsedBtn: UIButton!
    @IBOutlet weak var doneBtn: HLRoundedGradientButton!
    
    @IBOutlet var categoryMarkLabel: UILabel!
    @IBOutlet var categoryMarkLineLabel: UILabel!
    @IBOutlet var categoryMarkImage: UIImageView!
    @IBOutlet var perkMarkLabel: UILabel!
    @IBOutlet var perkMarkLineLabel: UILabel!
    @IBOutlet var perkMarkImage: UIImageView!
    @IBOutlet weak var charactersRemainingLabel: UILabel!
    
    @IBOutlet weak var productReferenceImage: UIImageView!
    var productCondition:String = "new"
    var productImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        
    }
    func initView(){
        
        
        commonUtils.circleImageView(productReferenceImage)
        productReferenceImage.image = productImage
        
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        categoryTableView.frame.origin = CGPoint(x: 0.0, y: 0.0)
        perkContainView.frame.origin = CGPoint(x: mainScrollView.frame.size.width, y: 0.0)
        contentView.frame.origin = CGPoint(x: 0.0, y: 0)
        //mainScrollView.contentSize = contentView.frame.size
        mainScrollView.setContentOffset(CGPoint(x:0.0, y:0.0), animated: false)
        self.changeMarkState(0)
        self.changeConditionState(conditionNewBtn.tag)
        
        //doneBtn.setup()
        desciptionTxtField.addTarget(self, action: #selector(textchange(_:)), for: UIControlEvents.editingChanged)
        let tapGesture: UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: #selector(onTapScreen))
        perkContainView.addGestureRecognizer(tapGesture)
    }
    
    func changeMarkState(_ mode: Int!){
        if mode == 0 {
            categoryMarkLabel.textColor = HulaConstants.appMainColor
            categoryMarkImage.image = UIImage.init(named: "icon_progress")
            categoryMarkLineLabel.isHidden = false
            perkMarkLabel.textColor = UIColor.lightGray
            perkMarkImage.image = UIImage.init(named: "icon_unprogress")
            perkMarkLineLabel.isHidden = true
        }else if mode == 1{
            perkMarkLabel.textColor = HulaConstants.appMainColor
            perkMarkImage.image = UIImage.init(named: "icon_progress")
            perkMarkLineLabel.isHidden = false
            categoryMarkLabel.textColor = UIColor.lightGray
            categoryMarkImage.image = UIImage.init(named: "icon_checked")
            categoryMarkLineLabel.isHidden = true
        }
    }
    @IBAction func newConditionClicked(_ sender: UIButton!) {
        self.changeConditionState(sender.tag)
    }
    @IBAction func usedConditionClicked(_ sender: UIButton) {
        self.changeConditionState(sender.tag)
    }
    func changeConditionState(_ mode: Int!){
        if mode == 10 {
            productCondition = "new"
            conditionNewBtn.backgroundColor = HulaConstants.appMainColor
            conditionNewBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionNewBtn, 0.0, UIColor.clear, conditionNewBtn.frame.size.height / 2.0)
            conditionUsedBtn.backgroundColor = UIColor.white
            conditionUsedBtn.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionUsedBtn, 1.0, HulaConstants.appMainColor, conditionUsedBtn.frame.size.height / 2.0)
        }else if mode == 20{
            productCondition = "used"
            conditionUsedBtn.backgroundColor = HulaConstants.appMainColor
            conditionUsedBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionUsedBtn, 0.0, UIColor.clear, conditionUsedBtn.frame.size.height / 2.0)
            conditionNewBtn.backgroundColor = UIColor.white
            conditionNewBtn.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionNewBtn, 1.0, HulaConstants.appMainColor, conditionNewBtn.frame.size.height / 2.0)
        }
    }
    //#MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.arrCategories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "completeProductProfileCategoryCell") as! HLHomeCategoryTableViewCell
        let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
        
        cell.categoryName.attributedText = commonUtils.attributedStringWithTextSpacing(category.object(forKey: "name") as! String, CGFloat(2.33))
        cell.categoryImage.image = UIImage.init(named: category.object(forKey: "icon") as! String)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
        //print(category)
        dataManager.newProduct.productCategory = category.object(forKey: "_id") as! String
        
        UIView.animate(withDuration: 0.3, animations: {
            self.perkContainView.frame.origin.x = 0
            self.categoryTableView.frame.origin.x = -self.mainScrollView.frame.size.width
        })
        //mainScrollView.setContentOffset(CGPoint(x:HulaConstants.screenWidth, y:0), animated: true)
        self.changeMarkState(1)
    }
    func onTapScreen(){
        desciptionTxtField.resignFirstResponder()
        perkScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    //#MARK - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    func textchange(_ textField:UITextField) {
        self.changeDoneBtnState(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        perkScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        return textField.resignFirstResponder()
    }
    func changeDoneBtnState(_ string: String){
        let charCount = string.characters.count
        if string.characters.count != 0  {
            doneBtn.isEnabled = true
            doneBtn.alpha = 1
            //doneBtn.startAnimation()
            //print("Is enabled")
        }else{
            doneBtn.isEnabled = false
            doneBtn.alpha = 0.5
            //doneBtn.stopAnimation()
        }
        
        var theRemainingChars = 200 - charCount
        if (theRemainingChars < 1){
            let str = self.desciptionTxtField.text!
            let index = str.index(str.startIndex, offsetBy: 200)
            desciptionTxtField.text = str.substring(to: index)
            theRemainingChars = 0
        }
        charactersRemainingLabel.text = "\(theRemainingChars) characters remaining"
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.perkContainView.frame.origin.x = self.mainScrollView.frame.size.width
            self.categoryTableView.frame.origin.x = 0
        })
        self.changeMarkState(0)
        
    }
    @IBAction func doneBtnPRessed(_ sender: Any) {
        print("Complete button pressed")
        if (dataManager.newProduct.arrProductPhotoLink.count>0){
            dataManager.newProduct.productDescription = desciptionTxtField.text
            dataManager.newProduct.productCondition = productCondition
            dataManager.uploadMode = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
            self.dismiss(animated: true, completion: nil)
        } else {
            print("Images still uploading...")
        }
    }
    
}
