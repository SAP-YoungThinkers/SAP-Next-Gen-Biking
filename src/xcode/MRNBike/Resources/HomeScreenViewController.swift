//
//  HomeScreenViewController.swift
//  MRNBike
//
//  Created by Ziad Abdelkader on 5/4/17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
        var count = 0
        @IBOutlet weak var myLabel: UILabel!
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            myLabel.text = "Count \(count)"
            count += 1
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            count = 1
            // Do any additional setup after loading the view.
        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

    
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


