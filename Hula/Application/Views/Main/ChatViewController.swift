//
//  ChatViewController.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatTextField: UITextField!

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func sendChatTextAction(_ sender: Any) {
    }
    @IBAction func closeChatAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 25
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel(frame: CGRect(x: 20, y:1, width: tableView.frame.size.width, height: 23))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.attributedText = CommonUtils.sharedInstance.attributedStringWithTextSpacing("NEAR YOU", 2.33)
        label.textAlignment = .center
        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
            cell.userNameLabel.text = "Mi nombre"
        
            cell.messageText.text = "Este es el texto del mensaje"
        
            return cell
    }
}
