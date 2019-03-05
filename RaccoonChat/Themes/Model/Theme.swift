//
//  Theme.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 06/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

enum Theme: Int {
  case Orange, Blue, Purple
  
  var mainColor: UIColor {
    switch self {
    case .Blue:
      return UIColor(red: 119/255, green: 139/255, blue: 235/255, alpha: 1)
    case .Orange:
      return UIColor(red: 241/255, green: 144/255, blue: 102/255, alpha: 1)
    case .Purple:
      return UIColor(red: 120/255, green: 111/255, blue: 166/255, alpha: 1)
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .Orange:
      return .default
    case .Blue, .Purple:
      return .black
    }
  }
  
}
