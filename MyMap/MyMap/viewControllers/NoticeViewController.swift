//
//  NoticeViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/23.
//

import UIKit
import Alamofire

class NoticeViewController: UIViewController {

    @IBOutlet weak var noticeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTable()
        getData()
    }
    
    var notices = [spotData]()

}
extension NoticeViewController : UITableViewDelegate, UITableViewDataSource{
    
    func setTable(){
        noticeTable.delegate = self
        noticeTable.dataSource = self
    }
    
    func getData(){
        AF.request( baseURL+"/alerts?"+now(), method: .get ,headers: ["Authorization":"Bearer "+access_token]).validate().responseJSON(completionHandler: { res in
                           
            switch res.result {
            case .success(let value):
                print(value)
                if let data = value as? [[String:Any]]{
                    DispatchQueue.global().async {
                        for dataIndex in data {
                            self.notices.insert(spotData(visited_at:dataIndex["visited_at"] as! String,
                                                               address: dataIndex["address"] as! String,
                                                               spotName: dataIndex["spot_name"] as! String),at: 0)
                            }
                        DispatchQueue.main.async {
                            self.noticeTable.reloadData()
                        }
                    }
                }
                            
            case .failure(let err):
                print("ERROR : \(err)")
            
            }
        })
    }
    
    func dateFormat1(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let temp = formatter.date(from: date) else {return "?"}
        formatter.dateFormat = "MM:dd"
        let current_time_string = formatter.string(from: temp)
        
        return current_time_string
    }
    
    func dateFormat2(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let temp = formatter.date(from: date) else {return "?"}
        formatter.dateFormat = "HH:mm"
        let current_time_string = formatter.string(from: temp)
        
        return current_time_string
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = noticeTable.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeCell
        
        cell.DateLable.text = dateFormat1(notices[indexPath.row].visited_at)
        cell.timeLable.text = dateFormat2(notices[indexPath.row].visited_at)
        cell.spotNameLable.text = notices[indexPath.row].spotName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
}

class NoticeCell : UITableViewCell {
    @IBOutlet weak var DateLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var spotNameLable: UILabel!
    @IBOutlet weak var DescriptionLable: UILabel!
}
