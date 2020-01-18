//
//  BaseViewController.swift
//  ScreenShot
//
//  Created by ljk on 2019/7/15.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

class BaseViewController: QMUICommonViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        
        modalPresentationStyle = .fullScreen
        
    }
    
    override var title: String? {
        didSet {
            navigation.item.title = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        extendedLayoutIncludesOpaqueBars = true
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)
        
    }
    
}

extension BaseViewController {
    func setTitleColor(_ color: UIColor) {
        let bar = navigation.bar
        if var titleTextAttributes = bar.titleTextAttributes {
            titleTextAttributes[.foregroundColor] = color
            bar.titleTextAttributes = titleTextAttributes
        } else {
            bar.titleTextAttributes = [.foregroundColor: color]
        }
    }
    
    func setTitleFont(_ font: UIFont) {
        let bar = navigation.bar
        if var titleTextAttributes = bar.titleTextAttributes {
            titleTextAttributes[.font] = font
            bar.titleTextAttributes = titleTextAttributes
        } else {
            bar.titleTextAttributes = [.font: font]
        }
    }
}

private extension BaseViewController {
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}
