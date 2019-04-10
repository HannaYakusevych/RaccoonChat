//
//  CoreDataStack.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 20/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  static let shared = CoreDataStack()

  // MARK: - NSPersistentStore
  private var storeURL: URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsURL.appendingPathComponent("TheStore.sqlite")
  }

  // MARK: - NSManagedObjectModel
  private let dataModelName = "RaccoonChat"

  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  // MARK: - NSPersistentStoreCoordinator
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
    } catch {
      assert(false, "Error adding store: \(error)")
    }

    return coordinator
  }()

  // MARK: - Contexts
  lazy var masterContext: NSManagedObjectContext = {
    var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    masterContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    masterContext.mergePolicy = NSOverwriteMergePolicy
    return masterContext
  }()

  lazy var mainContext: NSManagedObjectContext = {
    var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    //mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    mainContext.parent = self.masterContext
    mainContext.mergePolicy = NSOverwriteMergePolicy
    return mainContext
  }()

  lazy var saveContext: NSManagedObjectContext = {
    var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    saveContext.parent = self.mainContext
    saveContext.mergePolicy = NSOverwriteMergePolicy
    return saveContext
  }()

  // MARK: - Saving
  typealias SaveCompletion = (Bool) -> Void
  func performSave(with context: NSManagedObjectContext, completion: SaveCompletion? = nil) {
    print(context)
    context.perform {
      // Check if there is something new to save
      guard context.hasChanges else {
        Logger.write("No changes to save in \(context)")
        completion?(true)
        return
      }
      // Try to save
      do {
        try context.save()
      } catch {
        Logger.write("Context save error: \(error.localizedDescription)")
        completion?(false)
        return
      }

      if let parentContext = context.parent {
        self.performSave(with: parentContext, completion: completion)
      } else {
        completion?(true)
      }
    }
  }
}
