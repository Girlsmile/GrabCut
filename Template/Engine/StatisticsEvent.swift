//
//  StatisticsEvent.swift
//  FakeGPS
//
//  Created by ljk on 2019/5/17.
//  Copyright © 2019 flow. All rights reserved.
//

import Foundation

enum StatisticsEvent: String {
    case homePageClick
    case saveFrom
    case selectEffect
    case shareTo
    
    func sendEvent(label: String) {
        MobClick.event(rawValue, label: label)
    }
}
