//
//  ConversationListDataProvider.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class ConversationListDataProvider: NSObject {
  var fetchedResultsController: NSFetchedResultsController<User>
  var tableView: UITableView
  init(tableView: UITableView, context: NSManagedObjectContext) {
    self.tableView = tableView
    let request: NSFetchRequest<User> = User.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "isOnline", ascending: true),
                               NSSortDescriptor(key: "userId", ascending: true)]
    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: context,
                                                               sectionNameKeyPath: "isOnline",
                                                               cacheName: nil)
    super.init()
    self.fetchedResultsController.delegate = self
  }
  func loadConversations() {
    do {
      try self.fetchedResultsController.performFetch()
    } catch {
      Logger.write("Error loading conversations")
    }
  }
}

extension ConversationListDataProvider: NSFetchedResultsControllerDelegate {
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
