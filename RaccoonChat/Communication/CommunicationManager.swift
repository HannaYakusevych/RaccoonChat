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
      // If chat wasn't empty, save it
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

// MARK: - Helping structs (data source)
class User {
  var name = "Name"
  var peerId: MCPeerID

  var message: String? { return chatHistory.last?.text  }
  var date: Date? { return chatHistory.last?.date }

  var hasUnreadMessages = false
  var online = true
  var connected = false
  var photo: UIImage?
  var chatHistory = [Message]()

  init(peerId: MCPeerID) {
    self.peerId = peerId
    self.name = peerId.displayName
  }

  static func sortUsers(lhs: User, rhs: User) -> Bool {
    switch (lhs.date, rhs.date) {
    case (nil, nil):
      return lhs.name < rhs.name
    case (nil, _):
      return false
    case ( _, nil):
      return true
    case (let lhs, let rhs):
      return lhs! < rhs!
    }
  }
}

struct Message {
  let isInput: Bool
  let text: String
  let date: Date
}
