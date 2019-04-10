//
//  Communicator.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 18/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator {
  func sendMessage(string: String, to userId: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void))
  var delegate: CommunicatorDelegate? {get set}
  var online: Bool {get set}
}
