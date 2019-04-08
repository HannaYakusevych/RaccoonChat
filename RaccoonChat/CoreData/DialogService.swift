//
//  DialogService.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class DialogService {
  var coreDataStack: CoreDataStack
  init() {
    self.coreDataStack = CoreDataStack()
  }
  func findOrInsertNewUser(userId: String) -> User? {
    return User.findOrInsertUser(userId: userId, in: self.coreDataStack.mainContext)
  }
  func findOrInsertNewDialog(user: User) -> Conversation? {
    return Conversation.findOrInsertConversation(user: user, context: self.coreDataStack.mainContext)
  }
  func performSave(completion: ((Bool) -> Void)?) {
    self.coreDataStack.performSave(with: self.coreDataStack.saveContext, completion: completion)
  }
  func setOfflineStatus(userID: String, complition: ((Bool) -> Void)?) {
    User.setOffline(userId: userID, context: self.coreDataStack.mainContext)
    self.coreDataStack.performSave(with: self.coreDataStack.saveContext, completion: complition)
  }
  func insertNewMessage(text: String, to user: String, isInput: Bool) {
    Message.insertNewMessage(text: text, to: user, in: self.coreDataStack.saveContext, isInput: isInput)
  }
}
