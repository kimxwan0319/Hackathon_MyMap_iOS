//
//  LoadingViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/24.
//

import UIKit
import Alamofire

let baseURL : String = "http://192.168.0.14:8888"
var access_token : String = UserDefaults.standard.string(forKey: "access_token") ?? ""

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        AF.request( baseURL+"/information?"+now(), method: .get,parameters: [:] ,headers: ["Authorization":"Bearer "+access_token]).validate().responseJSON(completionHandler: { res in
                           
            switch res.result {
            case .success(_ ):
                self.goMain()
            case .failure(_ ):
                self.goLogin()
            }
        })
    }
    
    func goLogin() {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
        vcName?.modalTransitionStyle = .coverVertical
        vcName?.modalPresentationStyle = .fullScreen
        self.present(vcName!, animated: true, completion: nil)
    }
           
    func goMain() {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "mainNC")
        vcName?.modalTransitionStyle = .coverVertical
        vcName?.modalPresentationStyle = .fullScreen
        self.present(vcName!, animated: true, completion: nil)
    }

    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
}
