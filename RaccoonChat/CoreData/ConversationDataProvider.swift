//
//  ConversationDataProvider.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 02/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class ConversationDataProvider: NSObject {
  var fetchedResultsController: NSFetchedResultsController<Message>
  var tableView: UITableView
  init(conversationID: String, tableView: UITableView, context: NSManagedObjectContext) {
    self.tableView = tableView
    let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "conversation.conversationID == %@", conversationID)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    self.fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: fetchRequest,
                                                                        managedObjectContext: context,
                                                                        sectionNameKeyPath: nil,
                                                                        cacheName: nil)
    super.init()
    self.fetchedResultsController.delegate = self
  }
  func loadMessages() {
    do {
      try self.fetchedResultsController.performFetch()
    } catch {
      print("Error fetching messages: \(error.localizedDescription)")
    }
  }
}

extension ConversationDataProvider: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .delete:
      if let indexPath = indexPath {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    case .insert:
      if let newIndexPath = newIndexPath {
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      }
    case .update:
      if let indexPath = indexPath {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
      }
    case .move:
      if let indexPath = indexPath, let newIndexPath = newIndexPath {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      }
    }
  }
}
