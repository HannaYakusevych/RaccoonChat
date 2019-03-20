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
  
  // MARK: Singleton
  static let shared = CommunicationManager()
  
  var updateChatList: (() -> Void)?
  var updateChat: (() -> Void)?
  
  var communicator: MultipeerCommunicator
  init() {
    self.communicator = MultipeerCommunicator()
    self.communicator.delegate = self
  }
  func didFoundUser(userID: String, userName: String?) {
    communicator.onlineUsers.sort(by: User.sortUsers(lhs:rhs:))
    updateChatList?()
  }
  
  func didLostUser(userID: String) {
    communicator.onlineUsers.sort(by: User.sortUsers(lhs:rhs:))
    updateChatList?()
  }
  
  func failedToStartBrowsingForUsers(error: Error) {
    assertionFailure(error.localizedDescription)
  }
  
  func failedToStartAdvertising(error: Error) {
    assertionFailure(error.localizedDescription)
  }
  
  func didReceiveMessage(text: String, fromUser: String, toUser: String) {
    let message = Message(isInput: true, text: text, date: Date(timeIntervalSinceNow: 0))
    communicator.onlineUsers.first(where: {$0.name == fromUser})?.chatHistory.append(message)
    updateChatList?()
    updateChat?()
  }
  
  
}
