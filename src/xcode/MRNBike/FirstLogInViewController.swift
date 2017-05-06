//
//  FirstLogInViewController.swift
//  MRNBike
//
//  Created by 1 on 04.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class FirstLogInViewController: UIViewController {


    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var helpMessage: UIImageView!
   
    @IBOutlet weak var helpMessageBox: UILabel!
    
    @IBAction func openHelpMessage(_ sender: UIButton) {
        helpMessage.isHidden = false
        helpMessageBox.isHidden = false
        
    }
    
    @IBAction func doneButton(segue:UIStoryboardSegue) {
    }
    @IBAction func backButton(segue:UIStoryboardSegue) {
    }
    
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

}
