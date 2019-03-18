//
//  CommunicationManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 18/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class CommunicationManager: CommunicatorDelegate {
  
  var updateChat: (() -> Void)?
  
  var communicator: MultipeerCommunicator
  init() {
    self.communicator = MultipeerCommunicator()
    self.communicator.delegate = self
  }
  func didFoundUser(userID: String, userName: String?) {
    updateChat?()
  }
  
  func didLostUser(userID: String) {
    updateChat?()
  }
  
  func failedToStartBrowsingForUsers(error: Error) {
    assertionFailure(error.localizedDescription)
  }
  
  func failedToStartAdvertising(error: Error) {
    assertionFailure(error.localizedDescription)
  }
  
  func didReceiveMessage(text: String, fromUser: String, toUser: String) {
    // TODO: implement
  }
  
  
}
