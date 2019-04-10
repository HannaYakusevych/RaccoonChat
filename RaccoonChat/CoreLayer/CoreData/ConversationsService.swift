//
//  ConversationsService.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class ConversationsService {
  var coreDataStack: CoreDataStack
  init() {
    //self.coreDataStack = CoreDataStack()
    self.coreDataStack = CoreDataStack.shared
  }
  func findOrInsertNewUser(userId: String, name: String?) -> User? {
    return User.findOrInsertUser(userId: userId, in: self.coreDataStack.mainContext)
  }
  func findOrInsertNewDialog(user: User) -> Conversation? {
    return Conversation.findOrInsertConversation(user: user, context: self.coreDataStack.mainContext)
  }
  func performSave(completion: ((Bool) -> Void)?) {
    self.coreDataStack.performSave(with: self.coreDataStack.saveContext, completion: completion)
  }
  func setOfflineStatus(userID: String, completion: ((Bool) -> Void)?) {
    User.setOffline(userId: userID, context: self.coreDataStack.mainContext)
    self.coreDataStack.performSave(with: self.coreDataStack.mainContext, completion: completion)
  }
  func insertNewMessage(text: String, to user: String, isInput: Bool) {
    Message.insertNewMessage(text: text, to: user, in: self.coreDataStack.saveContext, isInput: isInput)
  }
}
