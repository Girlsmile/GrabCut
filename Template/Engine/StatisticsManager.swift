//
//  StatisticsManager.swift
//  FakeGPS
//
//  Created by ljk on 2019/5/17.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

class StatisticsManager: NSObject {
    
    static let shared = StatisticsManager()
    
    static let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
        guard
            let originalMethod = class_getInstanceMethod(forClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
            else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    private var currentPageName = ""
    
    func controllerDidAppear(_ controller: UIViewController) {
        
        guard let pageName = controller.pageName else { return }
        
        enterPage(pageName)
    }
    
    func enterPage(_ pageName: String) {
        if pageName == currentPageName {
            return
        }
        if !currentPageName.isEmpty {
            LLog("[DEBUG] controller disappear: ", currentPageName)
            MobClick.endLogPageView(currentPageName)
        }
        LLog("[DEBUG] controller appear: ", pageName)
        MobClick.beginLogPageView(pageName)
        
        currentPageName = pageName
    }
}

private extension UIViewController {
    var pageName: String? {
        
//        if self is MainViewController {
//            return "首页"
//        } else if self is SettingViewController {
//            return "设置页"
//        } else if self is AboutViewController {
//            return "关于"
//        } else if self is RecordViewController {
//            return "录音页"
//        }
        
        return nil
    }
}

extension UIViewController {
    static let classInit: Void = {
        let originalSelector = #selector(viewDidAppear(_:))
        let swizzledSelector = #selector(swizzled_viewDidAppear(_:))
        StatisticsManager.swizzling(UIViewController.self, originalSelector, swizzledSelector)
    }()
    
    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        StatisticsManager.shared.controllerDidAppear(self)
    }
    
}
