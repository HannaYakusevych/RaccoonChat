//
//  ConversationsListViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 24/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit
import CoreData

class ConversationsListViewController: UITableViewController {
  var onlineUsers = [User]()
  var historyUsers = [User]()
  var conversationsService = ConversationsService()
  var conversationListDataProvider: ConversationListDataProvider?
  var dialogService = DialogService()

  // MARK: - Actions
  @IBAction func goToProfile(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Profile", bundle: nil)
    if let viewController = storyboard.instantiateViewController(withIdentifier: "ProfViewController") as? ProfileViewController {
      let navigationController = UINavigationController.init(rootViewController: viewController)
      self.present(navigationController, animated: true, completion: nil)
    }
  }
  @IBAction func selectNewTheme(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Themes", bundle: nil)
    guard let navigationController = storyboard.instantiateViewController(withIdentifier: "ThemeController") as? UINavigationController else {
      Logger.write("Error: the ThemesViewController is unavailable")
      fatalError()
    }

    guard let themesViewController = navigationController.viewControllers.first as? ThemesViewController else {
      return
    }

    themesViewController.changeColor = { (selectedTheme: UIColor) in

      switch selectedTheme {
      case Theme.blue.mainColor:
        ThemeManager.applyTheme(theme: Theme.blue)
      case Theme.orange.mainColor:
        ThemeManager.applyTheme(theme: Theme.orange)
      case Theme.purple.mainColor:
        ThemeManager.applyTheme(theme: Theme.purple)
      default:
        Logger.write("Error: the selected theme is out of available")
      }

      themesViewController.view.backgroundColor = selectedTheme
      navigationController.navigationBar.barStyle = ThemeManager.currentTheme().barStyle
      navigationController.navigationBar.backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(0.7)

      self.tableView.reloadData()

      self.logThemeChanging(selectedTheme: selectedTheme)
    }

    themesViewController.model = Themes(firstColor: Theme.orange.mainColor, second: Theme.blue.mainColor, third: Theme.purple.mainColor)
    self.present(navigationController, animated: true, completion: nil)
  }

  @IBOutlet weak var showProfileButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    CommunicationManager.shared.delegate = self
    self.conversationListDataProvider = ConversationListDataProvider(tableView: self.tableView,
                                                             context: self.conversationsService.coreDataStack.mainContext)
    self.conversationListDataProvider?.loadConversations()
    tableView.reloadData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.tableView.reloadData()
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell else {
      fatalError("Cell format is wrong")
    }
    if let user = self.conversationListDataProvider?.fetchedResultsController.object(at: indexPath) {
      cell.name = user.name
      cell.message = user.lastMessage
      cell.date = user.lastMessageDate
      cell.online = user.isOnline
      cell.hasUnreadMessages = user.hasUnreadMessage
      if let image = user.image {
        cell.photo = UIImage(data: image)
      } else {
        cell.photo = nil
      }
    }
    return cell
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let numberOfSections = self.conversationListDataProvider?.fetchedResultsController.sections?.count else {
      return 0
    }
    return numberOfSections
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = self.conversationListDataProvider?.fetchedResultsController.sections else {
      return 0
    }
    print("Number of objects in section: \(sections[section].numberOfObjects)")
    return sections[section].numberOfObjects
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Online"
    }
    return "History"
  }

  // MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    goToConversation(indexPath: indexPath)
  }

  func goToConversation(indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Conversation", bundle: nil)
    if let viewController = storyboard.instantiateViewController(withIdentifier: "ConvViewController") as? ConversationViewController {
      viewController.title = self.conversationListDataProvider?.fetchedResultsController.object(at: indexPath).name ?? "Name unspecified"
      viewController.conversationsService = self.conversationsService
      viewController.dialogService = self.dialogService
      navigationController?.pushViewController(viewController, animated: true)
    }
  }

  // MARK: - Theme changing methods
  func logThemeChanging(selectedTheme: UIColor) {
    if let components = selectedTheme.cgColor.components {
      Logger.write("to the color 'red: \(components[0]), green: \(components[1]), blue: \(components[2]), alpha: \(components[3])'")
    } else {
      Logger.write("Error: the new theme color is nil")
    }
  }
}

extension ConversationsListViewController: CommunicationManagerDelegate {
  func moveUserToOnlineSection(userId: String, userName: String?) {
    guard let user = dialogService.findOrInsertNewUser(userId: userId) else {
      assert(false, "Some error with find or insert user")
      return
    }
    user.name = userName
    if let conversation = dialogService.findOrInsertNewDialog(user: user) {
      conversation.user?.isOnline = true
      self.conversationsService.performSave(completion: { isSaved in
        print(isSaved ? "User saved" : "Can't save user")
      })
    }
    reloadTableView()
  }
  func moveUserToHistorySection(userId: String) {
    self.dialogService.setOfflineStatus(userID: userId, complition: nil)
    reloadTableView()
  }
  func didReceiveNewMessage(text: String, from userId: String) {
    guard let user = self.dialogService.findOrInsertNewUser(userId: userId) else {
      print("Error finding and inserting user")
      return
    }
    user.lastMessage = text
    user.lastMessageDate = Date()
    self.dialogService.insertNewMessage(text: text, to: userId, isInput: true)
    self.conversationsService.performSave(completion: nil)
    reloadTableView()
  }
}

extension ConversationsListViewController: ConversationsListDelegate {
  func reloadTableView() {
    conversationListDataProvider?.loadConversations()
    self.onlineUsers = self.onlineUsers.sorted(by: { $0.lastMessageDate?.compare($1.lastMessageDate!) == .orderedDescending })
    self.tableView.reloadData()
  }
}
