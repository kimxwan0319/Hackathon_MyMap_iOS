//
//  contactTracingListViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/23.
//

import UIKit
import Alamofire

class contactTracingListViewController: UIViewController {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var contactTracingTable: UITableView!
    
    @IBOutlet weak var QRScanBtn: UIButton!
    
    var showingDate = Date()
    var myVisitedSpots = [spotData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBtn()
        gestureInDateView()
        setDate()
        setTableView()
        
        getData()
        initRefresh()
    }
    
    
    
    @IBAction func lastDayBtn(_ sender: Any) {
        showingDate -= 86400
        setDate()
        getData()
    }
    @IBAction func NextDayBtn(_ sender: Any) {
        showingDate += 86400
        setDate()
        getData()
    }

}

extension contactTracingListViewController{
    
    func setBtn(){
        QRScanBtn.layer.cornerRadius = QRScanBtn.frame.size.width/2.0
    }
    
    func gestureInDateView(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(alertWithDatePicker))
        self.dateView.addGestureRecognizer(gesture)
    }
    
    @objc func alertWithDatePicker(){
        
    }
    
    func setDate(){
        dateLable.text = dateFormat1()
    }
    
    func getData(){
        AF.request( baseURL+"/logs?"+now(), method: .get,parameters: ["date":dateFormat3()] ,headers: ["Authorization":"Bearer "+access_token]).validate().responseJSON(completionHandler: { res in
                           
            switch res.result {
            case .success(let value):
                print(value)
                if let data = value as? [[String:Any]]{
                    self.myVisitedSpots.removeAll()
                    DispatchQueue.global().async {
                        for dataIndex in data {
                            self.myVisitedSpots.insert(spotData(visited_at:dataIndex["visited_at"] as! String,
                                                               address: dataIndex["address"] as! String,
                                                               spotName: dataIndex["spot_name"] as! String),at: 0)
                            }
                        DispatchQueue.main.async {
                            self.contactTracingTable.reloadData()
                        }
                    }
                }
                            
            case .failure(let err):
                print("ERROR : \(err)")
            
            }
        })
    }
    
    func dateFormat1() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "MM월\ndd일"
        let current_time_string = formatter_time.string(from: showingDate)
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
    
    func dateFormat3() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_time_string = formatter.string(from: showingDate)
        return current_time_string
    }

}

extension contactTracingListViewController :
    UITableViewDelegate, UITableViewDataSource{
    
    func setTableView(){
        contactTracingTable.delegate = self
        contactTracingTable.dataSource = self
        contactTracingTable.separatorStyle = .none
        contactTracingTable.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myVisitedSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactTracingTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTracingCell
        
        if myVisitedSpots.count == 1{
            cell.lineImageView.image = UIImage(named: "Only")
        }
        else if indexPath.row == 0 {
            cell.lineImageView.image = UIImage(named: "Last")
        }
        else if indexPath.row == myVisitedSpots.count-1{
            cell.lineImageView.image = UIImage(named: "First")
        }
        else{
            cell.lineImageView.image = UIImage(named: "Middle")
        }
        
        cell.timeLable.text = dateFormat2(myVisitedSpots[indexPath.row].visited_at)
        
        cell.addressLable.text = myVisitedSpots[indexPath.row].spotName
        
        cell.detailedAddressLable.text = myVisitedSpots[indexPath.row].address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
    
    func initRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
     
        if #available(iOS 10.0, *) {
            contactTracingTable.refreshControl = refresh
        } else {
            contactTracingTable.addSubview(refresh)
        }
    }
        
        // 새로고침 함수
    @objc func updateUI(refresh: UIRefreshControl) {
        refresh.endRefreshing() // 리프레쉬 종료
        getData()
    }
    
}

class ContactTracingCell: UITableViewCell {
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var detailedAddressLable: UILabel!
}

struct spotData{
    let visited_at: String
    let address: String
    let spotName: String
}

