//
//  VideoViewController.swift
//  StopDrunkDriving
//
//  Created by charles on 10/24/18.
//  Copyright © 2018 liang. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    @IBOutlet weak var suggestText: UITextView!
    @IBOutlet weak var uberButton: UIButton!
    
    @IBAction func UberBtn(_ sender: Any) {
        
        if let appUrl = URL(string: "uber://"){
            let canOpen = UIApplication.shared.canOpenURL(appUrl)
            let appName = "uber"
            let appScheme = "\(appName)://"
            let appSchemeUrl = URL(string: appScheme)
            
            if UIApplication.shared.canOpenURL(appSchemeUrl! as URL){
                UIApplication.shared.open(appSchemeUrl!, options: [:], completionHandler: nil)
        }
        }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestText.isHidden = true
        uberButton.isHidden = true
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: nil, message: "Analyzing the video, please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 15, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
            self.suggestText.isHidden = false
            self.uberButton.isHidden = false

        }
    }
    
    
    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
    }
    
    
    
    
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
