//
//  SettingsBundleHelper.swift
//  Clea
//
//  Created by Damian Elsen on 11/24/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    
    struct SettingsBundleKeys {
        static let BundleVersionDictionaryKey = "CFBundleVersion"
        static let BundleShortVersionDictionaryKey = "CFBundleShortVersionString"
        static let AppVersionKey = "key_app_version"
        static let BuildVersionKey = "key_build_version"
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: SettingsBundleKeys.BundleShortVersionDictionaryKey) as! String
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.AppVersionKey)
        let build: String = Bundle.main.object(forInfoDictionaryKey: SettingsBundleKeys.BundleVersionDictionaryKey) as! String
        UserDefaults.standard.set(build, forKey: SettingsBundleKeys.BuildVersionKey)
    }
    
}
