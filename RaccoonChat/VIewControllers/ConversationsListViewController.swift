//
//  ConversationsListViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 24/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {
  
  let communicationManager = CommunicationManager()

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
    communicationManager.updateChat = {self.tableView.reloadData()}

    tableView.reloadData()
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: - Table view data source
  
  // Just for representing cell styles
  let onlineUsers = [User(name: "Name 1", message: nil, date: nil, online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 7", message: "Old message", date: Date(timeIntervalSince1970: 10000000), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 2", message: "Hello", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 3", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 4", message: "Hello", date: Date(timeIntervalSinceNow: -900), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 5", message: "Unread Message", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: true, photo: nil),
                     User(name: "Name 6", message: "Unread Message", date: Date(timeIntervalSinceNow: -30), online: true, hasUnreadMessages: true, photo: nil),
                     User(name: "Name 8", message: "Hello", date: Date(timeIntervalSinceNow: -30000), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 9", message: "Hello", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 10", message: "Hello", date: Date(timeIntervalSinceNow: -90), online: true, hasUnreadMessages: false, photo: nil)]
  
  let offlineUsers: [User] = []
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
    if indexPath.section == 0 {
      cell.name = communicationManager.communicator.foundPeers[indexPath.row].displayName
      cell.message = onlineUsers[indexPath.row].message
      cell.date = onlineUsers[indexPath.row].date
      cell.online = onlineUsers[indexPath.row].online
      cell.hasUnreadMessages = onlineUsers[indexPath.row].hasUnreadMessages
      cell.photo = onlineUsers[indexPath.row].photo
    }
    else {
      cell.name = offlineUsers[indexPath.row].name
      cell.message = offlineUsers[indexPath.row].message
      cell.date = offlineUsers[indexPath.row].date
      cell.online = offlineUsers[indexPath.row].online
      cell.hasUnreadMessages = offlineUsers[indexPath.row].hasUnreadMessages
      cell.photo = offlineUsers[indexPath.row].photo
    }

    return cell
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return communicationManager.communicator.foundPeers.count
    }
    return offlineUsers.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Online"
    }
    return "History"
  }
  
  // MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let viewController = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewController(withIdentifier: "ConvViewController") as? ConversationViewController {
      viewController.title = indexPath.section == 0 ? communicationManager.communicator.foundPeers[indexPath.row].displayName : offlineUsers[indexPath.row].name
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
  
  // MARK: - Navigation
  /*
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }
 */

}


// MARK: User class - just for the task
struct User {
  var name = "Name"
  var message: String? = nil
  var date: Date? = nil
  var online = false
  var hasUnreadMessages = false
  var photo: UIImage? = nil
}
