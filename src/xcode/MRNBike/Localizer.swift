//
//  Localizer.swift
//  Next Gen Biking
//
//  Created by Bormeth, Marc on 05/01/2017.
//  Copyright © 2017 Marc Bormeth. All rights reserved.
//

import Foundation

class Localizator {
    
    static let sharedInstance = Localizator()
    
    lazy var localizableDictionary: NSDictionary! = {
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "plist") {
            return NSDictionary(contentsOfFile: path)
        }
        fatalError("Localizable file NOT found")
    }()
    
    func localize(string: String) -> String {
        guard let localizedString = (localizableDictionary.value(forKey: string) as AnyObject).value(forKey: "value") as? String else {
            assertionFailure("Missing translation for: \(string)")
            return ""
        }
        return localizedString
    }
}
