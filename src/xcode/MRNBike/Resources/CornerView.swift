 

import UIKit

//@IBDesignable
class CornerView: UIView {
    
    @IBInspectable var radii: CGFloat = 4 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var strokeColor: UIColor = .clear {
        didSet {
            self.borderLayer.strokeColor = self.strokeColor.cgColor
        }
    }
    
    @IBInspectable var strokeWidth: CGFloat = 0 {
        didSet {
            self.borderLayer.lineWidth = self.strokeWidth
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            self.shapeLayer.fillColor = self.backgroundColor?.cgColor
            super.backgroundColor = .clear
        }
    }
    
    var corners: UIRectCorner = .allCorners {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var borders: Set<Border> = [] {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private let shapeLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        
        self.shapeLayer.shouldRasterize = true
        self.shapeLayer.rasterizationScale = UIScreen.main.scale
        self.shapeLayer.actions = ["fillColor": NSNull()]
        self.layer.insertSublayer(self.shapeLayer, at: 0)
        
        self.borderLayer.shouldRasterize = true
        self.borderLayer.fillColor = UIColor.clear.cgColor
        self.borderLayer.rasterizationScale = UIScreen.main.scale
//        self.borderLayer.actions = ["fillColor": NSNull()]
        self.layer.insertSublayer(self.borderLayer, at: 1)
    }
    
    // MARK: - View lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = CGSize(width: self.radii, height: self.radii)
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds,
                                            byRoundingCorners: self.corners,
                                            cornerRadii: size).cgPath
        
        self.borderLayer.path = UIBezierPath(roundedRect: self.borderBounds,
                                             byRoundingCorners: self.corners,
                                             cornerRadii: size).cgPath
    }
    
    private var borderBounds: CGRect {
        var borderFrame = self.bounds.insetBy(dx: self.strokeWidth / 2,
                                              dy: self.strokeWidth / 2)
        if !self.borders.contains(.left) {
            borderFrame.origin.x -= self.radii
            borderFrame.size.width += self.radii
        }
        if !self.borders.contains(.right) {
            borderFrame.size.width += self.radii
        }
        if !self.borders.contains(.top) {
            borderFrame.origin.y -= self.radii
            borderFrame.size.height += self.radii
        }
        if !self.borders.contains(.bottom) {
            borderFrame.size.height += self.radii
        }
        
        return borderFrame
    }
}

extension CornerView {
    
    enum Border {
        case left, right, top, bottom
    }
}
