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

  // MARK: UIViewController updates
  var updateChatList: (() -> Void)?
  var updateChat: (() -> Void)?

  var communicator: MultipeerCommunicator

  // Lists for all found peers
  var onlineUsers = [User]()
  var historyUsers = [User]()

  init() {
    self.communicator = MultipeerCommunicator()
    self.communicator.delegate = self
  }

  // Add user to the list
  func didFoundUser(userID: String, userName: String?) {
    onlineUsers.sort(by: User.sortUsers(lhs:rhs:))
    updateChatList?()
  }

  // Remove user from the list
  func didLostUser(userID: String) {
    for (index, user) in onlineUsers.enumerated() where user.name == userID {
      CommunicationManager.shared.onlineUsers.remove(at: index)
      user.online = false
      // If chat wasn't empty, save it till the end of session
      if user.chatHistory.count > 0 {
        historyUsers.append(user)
      }
    }
    onlineUsers.sort(by: User.sortUsers(lhs:rhs:))
    updateChatList?()
  }

  // Multipeer Communicator errors
  func failedToStartBrowsingForUsers(error: Error) {
    assertionFailure(error.localizedDescription)
  }
  func failedToStartAdvertising(error: Error) {
    assertionFailure(error.localizedDescription)
  }

  // Update table views with a new message
  func didReceiveMessage(text: String, fromUser: String, toUser: String) {
    let message = Message(isInput: true, text: text, date: Date())
    onlineUsers.first(where: {$0.name == fromUser})?.chatHistory.append(message)
    updateChatList?()
    updateChat?()
  }

}
