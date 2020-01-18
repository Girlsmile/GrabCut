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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button = QMUIFillButton(fillType: .green)
        view.addSubview(button)
        
        button.size = CGSize(width: 200, height: 34)
        
        button.centerX = UIScreen.main.bounds.midX
        button.centerY = UIScreen.main.bounds.midY
        
        button.addTarget(self, action: #selector(someButtonTapped), for: .touchUpInside)
    }

    @objc func someButtonTapped() {
        guard let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) else { return }
        
        vc.allowPickingVideo = false
        vc.allowTakeVideo = false
        vc.allowTakePicture = false
        
        vc.didFinishPickingPhotosHandle = { [weak self] images, _, _ in
            guard let `self` = self, let image = images?.first else { return }
            
            self.doGrabCutToImage(image)
        }
        
        Util.topViewController().present(vc, animated: true)
    }
    
    func doGrabCutToImage(_ image: UIImage) {
        
//        let image = manager.doGrabCut(withMask: image, maskImage: image, iterationCount: 1)
        
        let selectedR = CGRect.init(origin: .zero, size: image.size)
        
//        CGRect(origin: CGPoint(x: selectedR.origin.x + 1, y: y), size: CGSize(width: selectedR.size.width - 2, height: selectedR.size.height - y - 1))
        LLog(image)
        let rect = CGRect(origin: CGPoint(x: selectedR.origin.x + 1, y: selectedR.origin.y + 1), size: CGSize(width: image.size.width - 2, height: image.size.height - 2))
        
        let outputImage = manager.doGrabCut(image, foregroundRect: rect, iterationCount: 1)
        LLog(outputImage ?? "")
        let vc = UIViewController()
        let imageView = UIImageView(image: outputImage)
        imageView.backgroundColor = UIColor.purple
        imageView.contentMode = .scaleAspectFit
        vc.view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        Util.topViewController().present(vc, animated: true)
    }
}
