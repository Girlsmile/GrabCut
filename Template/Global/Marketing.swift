//
//  Marketing.swift
//  Template
//
//  Created by Endless Summer on 2019/12/9.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation
import SwiftyJSON
import AdLib
import SDWebImage

class Marketing: NSObject {
    static let shared = Marketing()
    
    struct PresetName {
        static let LoginRequired = "p7-2"
        
        struct SystemRT {
            static let Review = "p1-1"
            static let ReviewInterval = "p1-2"
        }
        
        struct Notification {
            static let TimeOffset = "p1-3"
        }
        
        enum Banner: String, CaseIterable {
            case home = "p2-1"
            
            case recentRecord = "p2-2"
            
            case edit = "p2-3"
            
            case setting = "p2-4"
            
            var shouldShow: Bool {
                return Preset.named(rawValue).boolValue && Ad.default.isEnabled
            }
            
            var dataKey: String? {
                switch self {
                case .home:
                    return BannerData.home
                case .setting:
                    return BannerData.setting
                case .edit:
                    return BannerData.edit
                case .recentRecord:
                    return BannerData.recentRecord
                }
            }
            
            var reuse: Bool {
                return true
            }
            
            struct BannerData {
                static let home = "S.Ad.首页"
                
                static let edit = "S.Ad.图片编辑页"
                
                static let setting = "S.Ad.设置页"
                
                static let recentRecord = "S.Ad.记录页"
                
            }
        }
        
        struct Interstitial {
            static let Launch = "p3-1"
            static let EnterForeground = "p3-2"
            static let Repost = "p3-3"
            
        }
        
        struct Reward {
            static let Reward = "p4-2"
            static let data = "p4-3"
            static let waitTime = "p4-4"
        }
        
        struct HouseAd {
            static let home = "p6-1"
        }
    }

    func setup() {
//        RT.default.setup(appID: K.IDs.AppID)
//
//        UMConfigure.initWithAppkey(K.IDs.UMengKey, channel: "App Store")
        
        var defaults: [String : Any] = [
            PresetName.SystemRT.Review: 2,
            PresetName.SystemRT.ReviewInterval: 1,
            
            PresetName.Notification.TimeOffset: ["days": 14],
            
            PresetName.Interstitial.Launch: 3,
            PresetName.Interstitial.EnterForeground: 3,
            PresetName.Interstitial.Repost: 5,
            
            PresetName.Reward.Reward: 0,
            PresetName.Reward.waitTime: 5,
            PresetName.Reward.data: [
                "title": "",
                "message": __("Your free usage is used up. Watch the ads below for continue using."),
                "cancel": __("Cancel"),
                "ok": __("Watch Video Ads")
            ],
            
        ]
        
        PresetName.Banner.allCases.forEach { (value) in
//            defaults[value.rawValue] = QMUIHelper.isSimulator() ? 0 : 1
            defaults[value.rawValue] = 1
        }
        
        Preset.default.setup(defaults: defaults)
        
        JSON.setupPMs(id: "7j2kc77r3z7uutzo",
                      key: "wb8cqmxzedksgpyl",
                      region: "oss-ap-northeast-1",
                      secret: "RepostSi/\(Util.appVersion())/meto.otf")
        
        // Ad
//        Ad.default.setup(bannerUnitID: K.IDs.BannerUnitID,
//                         interstitialUnitID: K.IDs.InterstitialUnitID,
//                         rewardAdUnitID: K.IDs.RewardUnitID)
        
        LoadingViewContainer.shared.backgroundImageView.image = UIImage.launchImage
        
        Ad.default.setupLaunchInterstitial(launchKey: PresetName.Interstitial.Launch, enterForegroundKey:  PresetName.Interstitial.EnterForeground, loadingView: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchHouseImage), name: JSONUpdatedNotification, object: nil)
        
        if QMUIHelper.isSimulator() {
//            Ad.default.isEnabled = false
        }
        showSystemRT()
//
        requestRewardAd()
    }
}

extension Marketing {
    
    var houseImageURL: URL? {
        return Preset.named(PresetName.HouseAd.home)["image"].url
    }
    
    var houseLinkURL: URL? {
        return Preset.named(PresetName.HouseAd.home)["link"].url
    }
    
    var houseImage: UIImage? {
        if let url = houseImageURL {
            let image = SDImageCache.shared.imageFromCache(forKey: url.absoluteString)
            return image
        }
        return nil
    }
    
}

extension Marketing {
    var loginRequired: Bool {
        return Preset.named(PresetName.LoginRequired).boolValue
    }
    
    @objc func willEnterForeground() {
        showSystemRT()
    }

    func showSystemRT() {
        let counter = Counter.find(key: PresetName.SystemRT.Review)
        counter.increase()
        if !RT.default.hasUserRTed && counter.hitsMax {
            Util.requestReview()
            counter.freeze()
        }
    }
    
    func requestRewardAd() {
        Ad.default.requestRewardAd()
    }
    
    @objc func fetchHouseImage() {
        guard let img = houseImageURL else { return }
        
        SDWebImageManager.shared.loadImage(with: img, options: .highPriority, context: nil, progress: nil) { (image, _, _, _, _, _) in

        }
    }
    
}

extension Marketing {
    
    func featureApps() -> UIView? {
        if !SettingsFeaturedApps.apps.isEmpty {
            return SettingsFeaturedApps.createAppsView(width: UIScreen.main.bounds.width)
        }
        return nil
    }
    
}

extension Marketing {
    static func handleRegisterRemoteNotification(granted: Bool) {
        let counter = Counter.find(key: PresetName.Notification.TimeOffset)
        if granted {
            counter.reset()
            return
        }
        if counter.hitsMax {
            counter.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.presentSettingNotificationAlert()
            })
        } else if counter.fireDate == .distantFuture {
            counter.fire()
        }
    }
    
    static func presentSettingNotificationAlert() {
        let alert = UIAlertController(title: __("您还没有开启消息通知"),
                                      message: __("“通知”可能包括提醒、声音和图标标记。这些可在“设置”中配置。"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: __("稍后再说"), style: .default, handler: nil))
        let openAction = UIAlertAction(title: __("立即设置"), style: .default, handler: { (_) in
            Util.openSettings()
        })
        alert.preferredAction = openAction
        alert.addAction(openAction)
        Util.topViewController().present(alert, animated: true)
    }
}
