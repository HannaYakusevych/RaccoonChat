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
  // NSPersistentStore
  private var storeURL: URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsURL.appendingPathComponent("TheStore.sqlite")
  }
  
  // NSManagedObjectModel
  private let dataModelName = "RaccoonChat"
  
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  
  // NSPersistentStoreCoordinator
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
    } catch {
      assert(false, "Error adding store: \(error)")
    }
    
    return coordinator
  }()
  
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
    ///saveContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    saveContext.parent = self.mainContext
    saveContext.mergePolicy = NSOverwriteMergePolicy
    return saveContext
  }()
  
  typealias SaveCompletion = () -> Void
  func performSave(with context: NSManagedObjectContext, completion: SaveCompletion? = nil) {
    context.perform {
      guard context.hasChanges else {
        completion?()
        return
      }
      do {
        try context.save()
      } catch {
        print("Context save error: \(error)")
      }
      
      if let parentContext = context.parent {
        self.performSave(with: parentContext, completion: completion)
      } else {
        completion?()
      }
    }
  }
}
