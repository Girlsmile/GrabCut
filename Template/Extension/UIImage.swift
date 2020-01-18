//
//  UIImage.swift
//  Template
//
//  Created by ljk on 2019/5/5.
//  Copyright © 2019 flow. All rights reserved.
//

import UIKit

public extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            if let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
                self.init(cgImage: cgImage)
                UIGraphicsEndImageContext()
                return
            }
        }
        self.init()
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func tinted(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        color.set()
        UIRectFillUsingBlendMode(rect, .sourceAtop)
        let tintImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintImage
    }
    
    func rotated(by rotationAngle: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: self.size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let size = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        if let bitmap = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: size.width / 2.0, y: size.height / 2.0)
            bitmap.rotate(by: rotationAngle)
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            let origin = CGPoint(x: -self.size.width / 2.0, y: -self.size.height / 2.0)
            
            bitmap.draw(cgImage, in: CGRect(origin: origin, size: self.size))
        }
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        } else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
    
}

extension UIImage {
    
    /// APP icon
    static var icon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    static var launchImage: UIImage? {
        if let image = assetsLaunchImage() {
            return image
        }
        if let image = storyboardLaunchImage() {
            return image
        }
        return nil
    }
    
    /// From Assets
    static private func assetsLaunchImage() -> UIImage? {
        if let image = assetsLaunchImage("Portrait") { return image }
        if let image = assetsLaunchImage("Landscape") { return image }
        return nil
    }
    
    static private func assetsLaunchImage(_ orientation: String) -> UIImage? {
        let size = UIScreen.main.bounds.size
        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] else { return nil }
        for dict in launchImages {
            if let sizeString = dict["UILaunchImageSize"] as? String,
                let dictOrientation = dict["UILaunchImageOrientation"] as? String {
                let imageSize = NSCoder.cgSize(for: sizeString)
                
                if __CGSizeEqualToSize(imageSize, size),
                    orientation == dictOrientation,
                    let launchImageName = dict["UILaunchImageName"] as? String {
                    let image = UIImage(named: launchImageName)
                    return image
                }
            }
        }
        return nil
    }
    
    /// Form LaunchScreen.Storyboard
    static private func storyboardLaunchImage() -> UIImage? {
        guard let storyboardLaunchName = Bundle.main.infoDictionary?["UILaunchStoryboardName"] as? String,
            let launchVC = UIStoryboard(name: storyboardLaunchName, bundle: nil).instantiateInitialViewController(),
            let view = launchVC.view else {
                return nil
        }
        
        view.frame = UIScreen.main.bounds
        let image = viewConvertImage(view: view)
        return image
    }
    
    /// view convert image
    static private func viewConvertImage(view: UIView) -> UIImage? {
        let size = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
