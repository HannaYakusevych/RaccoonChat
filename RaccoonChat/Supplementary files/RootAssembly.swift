//
//  RootAssembly.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 10/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class RootAssembly {
  static var communicationManager: CommunicationManager!

  init() {
    RootAssembly.communicationManager = CommunicationManager()
  }
}
