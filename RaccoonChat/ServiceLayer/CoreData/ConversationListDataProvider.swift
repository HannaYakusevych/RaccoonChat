//
//  ConversationListDataProvider.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

protocol ConversationListDataManagerProtocol: class {
  var fetchedResultsController: NSFetchedResultsController<User> { get }
  var tableView: UITableView { get }
  func loadConversations()
}

class ConversationListDataManager: NSObject, ConversationListDataManagerProtocol {
  var fetchedResultsController: NSFetchedResultsController<User>
  var tableView: UITableView
  init(tableView: UITableView, context: NSManagedObjectContext) {
    self.tableView = tableView
    let request: NSFetchRequest<User> = User.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "isOnline", ascending: false),
                               NSSortDescriptor(key: "userId", ascending: true)]
    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: context,
                                                               sectionNameKeyPath: "isOnline",
                                                               cacheName: nil)
    super.init()
    self.fetchedResultsController.delegate = self
    self.fetchedResultsController.fetchRequest.fetchBatchSize = 30
    self.fetchedResultsController.fetchRequest.returnsObjectsAsFaults = false
  }
  func loadConversations() {
    do {
      try self.fetchedResultsController.performFetch()
    } catch {
      Logger.write("Error loading conversations")
    }
  }
}

extension ConversationListDataManager: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let newIndexPath = newIndexPath {
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      }
    case .move:
      if let indexPath = indexPath, let newIndexPath = newIndexPath {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      }
    case .update:
      if let indexPath = indexPath {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
      }
    case .delete:
      if let indexPath = indexPath {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }
  }
}
