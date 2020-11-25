//
//  QRScannerViewController.swift
//  MyMap
//
//  Created by 김수완 on 2020/11/23.
//

import UIKit
import AVFoundation
import Alamofire

class QRScannerViewController: UIViewController {

    @IBOutlet weak var QRCodeFrame: UIView!
    
    var video = AVCaptureVideoPreviewLayer()
    
    var wasQRScan : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setQRScanner()
        setFrame()
    }

}

extension QRScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func setNavigationBar(){
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
    }
    
    func setQRScanner(){
        let session = AVCaptureSession()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }
        catch{
            print("ERROR")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count != 0{
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if object.type == .qr{
                    
                    if !wasQRScan{
                        wasQRScan = true
                        AF.request( baseURL+"/spot/"+object.stringValue!+"?"+now(), method: .get,parameters: [:] ,headers: ["Authorization":"Bearer "+access_token]).validate().responseJSON(completionHandler: { res in
                                       
                            switch res.result {
                            case .success(let value):
                                if let data = value as? [String:Any]{
                                    let alert = UIAlertController(title: "QR코드 정보", message: data["spot_name"] as? String, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "취소", style: .default, handler: { action in
                                        self.wasQRScan = false
                                    }))
                                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                        self.postMyLocation(Int(object.stringValue!)!)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                        
                            case .failure(let err):
                                print("ERROR : \(err)")
                                self.wasQRScan = false
                            }
                        })
                    }
                    
                }
            }
        }
    }
    
    func postMyLocation(_ spot_id : Int){
                        
        let alamo = AF.request(baseURL+"/logs", method: .post, parameters:["spot_id" : spot_id],encoder: JSONParameterEncoder.default, headers: ["Authorization":"Bearer "+access_token]).validate(statusCode: 200..<300)
                        
        alamo.responseJSON(){ response in
            switch response.result
            {
            //통신성공
            case .success( _):
                self.navigationController?.popViewController(animated: true)
            //통신실패
            case .failure(let err):
                print(err)
                self.wasQRScan = false
            }
        }
    }
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
    
    func setFrame(){
        self.view.bringSubviewToFront(QRCodeFrame)
    }
}

extension UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion:@escaping (()->())) {
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    func popViewController(animated: Bool, completion:@escaping (()->())) -> UIViewController? {
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        let poppedViewController = self.popViewController(animated: animated)
        CATransaction.commit()
        return poppedViewController
    }
}
