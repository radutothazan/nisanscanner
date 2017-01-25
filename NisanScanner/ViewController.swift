//
//  ViewController.swift
//  NisanScanner
//
//  Created by Radu Tothazan on 02/12/2016.
//  Copyright © 2016 Radu Tothazan. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ViewController: UIViewController {
    
    @IBOutlet weak var scanButton: UIButton!
    var produse : [Produs]!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.backgroundColor = UIColor.black
        scanButton.isHidden = true
        activityIndicator.center.x = self.view.center.x
        activityIndicator.center.y = self.view.center.y + 200
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.color = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        activityIndicator.transform = CGAffineTransform(scaleX: 3.5, y: 3.5);
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()


        Alamofire.request("http://ecinstal.ro/connection.php").responseArray { (response: DataResponse<[Produs]>) in
            self.produse = response.result.value
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan"{
            let vc = segue.destination as! ScannerController
            vc.produse = produse
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

