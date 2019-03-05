//
//  ThemeManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 05/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

// String for saving in UserDefaults
let SelectedThemeKey = "SelectedTheme"

struct ThemeManager {
  
  static func currentTheme() -> Theme {
    if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
      return Theme(rawValue: storedTheme)!
    } else {
      return .Orange
    }
  }
  
  static func applyTheme(theme: Theme) {
    UserDefaults.standard.set(theme.rawValue, forKey: SelectedThemeKey)
    UserDefaults.standard.synchronize()
    
    let sharedApplication = UIApplication.shared
    sharedApplication.delegate?.window??.tintColor = theme.mainColor
    UINavigationBar.appearance().barStyle = ThemeManager.currentTheme().barStyle
    UINavigationBar.appearance().backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(0.7)
  }
}


