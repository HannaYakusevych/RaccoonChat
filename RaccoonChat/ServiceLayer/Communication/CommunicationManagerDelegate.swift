//
//  CommunicationManagerDelegate.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

protocol CommunicationManagerDelegate: class {
  func moveUserToOnlineSection(userId: String, userName: String?)
  func moveUserToHistorySection(userId: String)
  func didReceiveNewMessage(text: String, from user: String)
}
