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

  var communicator: MultipeerCommunicator
  // Communication with the view controller
  weak var delegate: CommunicationManagerDelegate?
  weak var changeUserState: UserStateDelegate?
  weak var newMessageDelegate: NewMessageDelegate?

  init() {
    self.communicator = MultipeerCommunicator()
    self.communicator.delegate = self
  }

  // Add user to the list
  func didFoundUser(userID: String, userName: String?) {
    Logger.write("")
    self.delegate?.moveUserToOnlineSection(userId: userID, userName: userName)
    self.changeUserState?.setOnline(userId: userID)
  }

  // Remove user from the list
  func didLostUser(userID: String) {
    Logger.write("")
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
    newMessageDelegate?.reloadData()
  }

}
