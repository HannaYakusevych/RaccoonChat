//
//  ConversationsListViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 24/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {

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
    CommunicationManager.shared.updateChatList = {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
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
    if indexPath.section == 0 {
      cell.name = CommunicationManager.shared.onlineUsers[indexPath.row].name
      cell.message = CommunicationManager.shared.onlineUsers[indexPath.row].message
      cell.date = CommunicationManager.shared.onlineUsers[indexPath.row].date
      cell.online = CommunicationManager.shared.onlineUsers[indexPath.row].online
      cell.hasUnreadMessages = CommunicationManager.shared.onlineUsers[indexPath.row].hasUnreadMessages
      cell.photo = CommunicationManager.shared.onlineUsers[indexPath.row].photo
    } else {
      cell.name = CommunicationManager.shared.historyUsers[indexPath.row].name
      cell.message = CommunicationManager.shared.historyUsers[indexPath.row].message
      cell.date = CommunicationManager.shared.historyUsers[indexPath.row].date
      cell.online = CommunicationManager.shared.historyUsers[indexPath.row].online
      cell.hasUnreadMessages = CommunicationManager.shared.historyUsers[indexPath.row].hasUnreadMessages
      cell.photo = CommunicationManager.shared.historyUsers[indexPath.row].photo
    }

    return cell
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return CommunicationManager.shared.onlineUsers.count
    }
    return CommunicationManager.shared.historyUsers.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Online"
    }
    return "History"
  }

  // MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !CommunicationManager.shared.onlineUsers[indexPath.row].connected {
      let selectedPeer = CommunicationManager.shared.onlineUsers[indexPath.row].peerId
      CommunicationManager.shared.communicator.inviteUser(peerId: selectedPeer)
      goToConversation(indexPath: indexPath)
    } else {
      goToConversation(indexPath: indexPath)
    }
  }

  func goToConversation(indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Conversation", bundle: nil)
    if let viewController = storyboard.instantiateViewController(withIdentifier: "ConvViewController") as? ConversationViewController {
      if indexPath.section == 0 {
        viewController.title = CommunicationManager.shared.onlineUsers[indexPath.row].name
      } else {
        viewController.title = CommunicationManager.shared.historyUsers[indexPath.row].name
      }
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
