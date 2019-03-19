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
    if let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfViewController") as? ProfileViewController {
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
    
    let themesViewController = navigationController.viewControllers.first as! ThemesViewController
    themesViewController.changeColor = { (selectedTheme: UIColor) in
      
      switch selectedTheme {
      case Theme.Blue.mainColor:
        ThemeManager.applyTheme(theme: Theme.Blue)
      case Theme.Orange.mainColor:
        ThemeManager.applyTheme(theme: Theme.Orange)
      case Theme.Purple.mainColor:
        ThemeManager.applyTheme(theme: Theme.Purple)
      default:
        Logger.write("Error: the selected theme is out of available")
      }
      
      themesViewController.view.backgroundColor = selectedTheme
      navigationController.navigationBar.barStyle = ThemeManager.currentTheme().barStyle
      navigationController.navigationBar.backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(0.7)
     
      self.tableView.reloadData()
     
      self.logThemeChanging(selectedTheme: selectedTheme)
    }
    
    themesViewController.model = Themes(firstColor: Theme.Orange.mainColor, second: Theme.Blue.mainColor, third: Theme.Purple.mainColor)
    self.present(navigationController, animated: true, completion: nil)
  }
  
  @IBOutlet weak var showProfileButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    CommunicationManager.shared.updateChat = {self.tableView.reloadData()}
    // TODO: Check!!
    //communicationManager.communicator.goToChat = { indexPath in
    //  goToConversation(indexPath: indexPath)
    //}
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
    if indexPath.section == 0 {
      cell.name = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].name
      cell.message = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].message
      cell.date = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].date
      cell.online = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].online
      cell.hasUnreadMessages = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].hasUnreadMessages
      cell.photo = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].photo
    }
    else {
      cell.name = CommunicationManager.shared.communicator.historyUsers[indexPath.row].name
      cell.message = CommunicationManager.shared.communicator.historyUsers[indexPath.row].message
      cell.date = CommunicationManager.shared.communicator.historyUsers[indexPath.row].date
      cell.online = CommunicationManager.shared.communicator.historyUsers[indexPath.row].online
      cell.hasUnreadMessages = CommunicationManager.shared.communicator.historyUsers[indexPath.row].hasUnreadMessages
      cell.photo = CommunicationManager.shared.communicator.historyUsers[indexPath.row].photo
    }

    return cell
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return CommunicationManager.shared.communicator.onlineUsers.count
    }
    return CommunicationManager.shared.communicator.historyUsers.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Online"
    }
    return "History"
  }
  
  // MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !CommunicationManager.shared.communicator.onlineUsers[indexPath.row].connected {
      let selectedPeer = CommunicationManager.shared.communicator.onlineUsers[indexPath.row].peerId
      CommunicationManager.shared.communicator.inviteUser(peerId: selectedPeer)
      goToConversation(indexPath: indexPath)
    } else {
      goToConversation(indexPath: indexPath)
    }
  }
  
  func goToConversation(indexPath: IndexPath) {
    if let viewController = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewController(withIdentifier: "ConvViewController") as? ConversationViewController {
      viewController.title = indexPath.section == 0 ? CommunicationManager.shared.communicator.onlineUsers[indexPath.row].name : CommunicationManager.shared.communicator.historyUsers[indexPath.row].name
      viewController.messages = indexPath.section == 0 ? CommunicationManager.shared.communicator.onlineUsers[indexPath.row].chatHistory : CommunicationManager.shared.communicator.historyUsers[indexPath.row].chatHistory
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

