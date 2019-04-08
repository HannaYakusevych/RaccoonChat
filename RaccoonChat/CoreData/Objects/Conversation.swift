//
//  Conversation.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 01/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

extension Conversation {
  static func insertConversation(user: User, context: NSManagedObjectContext) -> Conversation? {
    guard let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation else {
      return nil
    }
    conversation.user = user
    conversation.conversationId = user.userId
    return conversation
  }
  static func findOrInsertConversation(user: User, context: NSManagedObjectContext) -> Conversation? {
    var conversation: Conversation?
    conversation = user.conversation
    if conversation == nil {
      conversation = Conversation.insertConversation(user: user, context: context)
    }
    return conversation
  }
}
