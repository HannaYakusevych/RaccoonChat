//
//  Message.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

extension Message {
  static func insertNewMessage(text: String, to userId: String, in context: NSManagedObjectContext, isInput: Bool) {
    if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
      guard let user = User.findOrInsertUser(userId: userId, in: context) else {
        Logger.write("Can't find corresponding user")
        return
      }
      guard let conversation = Conversation.findOrInsertConversation(user: user, context: context) else {
        Logger.write("Can't find or insert conversation")
        return
      }
      message.conversation = conversation
      message.id = generateMessageId()
      message.date = Date()
      message.text = text
      message.isInput = isInput
      conversation.addToMessages(message)
    }
  }
  static func generateMessageId() -> String {
    let date = Date.timeIntervalSinceReferenceDate
    let string = "\(arc4random_uniform(UINT32_MAX))+\(date)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
    return string!
  }
}
