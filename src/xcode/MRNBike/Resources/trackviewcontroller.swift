//
//  trackviewcontroller.swift
//  MRNBike
//
//  Created by seirra on 2017/5/1.
//  Copyright © 2017年 Marc Bormeth. All rights reserved.
//
import UIKit
import os.log
import MapKit
import CoreLocation


class TrackViewController: UIViewController {
  
    var counter=0
    var counterdouble=Double()
    var savetime=Timer()
    var isplaying=1
    var commer=":"
    var zero="00"
    var singlezero="0"
    
    var wheels: Int = 0
    var location: String = " "
    var duration: Int = 0
    var burgers: Float = 0.0
    var distance: Float = 0.0
    var trees: Float = 0.0
    var press=0
    
    var locationManager = LocationManager()
    var trackPointsArray = [TrackPoint]()
    let config = Configurator()
    var isTracking: Bool = false
    func updatetime(){
        
        counterdouble=Double(counter)
        wheels=counter*5
        duration=counter
        burgers=Float(counterdouble/100.00)
        distance=Float(counterdouble/100.00)
        trees=Float(counterdouble/1000.000)

        counter=counter+1
        if counter<10
        {
            timelable.text=zero+commer+zero+commer+singlezero+String(counter)
        }
        else if counter < 60
        {
            timelable.text=zero+commer+zero+commer+String(counter)
        }
        else if counter < 70
        {
            timelable.text=zero+commer+singlezero+String(counter/60)+commer+singlezero+String(counter%60)
        }
        else if counter<600
        {
         timelable.text=zero+commer+singlezero+String(counter/60)+commer+String(counter%60)
        }
        else if counter<3600
        {
         timelable.text=zero+commer+String(counter/60)+commer+String(counter%60)
        }
        else if counter<4200
        {
            timelable.text=singlezero+String(counter/3600)+commer+singlezero+String((counter-3600)/60)+commer+String(counter%60)
        }
        else
        {
            timelable.text=String(counter/3600)+commer+String((counter-counter/3600)/60)+commer+String(counter%60)
            //repeat for every 1 second
        }
        // transform the time in a right form
        rotationlable.text=String(wheels)
        burgerlable.text=String(burgers)
        distancelable.text=String(distance)
        treelable.text=String(trees)
        
    }
    
  
    @IBOutlet weak var rotationlable: UILabel!
    @IBOutlet weak var treelable: UILabel!
    @IBOutlet weak var distancelable: UILabel!
    @IBOutlet weak var burgerlable: UILabel!
    
    @IBAction func backbutton(_ sender: UIButton) {
    }
    
    @IBAction func reportbutton(_ sender: UIButton) {
    }
    
    
    @IBAction func pausebutton(_ sender: UIButton, forEvent event: UIEvent) {
        if isplaying==0 {
         savetime.invalidate()
            isplaying=1
            sender.isSelected=false
            
        }
        else
        {savetime = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(updatetime), userInfo:nil, repeats:true)
           isplaying=0
            sender.isSelected=true
           
        }
        
        if isTracking {
           
            self.locationManager.stopTracking()
            
            isTracking = false
          
            locationManager.delegate = nil
            
            saveCollectedDataLocally()
        } else {
           
            isTracking = true
            locationManager.delegate = self
            locationManager.startTracking()
            
                   }
    }
    // collect gps data of every single track

    
    

    @IBAction func stopbutton(_ sender: UIButton) {
        timelable.text="00:00:00"
        rotationlable.text="0"
        burgerlable.text="0"
        distancelable.text="0"
        treelable.text="0"
        savetime.invalidate()
        
        // when stop click will stop collecting gps data
        self.locationManager.stopTracking()
        isTracking = false
        locationManager.delegate = nil
        saveCollectedDataLocally()
        
        //switch to save route page
        let sb = UIStoryboard(name: "Tracking", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "SaverouteViewController") as!SaverouteViewController
        vc.counter1=counter
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }

    
        
    @IBOutlet weak var navigationitem: UINavigationItem!
    
    @IBOutlet weak var timelable: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
        
        saveCollectedDataLocally()
        // stores collected data in local storage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigation bar is invisable
        
        self.locationManager.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.titleTextAttributes=[NSForegroundColorAttributeName : UIColor.white]
        
                // Do any additional setup after loading the view, typically from a nib.
    }
    func saveCollectedDataLocally(){
        
        if StorageHelper.storeLocally(trackPointsArray: trackPointsArray) {
            trackPointsArray.removeAll() // in order to dispose used memory
        }
    }
    func getTrackPoints() -> [TrackPoint] { return trackPointsArray }
    func polyline(points: [TrackPoint]) -> MKPolyline {
        var rawrCoords = [CLLocationCoordinate2D]()
        
        for current in points {
            rawrCoords.append(CLLocationCoordinate2D(latitude: current.latitude, longitude: current.longitude))
        }
        
        return MKPolyline(coordinates: &rawrCoords, count: rawrCoords.count)
    }
    }

    extension TrackViewController: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D) {
        let timestamp = Date().timeIntervalSince1970 * 1000 //this one is for HANA
        let currentTrackPoint = TrackPoint(point: location, timestamp: Int64(timestamp))
        
        trackPointsArray.append(currentTrackPoint)
    }
    // upload the gps data
        
    @IBAction func canceltrack(segue:UIStoryboardSegue) {
        self.navigationController?.isNavigationBarHidden=true    
    }
}


