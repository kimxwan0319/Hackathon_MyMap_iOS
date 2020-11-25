//
//  MyPageViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/23.
//

import UIKit
import Alamofire

class MyPageViewController: UIViewController {

    @IBOutlet weak var NameLable: UILabel!
    @IBOutlet weak var birthdayLable: UILabel!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var bloodTypeLable: UILabel!
    @IBOutlet weak var confirmationrRegistrationBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmationrRegistrationBtn.layer.borderWidth = 0.5
        confirmationrRegistrationBtn.layer.borderColor = #colorLiteral(red: 0.5311415792, green: 0.4400755167, blue: 1, alpha: 1)
        setUserData()
        // Do any additional setup after loading the view.
    }

    @IBAction func logoutBtn(_ sender: Any) {
        alertForLogin()
    }
    
    @IBAction func confirmationrRegistrationBtn(_ sender: Any) {
        alertForConfirmationrRegistration()
    }
}

extension MyPageViewController {
    
    func setUserData(){
        AF.request( baseURL+"/information?"+now(), method: .get,parameters: [:] ,headers: ["Authorization":"Bearer "+access_token]).validate().responseJSON(completionHandler: { res in
                           
            switch res.result {
            case .success(let value):
                print(value)
                if let data = value as? [String:Any]{
                    self.NameLable.text = data["name"] as? String
                    self.birthdayLable.text = "생년월일 : " + (data["birth_date"] as? String)!
                    self.addressLable.text = data["address"] as? String
                    self.bloodTypeLable.text = ((data["blood_type"] as? String)!) + "형"
                }
                            
            case .failure(let err):
                print("ERROR : \(err)")
            
            }
        })
    }

    func alertForConfirmationrRegistration(){
        let alert = UIAlertController(title: "당담자에게 동선 제출", message: "이메일", preferredStyle: .alert)
        alert.addTextField{ (TextField) in
            TextField.keyboardType = .emailAddress
            TextField.placeholder = "email"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                            
            let alamo = AF.request(baseURL+"/infection", method: .post, parameters:["email": alert.textFields![0].text!], headers: ["Authorization":"Bearer "+access_token]).validate(statusCode: 200..<300)
                            
            alamo.responseJSON(){ response in
                switch response.result
                {
                //통신성공
                case .success( _):
                    print("SUCCESS")
                    
                //통신실패
                case .failure(let err):
                    print(err)
                }
            }
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertForLogin(){
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .default, handler: nil)
        let okButton = UIAlertAction(title: "로그아웃", style: .default, handler: { action in
            UserDefaults.standard.removeObject(forKey: "access_token")
            access_token = ""
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "wattingVC")
                vcName?.modalTransitionStyle = .coverVertical
                vcName?.modalPresentationStyle = .fullScreen
            self.present(vcName!, animated: true, completion: nil)
        })
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert,animated: true, completion: nil)
    }
    
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
}
