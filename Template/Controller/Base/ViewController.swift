//
//  ViewController.swift
//  Template
//
//  Created by ljk on 2019/5/5.
//  Copyright © 2019 flow. All rights reserved.
//

import UIKit
import TZImagePickerController

class ViewController: BaseViewController {

    lazy var manager = OpenCVManager()
    
    let button = QMUIFillButton(fillType: .green)
    
    
    let changeColorButton = QMUIFillButton(fillType: .gray)
    
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        view.addSubview(button)
        
        view.addSubview(changeColorButton)
        
//        button.size = CGSize(width: 200, height: 34)
//
//        button.centerX = UIScreen.main.bounds.midX
//        button.centerY = UIScreen.main.bounds.midY
        
        changeColorButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(button.snp.bottom).offset(8)
        }
        
        changeColorButton.setTitle("修改背景色", for: .normal)
        self.changeColorButton.isHidden = true
        
        changeColorButton.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
//
        button.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
        }
        
        button.addTarget(self, action: #selector(someButtonTapped), for: .touchUpInside)
        button.setTitle("选择一张照片", for: .normal)
        
        self.view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(changeColorButton.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFit
    }
    
    @objc func changeColor() {
        imageView.image = manager.changeColor(5, g: 172, b: 250)
    }

    @objc func someButtonTapped() {
        guard let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) else { return }
        
        vc.allowPickingVideo = false
        vc.allowTakeVideo = false
        vc.allowTakePicture = false
        
        vc.didFinishPickingPhotosHandle = { [weak self] images, _, _ in
            guard let `self` = self, var image = images?.first else { return }
            
            
            let w: CGFloat = 500.0
            let h = (image.size.height / image.size.width) * w
            image = image.aspectScaled(toFill: CGSize.init(width: w, height: h))
            
            self.changeColorButton.isHidden = true
            self.button.setTitle("处理中", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                self.doGrabCutToImage(image)
            }
            
        }
        
        self.present(vc, animated: true, completion: nil)
       
    }
    
    func doGrabCutToImage(_ image: UIImage) {
        
        
        
//        let image = manager.doGrabCut(withMask: image, maskImage: image, iterationCount: 1)
        
        let selectedR = CGRect(origin: .zero, size: image.size)
        
//        CGRect(origin: CGPoint(x: selectedR.origin.x + 1, y: y), size: CGSize(width: selectedR.size.width - 2, height: selectedR.size.height - y - 1))
        LLog(image)
        let rect = CGRect(origin: CGPoint(x: selectedR.origin.x + 1, y: selectedR.origin.y + 1), size: CGSize(width: image.size.width - 2, height: image.size.height - 2))
        
        let outputImage = manager.doGrabCut(image, foregroundRect: rect, iterationCount: 5)
        
        
        imageView.image = outputImage
//        LLog(outputImage ?? "")
//        let vc = UIViewController()
//        let imageView = UIImageView(image: outputImage)
//        imageView.backgroundColor = UIColor.clear
//        imageView.contentMode = .scaleAspectFit
//        vc.view.addSubview(imageView)
//
//        imageView.snp.makeConstraints { (make) in
//            make.center.width.equalToSuperview()
//        }
        
        self.changeColorButton.isHidden = false
        button.setTitle("选择一张照片", for: .normal)
//        Util.topViewController().present(vc, animated: true)
    }
}

extension UIImage {
    
    public func scaled(to size: CGSize, scale: CGFloat = 1) -> UIImage {
        let targetSize = self.parse(size: size)
        
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: .zero, size: targetSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    public func aspectScaled(toFit targetSize: CGSize, scale: CGFloat = 1) -> UIImage {
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = targetSize.width / targetSize.height
        
        var resizeFactor: CGFloat
        
        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = targetSize.width / self.size.width
        } else {
            resizeFactor = targetSize.height / self.size.height
        }
        
        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2.0, y: (targetSize.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: origin, size: scaledSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    public func aspectScaled(toFill targetSize: CGSize, scale: CGFloat = 1) -> UIImage {
        if self.isResizable(targetSize: targetSize) == false {
            return self
        }
        
        let imageAspectRatio = self.size.width / self.size.height
        let canvasAspectRatio = targetSize.width / targetSize.height
        
        var resizeFactor: CGFloat
        
        if imageAspectRatio > canvasAspectRatio {
            resizeFactor = targetSize.height / self.size.height
        } else {
            resizeFactor = targetSize.width / self.size.width
        }
        
        let scaledSize = CGSize(width: self.size.width * resizeFactor, height: self.size.height * resizeFactor)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2.0, y: (targetSize.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, scale)
        draw(in: CGRect(origin: origin, size: scaledSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    private func isResizable(targetSize: CGSize) -> Bool {
        return targetSize != self.size && self.size.width > 0 && self.size.height > 0 && targetSize.width > 0 && targetSize.height > 0
    }
    
    private func parse(size: CGSize) -> CGSize {
        var result = size
        
        if size.width == -1 && size.height == -1 {
            result = self.size
        }
        else if size.width == -1 {
            result.width = self.size.width / self.size.height * size.height
        }
        else if size.height == -1 {
            result.height = size.width / (self.size.width / self.size.height)
        }
        
        return result
    }
}

