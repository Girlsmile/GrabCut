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
        
        Util.topViewController().present(vc, animated: true)
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
