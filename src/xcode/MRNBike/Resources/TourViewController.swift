//
//  TourViewController.swift
//  MRNBike
//
//  Created by 1 on 06.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit

class TourViewController: UIViewController {
    var startRidingAction: (() -> ())?
    
    @IBAction func startRidingPressed(_ sender: Any) {
        startRidingAction?()
        self.close()
  }
}
