//
//  TrackingViewController.swift
//  MRNBike
//
//  Created by Bormeth, Marc on 11.05.17.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreImage

class TrackingViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var SaveRouteButton: UIButton!
    @IBOutlet weak var DismissButton: UIButton!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var backGroundImage: UIImageView!
    @IBOutlet weak var statisticView: UIView!
    @IBOutlet weak var wheelRotationLabel: UILabel!
    @IBOutlet weak var burgersLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var treesSavedLabel: UILabel!
    
    var locationManager = LocationManager()
    
    var trackPointsArray = [TrackPoint]() //storing Trackpoints including timestamp

    var elapsedSeconds: Int = 0
    var timerRunBool: Bool = true
    var timer: Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = "Record Route"
        
        statisticView.borderColor = UIColor.lightGray
        statisticView.borderWidth = 1
        
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: backGroundImage.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(3, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        
        backGroundImage.image = processedImage
        
        self.locationManager.delegate = self
        SaveRouteButton.isHidden = true
        DismissButton.isHidden = true
        PauseButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.saveCollectedDataLocally() // stores collected data in local storage
    }
    
    
    // MARK: - Action
    @IBAction func startTrackingEvent(_ sender: UIButton) {
        startButton?.isHidden = true
        PauseButton.isHidden = false
        locationManager.delegate = self
        locationManager.startTracking()
        
        if timerRunBool {
            startTimer(startNew: true)
        } else {
            startTimer(startNew: false)
        }
    }
    
    
    @IBAction func pauseTrackingEvent(_ sender: UIButton) {
        startButton?.isHidden = false
        PauseButton.isHidden = true
        timerRunBool = false
        timer.invalidate()
    }

    @IBAction func stopTrackingEvent(_ sender: UIButton) {
        self.locationManager.stopTracking()
        locationManager.delegate = nil
        DismissButton.isHidden = false
        SaveRouteButton.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = true
        PauseButton.isHidden = true
        timer.invalidate()
        
        //Test data. Delete Later!!!
        wheelRotationLabel.text = "20"
        burgersLabel.text = "30"
        distanceLabel.text = "40"
        treesSavedLabel.text = "50"
        
    }
    
    @IBAction func saveRouteButton(_ sender: UIButton) {
        
        var wheelRotation: Int = UserDefaults.standard.integer(forKey: "wheelRotation")
        wheelRotation += Int(wheelRotationLabel.text!)!
        UserDefaults.standard.set(wheelRotation, forKey: "wheelRotation")
        
        var burgers: Int = UserDefaults.standard.integer(forKey: "burgers")
        burgers += Int(burgersLabel.text!)!
        UserDefaults.standard.set(burgers, forKey: "burgers")
        
        var distance: Int = UserDefaults.standard.integer(forKey: "distance")
        distance += Int(distanceLabel.text!)!
        UserDefaults.standard.set(distance, forKey: "distance")
        
        var treesSaved: Int = UserDefaults.standard.integer(forKey: "treesSaved")
        treesSaved += Int(treesSavedLabel.text!)!
        UserDefaults.standard.set(treesSaved, forKey: "treesSaved")
      
        //upload()
    }
    
    // MARK: - NSCoding
    func saveCollectedDataLocally(){
        if StorageHelper.storeLocally(trackPointsArray: trackPointsArray) {
            trackPointsArray.removeAll() // in order to dispose used memory
        }
    }
    
    // MARK: - Helper Functions

    func startTimer(startNew: Bool) {
        if startNew { elapsedSeconds = 0 }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateElapsedTime), userInfo: nil, repeats: true)
    }
    
    func updateElapsedTime() {
        elapsedSeconds += 1
        
        if(elapsedSeconds > 0){
            let ti = NSInteger(elapsedSeconds)
            let strSeconds = ti % 60
            let strMinutes = (ti / 60) % 60
            let strHours = (ti / 3600)
            self.timeLabel.text = String(format: "%0.2d:%0.2d:%0.2d",strHours,strMinutes,strSeconds)
        }
    }
    
    func formatMinutesAgo(timeDifference: Double) -> String {
        let hours = Int(timeDifference) / 3600
        let minutes = Int(timeDifference) / 60 % 60
        let seconds = Int(timeDifference) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    
    // MARK: - Cloud storage
    
    func upload() {
        //TODO: Check for connection -> what if there is bad connection?
        
        saveCollectedDataLocally()
        
        if let loadedData = StorageHelper.loadGPS() {
            
            let jsonObj = StorageHelper.generateJSON(tracks: loadedData)
            
            StorageHelper.uploadToHana(scriptName: "importData/bringItToHana.xsjs", paramDict: nil, jsonData: jsonObj)
        }
    }

}


extension TrackingViewController: LocationManagerDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D) {
        let timestamp = Date().timeIntervalSince1970 * 1000 //this one is for HANA
        let currentTrackPoint = TrackPoint(point: location, timestamp: Int64(timestamp))
        
        trackPointsArray.append(currentTrackPoint)
    }
}

