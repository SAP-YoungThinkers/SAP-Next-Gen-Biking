//
//  HomeViewController.swift
//  MRNBike
//
//  Created by Ziad Abdelkader on 5/20/17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = UserDefaults.standard.string(forKey: "userFirstName")

        wheelRotationLabel.text = String(UserDefaults.standard.integer(forKey: "wheelRotation"))
        burgerLabel.text = String(UserDefaults.standard.double(forKey: "burgers"))
        distanceLabel.text = String(UserDefaults.standard.double(forKey: "distance"))
        treesSavedLabel.text = String(UserDefaults.standard.double(forKey: "treesSaved"))

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
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
