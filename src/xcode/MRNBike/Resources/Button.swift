 
import UIKit

extension UIButton {
    
    @IBInspectable var mirror: Bool {
        set {
            let transform = newValue ? CGAffineTransform(scaleX: -1.0, y: 1.0) : CGAffineTransform.identity
            
            self.transform = transform
            self.titleLabel?.transform = transform
            self.imageView?.transform = transform
        }
        get {
            return self.transform.a == -1
        }
    }
    
    @IBInspectable var selectedBackgroundColor: UIColor? {
        set {
            if let color = newValue {
                self.setBackgroundImage(color.image(), for: .selected)
            }
            else {
                self.setBackgroundImage(nil, for: .selected)
            }
        }
        get {
            return nil
        }
    }
    
    
    @IBInspectable var disabledBackgroundColor: UIColor? {
        set {
            if let color = newValue {
                self.setBackgroundImage(color.image(), for: .disabled)
            }
            else {
                self.setBackgroundImage(nil, for: .disabled)
            }
        }
        get {
            return nil
        }
    }
    
    @IBInspectable var normalBackgroundColor: UIColor? {
        set {
            if let color = newValue {
                self.setBackgroundImage(color.image(), for: .normal)
            }
            else {
                self.setBackgroundImage(nil, for: .normal)
            }
        }
        get {
            return nil
        }
    }
}
