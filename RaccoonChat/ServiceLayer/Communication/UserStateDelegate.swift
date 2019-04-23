//
//  UserStateDelegate.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

protocol UserStateDelegate: class {
  var isOnline: Bool {get set}
  func setOffline(userId: String)
  func setOnline(userId: String)
}
