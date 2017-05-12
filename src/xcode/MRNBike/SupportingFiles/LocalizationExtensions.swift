import Foundation
import UIKit

open class LocalizationExtensions {
    
    open static let notificationMissingTransalation = "LocalizationExtensions.missingTranslation";
    
    fileprivate static var bundles : [Bundle] = []
    
    open static func addBundle(_ bundle: Bundle) {
        if !bundles.contains(bundle) && bundle != Bundle.main {
            bundles.append(bundle)
        }
    }
}

extension String {
    
    public var localized: String {
        return self.localizedWithComment("")
    }
    
    public func localizedWithComment(_ comment: String) -> String {
        if let string = self.localizedWithComment(comment, bundle: Bundle.main, recursion: 1) {
            return string
        }
        
        if let string = self.localizedWithComment(comment, bundles: LocalizationExtensions.bundles) {
            return string
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: LocalizationExtensions.notificationMissingTransalation), object: self)
        
        return self
    }
    
    fileprivate func localizedWithComment(_ comment: String, bundles: [Bundle]) -> String? {
        for bundle in bundles {
            if bundle != Bundle.main {
                if let string = self.localizedWithComment(comment, bundle: bundle, recursion: 1) {
                    return string
                }
            }
        }
        
        return nil
    }
    
    fileprivate func localizedWithComment(_ comment: String, bundle: Bundle, recursion: Int) -> String? {
        let string = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: comment)
        
        if self != string {
            return string
        }
        
        if recursion > 0 {
            if let urls = bundle.urls(forResourcesWithExtension: "bundle", subdirectory: nil) {
                for subURL in urls {
                    if let subBundle = Bundle(url: subURL) {
                        if let subString = self.localizedWithComment(comment, bundle: subBundle, recursion: recursion - 1) {
                            return subString
                        }
                    }
                }
                
            }
        }
        
        return nil;
    }
}

extension UILabel {
    
    @IBInspectable public var lzText: String?  {
        set {
            self.attributedText = NSAttributedString(string: newValue != nil ? newValue!.localized : "" , attributes: self.attributed)
        }
        
        get {
            return self.attributedText?.string
        }
    }
    
    public var attributed: [String: Any]? {
        return self.attributedText?.attributes(at: 0, effectiveRange: nil)
    }
}

extension UITextField {
    
    @IBInspectable public var lzPlaceholder : String? {
        set {
            
            self.placeholder = newValue != nil ? newValue?.localized : nil
        }
        
        get {
            return self.placeholder
        }
    }
}

extension UIButton {
    
    @IBInspectable public var lzTitle : String? {
        set { setLocalizedTitle(newValue, state: UIControlState()) }
        get { return getTitleForState(UIControlState()) }
    }
    
    @IBInspectable public var lzHighlighted : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.highlighted) }
        get { return getTitleForState(UIControlState.highlighted) }
    }
    
    @IBInspectable public var lzDisabled : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.disabled) }
        get { return getTitleForState(UIControlState.disabled) }
    }
    
    @IBInspectable public var lzSelected : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.selected) }
        get { return getTitleForState(UIControlState.selected) }
    }
    
    @IBInspectable public var lzFocused : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.focused) }
        get { return getTitleForState(UIControlState.focused) }
    }
    
    @IBInspectable public var lzApplication : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.application) }
        get { return getTitleForState(UIControlState.application) }
    }
    
    @IBInspectable public var lzReserved : String? {
        set { setLocalizedTitle(newValue, state: UIControlState.reserved) }
        get { return getTitleForState(UIControlState.reserved) }
    }
    
    fileprivate func setLocalizedTitle(_ title:String?, state: UIControlState) {
        self.setTitle(title != nil ? title!.localized : nil, for: state)
    }
    
    fileprivate func getTitleForState(_ state: UIControlState) -> String?{
        if let title = self.titleLabel {
            return title.text
        }
        return nil
    }
}

extension UIBarItem {
    
    @IBInspectable public var lzTitle : String? {
        set {
            self.title = newValue?.localized ?? nil
        }
        
        get {
            return self.title
        }
    }
}

extension UINavigationItem {
    
    @IBInspectable public var lzTitle : String? {
        set {
            self.title = newValue != nil ? newValue?.localized : nil
        }
        
        get {
            return self.title
        }
    }
    
    @IBInspectable public var lzPrompt : String? {
        set {
            self.prompt = newValue != nil ? newValue?.localized : nil
        }
        
        get {
            return self.prompt
        }
    }
}

extension UIViewController {
    
    @IBInspectable public var lzTitle : String? {
        set {
            self.title = newValue != nil ? newValue?.localized : nil
        }
        
        get {
            return self.title
        }
    }
}
