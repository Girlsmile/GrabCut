//
//  BaseNavigationController.swift
//  ScreenShot
//
//  Created by ljk on 2019/7/15.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import EachNavigationBar

class BaseNavigationController: UINavigationController {
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        didInitialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        didInitialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInitialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
    }
}

private extension BaseNavigationController {
    func setupUI() {
        
    }
    
    func setupData() {
        
        navigation.configuration.isEnabled = true
        navigation.configuration.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold), NSAttributedString.Key.foregroundColor: K.Color.black]
        navigation.configuration.setBackgroundImage(UIImage(color: UIColor.white))
        navigation.configuration.tintColor = UIColor.white
        
        navigation.configuration.isShadowHidden = true
        
        navigation.configuration.backItem = Configuration.BackItem(style: .image(Asset.back.image))
    }
}
