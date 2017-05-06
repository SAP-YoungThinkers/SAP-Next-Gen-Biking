//
//  StartViewController.swift
//  MRNBike
//
//  Created by 1 on 03.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
   
    @IBOutlet weak var opentour: UIButton!

    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var ContView: UIView!
   
    @IBAction func openTourPage(_ sender: UIButton) {
        ContView.isHidden = false
    }
    


    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
// Hide navigation Bar on start page
self.navigationController?.isNavigationBarHidden = true
        
        
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

}
