//
//  ConversationsService.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

protocol ConversationListServiceProtocol {
  func findOrInsertNewUser(userId: String) -> User?
  func findOrInsertNewDialog(user: User) -> Conversation?
  func setOfflineStatus(userId: String, completion: ((Bool) -> Void)?)
  func insertNewMessage(text: String, to user: String, isInput: Bool)
}

class ConversationListService: ConversationListServiceProtocol, ContextManagerProtocol {

  // MARK: - ContextManagerProtocol
  var coreDataStack: CoreDataStack
  init() {
    //self.coreDataStack = CoreDataStack()
    self.coreDataStack = RootAssembly.coreDataStack
  }

  func getMasterContext() -> NSManagedObjectContext? {
    return self.coreDataStack.masterContext
  }

  func getMainContext() -> NSManagedObjectContext? {
    return self.coreDataStack.mainContext
  }

  func getSaveContext() -> NSManagedObjectContext? {
    return self.coreDataStack.saveContext
  }

  func performSave(completion: ((Bool) -> Void)?) {
    self.coreDataStack.performSave(with: self.coreDataStack.saveContext, completion: completion)
  }

  // MARK: - ConversationListServiceProtocol
  func findOrInsertNewUser(userId: String) -> User? {
    return User.findOrInsertUser(userId: userId, in: self.coreDataStack.mainContext)
  }
  func findOrInsertNewDialog(user: User) -> Conversation? {
    return Conversation.findOrInsertConversation(user: user, context: self.coreDataStack.mainContext)
  }

  func setOfflineStatus(userId: String, completion: ((Bool) -> Void)?) {
    User.setOffline(userId: userId, context: self.coreDataStack.mainContext)
    self.coreDataStack.performSave(with: self.coreDataStack.mainContext, completion: completion)
  }
  func insertNewMessage(text: String, to user: String, isInput: Bool) {
    Message.insertNewMessage(text: text, to: user, in: self.coreDataStack.saveContext, isInput: isInput)
  }
}
