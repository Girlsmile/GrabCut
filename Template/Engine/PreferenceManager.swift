//
//  Preference.swift
//  Example
//
//  Created by ljk on 2019/5/31.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import MMKV

let defaults = PreferenceManager.shared

final class PreferenceKey<T>: BaseKey {
    let defaultValue: T?
    
    init(_ key: String, defaultValue: T? = nil) {
        self.defaultValue = defaultValue
        super.init(rawValue: key)
    }
    
    required init!(rawValue: String) {
        defaultValue = nil
        super.init(rawValue: rawValue)
    }
}

class BaseKey: RawRepresentable, Hashable {
    let rawValue: String
    
    required init!(rawValue: String) {
        self.rawValue = rawValue
    }
    
    convenience init(_ key: String) {
        self.init(rawValue: key)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

final class PreferenceManager {
    static let shared = PreferenceManager(mmapID: "default.mmkv")
    private let mmkv: MMKV
    
    init(mmapID: String, relativePath: String? = nil) {
        let path = relativePath ?? NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        mmkv = MMKV(mmapID: mmapID, relativePath: path)!
    }
    
}

extension PreferenceManager {
    
    subscript(key: PreferenceKey<String>) -> String? {
        get { return mmkv.string(forKey: key.rawValue, defaultValue: key.defaultValue) }
        set {
            if let newValue = newValue {
                mmkv.set(newValue, forKey: key.rawValue)
            } else {
                mmkv.removeValue(forKey: key.rawValue)
            }
        }
    }
    
    subscript(key: PreferenceKey<Data>) -> Data? {
        get { return mmkv.data(forKey: key.rawValue) }
        set {
            if let newValue = newValue {
                mmkv.set(newValue, forKey: key.rawValue)
            } else {
                mmkv.removeValue(forKey: key.rawValue)
            }
        }
    }
    
    subscript(key: PreferenceKey<Bool>) -> Bool {
        get { return mmkv.bool(forKey: key.rawValue, defaultValue: key.defaultValue ?? false) }
        set { mmkv.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Int>) -> Int {
        get { return Int(mmkv.int64(forKey: key.rawValue, defaultValue: Int64(key.defaultValue ?? 0))) }
        set { mmkv.set(Int64(newValue), forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Float>) -> Float {
        get { return mmkv.float(forKey: key.rawValue, defaultValue: key.defaultValue ?? 0) }
        set { mmkv.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Double>) -> Double {
        get { return mmkv.double(forKey: key.rawValue, defaultValue: key.defaultValue ?? 0) }
        set { mmkv.set(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<[String]>) -> [String]? {
        get {
            if let object = mmkv.object(of: NSArray.self, forKey: key.rawValue) as? [String] {
                return object
            } else {
                return key.defaultValue
            }
        }
        set {
            if let newValue = newValue {
                mmkv.set(newValue as NSArray, forKey: key.rawValue)
            } else {
                mmkv.removeValue(forKey: key.rawValue)
            }
        }
    }
}
