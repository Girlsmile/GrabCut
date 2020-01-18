//
//  UIView.swift
//  Common
//
//  Created by lsc on 27/02/2017.
//
//

import UIKit

public extension UIView {
    
    var x: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var y: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var left: CGFloat {
        set {
            self.frame = CGRect(x: newValue, y: self.top, width: self.width, height: self.height)
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var top: CGFloat {
        set {
            self.frame = CGRect(x: self.left, y: newValue, width: self.width, height: self.height)
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var right: CGFloat {
        set {
            self.frame = CGRect(x: newValue - self.width, y: self.top, width: self.width, height: self.height)
        }
        get {
            return self.left + self.width
        }
    }
    
    var bottom: CGFloat {
        set {
            self.frame = CGRect(x: self.left, y: newValue - self.height, width: self.width, height: self.height)
        }
        get {
            return self.top + self.height
        }
    }
    
    var centerX: CGFloat {
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
        get {
            return self.center.x
        }
    }
    
    var centerY: CGFloat {
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
        get {
            return self.center.y
        }
    }
    
    var width: CGFloat {
        set {
            self.frame.size = CGSize(width: newValue, height: self.frame.height)
        }
        get {
            return self.bounds.size.width
        }
    }
    
    var height: CGFloat {
        set {
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.width, height: newValue))
        }
        get {
            return self.bounds.size.height
        }
    }
    
    var halfWidth: CGFloat {
        return self.width / 2
    }
    
    var halfHeight: CGFloat {
        return self.height / 2
    }
    
    var size: CGSize {
        set {
            self.frame.size = newValue
        }
        get {
            return self.frame.size
        }
    }
}
