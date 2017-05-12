 
import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            self.layer.borderColor = newValue?.cgColor
        }
        get {
            return self.layer.borderColor != nil ? UIColor(cgColor: self.layer.borderColor!) : nil
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        set {
            self.layer.masksToBounds = newValue
        }
        get {
            return self.layer.masksToBounds
        }
    }
    
    @IBInspectable var shadowOffset: CGPoint {
        set {
            self.layer.shadowOffset = CGSize(width: newValue.x,
                                             height: newValue.y)
        }
        get {
            return CGPoint(x: self.layer.shadowOffset.width,
                           y: self.layer.shadowOffset.height)
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        set {
            self.layer.shadowOpacity = Float(newValue)
        }
        get {
            return CGFloat(self.layer.shadowOpacity)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            self.layer.shadowRadius = newValue
        }
        get {
            return self.layer.shadowRadius
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
        get {
            return self.layer.shadowColor != nil ? UIColor(cgColor: self.layer.shadowColor!) : nil
        }
    }
    
}

@IBDesignable
class DesignableView: UIView {
    
    @IBInspectable var computeCornerRadius: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.computeCornerRadius {
            self.cornerRadius = min(self.frame.width, self.frame.height) / 2
        }
    }
}
