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
    @IBOutlet var addBtn: UIButton!
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
        categoryTableView.frame = CGRect(x: 0.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        perkContainView.frame = CGRect(x: mainScrollView.frame.size.width, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        contentView.frame = CGRect(x: 0.0, y: 0, width: 2.0 * mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        mainScrollView.contentSize = contentView.frame.size
        mainScrollView.setContentOffset(CGPoint(x:0.0, y:0.0), animated: false)
        self.changeMarkState(0)
        self.changeConditionState(conditionNewBtn.tag)
        
        addBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_enabled"), for: UIControlState.normal)
        addBtn.setBackgroundImage(UIImage.init(named: "img_publish_btn_bg_disabled"), for: UIControlState.disabled)
        addBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        addBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
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
        return 55.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight))
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: tableView.sectionHeaderHeight - 1, width: tableView.frame.size.width, height: 1))
        lineLabel.backgroundColor = UIColor.init(red: 236.0/255, green: 236.0/255, blue: 236.0/255, alpha: 1.0)
        view.addSubview(lineLabel)
        view.backgroundColor = UIColor.white
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 89.0
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
        
        mainScrollView.setContentOffset(CGPoint(x:HulaConstants.screenWidth, y:0), animated: true)
    }
    //#MARK - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let posX: Int! = Int(mainScrollView.contentOffset.x / mainScrollView.frame.size.width)
        self.changeMarkState(posX)
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
        self.changeAddBtnState(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        perkScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        return textField.resignFirstResponder()
    }
    func changeAddBtnState(_ string: String){
        if dataManager.newProduct.productCategory.characters.count != 0 && string.characters.count != 0  {
            addBtn.isEnabled = true
        }else{
            addBtn.isEnabled = false
        }
    }
    @IBAction func completeProfile(_ sender: Any) {
        dataManager.newProduct.productDescription = desciptionTxtField.text
        dataManager.uploadMode = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
