//
//  Theme.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 05/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

enum Theme {
  case Orange, Blue, Dark
  
  var mainColor: UIColor {
    switch self {
    case .Orange:
      return UIColor(red: 119/255, green: 139/255, blue: 235/255, alpha: 1)
    case .Blue:
      return UIColor(red: 241/255, green: 144/255, blue: 102/255, alpha: 1)
    case .Dark:
      return UIColor(red: 48/255, green: 57/255, blue: 82/255, alpha: 1)
    }
  }
  
}


