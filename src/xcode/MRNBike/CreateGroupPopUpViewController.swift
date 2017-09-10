//
//  CreateGroupPopUpViewController.swift
//  MRNBike
//
//  Created by Bartosz Wilkusz on 10.09.17.
//
//

import UIKit

class CreateGroupPopUpViewController: UIViewController {

    
    //Mark: Properties
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var createGroupTitleLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Mark: Action
    @IBAction func onPressClosePopUp(_ sender: Any) {
        dismiss()
    }

}
