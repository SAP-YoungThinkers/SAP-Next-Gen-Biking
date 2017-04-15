//
//  Configurator.swift
//  Next Gen Biking
//
//  Created by Bormeth, Marc on 30/12/2016.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import Foundation
import UIKit

class Configurator : NSObject {

    public var distanceFilter : Double
    public var zoomLevel : Double
    public var allowAutoLocationPause : Bool
    public var backendBaseURL : String
    
    public var greenColor: UIColor
    public var redColor: UIColor
    public var yellowColor: UIColor
    public var hanaUser: String
    public var hanaPW: String
    

    /* e.g.: FF6666 returns a red UIColor */
    static func createColor(hex: String) -> UIColor {
        //snippet from StackOverflow -- Thanks dude!
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override init() {

        var list: [String: Any] = [:]
        
        if let url = Bundle.main.url(forResource:"ConfigList", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                list = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                // do something with the dictionary
            } catch {
                print(error)
            }
        }
        self.distanceFilter = (list["distance filter"] as! NSString).doubleValue
        self.allowAutoLocationPause = list["allow location pause"] as! Bool
        self.backendBaseURL = list["backend base url"] as! String
        self.zoomLevel = (list["zoom level"] as! NSString).doubleValue
        self.redColor = Configurator.createColor(hex: list["red"] as! String)
        self.greenColor = Configurator.createColor(hex: list["green"] as! String)
        self.yellowColor = Configurator.createColor(hex: list["yellow"] as! String)
        self.hanaUser = list["username"] as! String
        self.hanaPW = list["password"] as! String
        self.backendBaseURL = list["backend base url"] as! String
        super.init()
        
        
    }
    
}
