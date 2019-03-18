//
//  CommunicatorDelegate.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 18/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol CommunicatorDelegate: class {
  //discovering
  func didFoundUser(userID: String, userName: String?)
  func didLostUser(userID: String)
  
  //errors
  func failedToStartBrowsingForUsers(error: Error)
  func failedToStartAdvertising(error: Error)
  
  //messages
  func didReceiveMessage(text: String, fromUser: String, toUser: String)
}
