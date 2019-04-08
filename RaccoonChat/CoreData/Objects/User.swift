//
//  User.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

extension User {
  static func insertUser(userId: String, in context: NSManagedObjectContext) -> User? {
    guard let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User else { return nil }
    user.userId = userId
    return user
  }
  static func findOrInsertUser(userId: String, in context: NSManagedObjectContext) -> User? {
    guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
      assert(false, "Model is not available in context")
      return nil
    }
    var user: User?
    guard let fetchRequest = User.fetchRequestUserById(userId: userId, model: model) else {
      return nil
    }
    do {
      let results = try context.fetch(fetchRequest)
      assert(results.count < 2, "Multiple Users with the same ID found!")
      if let foundUser = results.first {
        user = foundUser
      }
    } catch {
      print("Failed to fetch User: \(error)")
    }
    if user == nil {
      user = User.insertUser(userId: userId, in: context)
    }
    return user
  }
  // MARK: - Fetch requests
  static func fetchRequestUser() -> NSFetchRequest<User>? {
    return User.fetchRequest()
  }
  static func fetchRequestUserById(userId: String, model: NSManagedObjectModel) -> NSFetchRequest<User>? {
    guard let fetchRequest = User.fetchRequestUser() else {
      return nil
    }
    fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
    return fetchRequest
  }
  static func setOffline(userId: String, context: NSManagedObjectContext) {
    guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
      assert(false, "Model is not available in this context")
      return
    }
    var user: User?
    guard let fetchRequest = User.fetchRequestUserById(userId: userId, model: model) else {
      return
    }
    do {
      let users = try context.fetch(fetchRequest)
      assert(users.count < 2, "More then one user found with id \(userId)")
      if let foundUser = users.first {
        user = foundUser
      }
    } catch {
      print("Error fetching user: \(error)")
    }
    user?.isOnline = false
  }
}
