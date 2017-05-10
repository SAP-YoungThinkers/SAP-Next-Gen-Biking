//
//  SaverouteViewController.swift
//  MRNBike
//
//  Created by seirra on 2017/5/2.
//  Copyright © 2017年 Marc Bormeth. All rights reserved.
//

import UIKit
import os.log

class SaverouteViewController: UIViewController {
    


    //@IBOutlet weak var ReportLocation: UIButton!
    
    @IBOutlet weak var saveroute: UIButton!
    @IBOutlet weak var report: UIButton!
    
    @IBOutlet weak var dismiss: UIButton!
    @IBOutlet weak var DurationDisplay: UILabel!
    @IBOutlet weak var DistanceDisplay: UILabel!
    @IBOutlet weak var LocationDisplay: UILabel!
    @IBOutlet weak var WheelsDisplay: UILabel!
    @IBOutlet weak var BurgerDisplay: UILabel!
    @IBOutlet weak var TreesDisplay: UILabel!
    
    //store the value counter passed by the tracking page
    var counter1=Int()
    var counterdouble1=Double()
    

    var counter=0
    var savetime=Timer()
    var isplaying=1
    var commer=":"
    var zero="00"
    var singlezero="0"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if counter1<10
        {
            DurationDisplay.text=zero+commer+zero+commer+singlezero+String(counter1)
        }
        else if counter1 < 60
        {
            DurationDisplay.text=zero+commer+zero+commer+String(counter1)
        }
        else if counter1 < 70
        {
            DurationDisplay.text=zero+commer+singlezero+String(counter/60)+commer+singlezero+String(counter1%60)
        }
        else if counter1<600
        {
            DurationDisplay.text=zero+commer+singlezero+String(counter/60)+commer+String(counter1%60)
        }
        else if counter1<3600
        {
            DurationDisplay.text=zero+commer+String(counter/60)+commer+String(counter%60)
        }
        else if counter1<4200
        {
            DurationDisplay.text=singlezero+String(counter/3600)+commer+singlezero+String((counter-3600)/60)+commer+String(counter%60)
        }
        else
        {
            DurationDisplay.text=String(counter/3600)+commer+String((counter1-counter1/3600)/60)+commer+String(counter1%60)
        }
        counterdouble1=Double(counter1)
        WheelsDisplay.text=String(counter1*5)
        BurgerDisplay.text=String(counterdouble1/100.00)
        DistanceDisplay.text=String(counterdouble1/100.00)
        TreesDisplay.text=String(counterdouble1/1000.00)
        

        // Do any additional setup after loading the view.
    }
    


    @IBAction func report(_ sender: Any) {
        //clear the data and go back to tracking
        counter1=0
        //self.navigationController?.isNavigationBarHidden=true
    }

      
    @IBAction func saveroute(_ sender: Any) {
        //store the route information in HANA and others locally, then go to myroute
        saveRoute()
        self.navigationController?.isNavigationBarHidden=true
        let sb = UIStoryboard(name: "Routes", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "RoutesStoryboard") as!UINavigationController
        self.present(vc, animated: true, completion: nil)
        
        
    }
    

    @IBAction func dismiss(_ sender: Any) {
        //clear the data and go back to tracking
        counter1=0
        self.navigationController?.isNavigationBarHidden=true
        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //store data using the class ThisTracking
    var tracks=[ThisTracking]()
    
    private func thisRoute() {
        
        let thistrack=ThisTracking(wheels: counter1, location: "Mannheim", duration: counter1, burgers: Float(counter1), distance: Float(counter1), trees: Float(counter1))
        
        tracks+=[thistrack]
        
    }
    
    private func saveRoute() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tracks, toFile: ThisTracking.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("tracking successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
}
