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
    @IBOutlet weak var doneBtn: HLBouncingButton!
    @IBOutlet var desciptionTxtField: UITextField!
    @IBOutlet var conditionNewBtn: UIButton!
    @IBOutlet var conditionUsedBtn: UIButton!
    
    @IBOutlet var categoryMarkLabel: UILabel!
    @IBOutlet var categoryMarkLineLabel: UILabel!
    @IBOutlet var categoryMarkImage: UIImageView!
    @IBOutlet var perkMarkLabel: UILabel!
    @IBOutlet var perkMarkLineLabel: UILabel!
    @IBOutlet var perkMarkImage: UIImageView!
    
    
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
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        categoryTableView.frame = CGRect(x: 0.0, y: 0.0, width: mainScrollView.frame.size.width, height: self.view.frame.size.height)
        perkContainView.frame = CGRect(x: mainScrollView.frame.size.width, y: 0.0, width: mainScrollView.frame.size.width, height: self.view.frame.size.height)
        contentView.frame = CGRect(x: 0.0, y: 0, width: mainScrollView.frame.size.width, height: self.view.frame.size.height)
        mainScrollView.contentSize = contentView.frame.size
        mainScrollView.setContentOffset(CGPoint(x:0.0, y:0.0), animated: false)
        self.changeMarkState(0)
        self.changeConditionState(conditionNewBtn.tag)
        
        doneBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_enabled"), for: UIControlState.normal)
        doneBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_disabled"), for: UIControlState.disabled)
        doneBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        doneBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneBtn.isUserInteractionEnabled = true
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
            conditionNewBtn.backgroundColor = HulaConstants.appMainColor
            conditionNewBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionNewBtn, 0.0, UIColor.clear, conditionNewBtn.frame.size.height / 2.0)
            conditionUsedBtn.backgroundColor = UIColor.white
            conditionUsedBtn.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionUsedBtn, 1.0, HulaConstants.appMainColor, conditionUsedBtn.frame.size.height / 2.0)
        }else if mode == 20{
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
        dataManager.newProduct.productCategory = category.object(forKey: "name") as! String
        
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
        if string.characters.count != 0  {
            doneBtn.isEnabled = true
            print("Is enabled")
        }else{
            doneBtn.isEnabled = false
        }
    }
    
    @IBAction func doneBtnPRessed(_ sender: Any) {
        print("Complete button pressed")
        dataManager.newProduct.productDescription = desciptionTxtField.text
        dataManager.uploadMode = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
}
