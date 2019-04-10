//
//  ContextManagerProtocol.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 10/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

protocol ContextManagerProtocol {
  var coreDataStack: CoreDataStack { get set }
  func performSave(completion: ((Bool) -> Void)?)
  func getMasterContext() -> NSManagedObjectContext?
  func getMainContext() -> NSManagedObjectContext?
  func getSaveContext() -> NSManagedObjectContext?
}
