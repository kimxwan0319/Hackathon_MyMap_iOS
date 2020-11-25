//
//  LoginViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/23.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var IdTextField: UITextField!
    @IBOutlet weak var PwdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var SignUpBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBtnStyle()
    }

    func setBtnStyle(){
        loginBtn.layer.cornerRadius = 10
        SignUpBtn.layer.cornerRadius = 10
        SignUpBtn.layer.borderWidth = 0.5
        SignUpBtn.layer.borderColor = #colorLiteral(red: 0.305421263, green: 0.4027591944, blue: 0.8744748235, alpha: 1)
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        login()
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func login(){
        if IdTextField.text == ""{
            alert("아이디를 확인해주세요!")
        }
        else if PwdTextField.text == ""{
            alert("비밀번호를 확인해주세요!")
        }
        else{
            let parameters: [String: String] = [
                "email": IdTextField.text!,
                "password": PwdTextField.text!
            ]
                            
            let alamo = AF.request(baseURL+"/login", method: .post, parameters:parameters, encoder: JSONParameterEncoder.default).validate(statusCode: 200..<300)
                            
            alamo.responseJSON(){ response in
                switch response.result
                {
                //통신성공
                case .success(let value):
                    print(value)
                    if let valueNew = value as? [String:String]{
                        UserDefaults.standard.set(valueNew["access_token"], forKey: "access_token")
                        access_token = valueNew["access_token"]!
                    }
                    
                    self.goMainPage()
                    
                //통신실패
                case .failure( _):
                    self.alert("정보가 일치하지 않습니다.")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func alert(_ phrases : String) {
        let alert = UIAlertController(title: phrases, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert,animated: true, completion: nil)
    }
    
    func goMainPage(){
        guard let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "mainNC") else {
            return
        }
        mainPage.modalTransitionStyle = .coverVertical
        mainPage.modalPresentationStyle = .fullScreen
        self.present(mainPage, animated: true, completion: nil)
    }
}
