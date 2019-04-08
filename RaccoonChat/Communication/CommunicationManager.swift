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

  var communicator: MultipeerCommunicator
  // Communication with the view controller
  weak var delegate: CommunicationManagerDelegate?
  weak var changeUserState: UserStateDelegate?

  init() {
    self.communicator = MultipeerCommunicator()
    self.communicator.delegate = self
  }

  // Add user to the list
  func didFoundUser(userID: String, userName: String?) {
    self.delegate?.moveUserToOnlineSection(userId: userID, userName: userName)
    self.changeUserState?.setOnline(userId: userID)
  }

  // Remove user from the list
  func didLostUser(userID: String) {
    self.delegate?.moveUserToHistorySection(userId: userID)
    self.changeUserState?.setOffline(userId: userID)
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
    delegate?.didReceiveNewMessage(text: text, from: fromUser)
  }

}
/*
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
*/
