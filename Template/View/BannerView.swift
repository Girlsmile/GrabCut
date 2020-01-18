//
//  BannerView.swift
//  IconChanger
//
//  Created by Endless Summer on 2019/8/27.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import AdLib

class BannerView: UIView {
    
    static var banners = [Marketing.PresetName.Banner: UIView]()
    
    private let banner: UIView?
    
    init(rootVC: UIViewController, location: Marketing.PresetName.Banner? = nil) {
        if let location = location, location.reuse, let view = BannerView.banners[location] {
            banner = view
        } else {
            banner = Ad.default.createBannerView(rootViewController: rootVC, houseAdDataKey: location?.dataKey)
            if let location = location, let view = banner {
                BannerView.banners[location] = view
            }
        }
        super.init(frame: .zero)
        
        if let view = banner {
            addSubview(view)
            
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
