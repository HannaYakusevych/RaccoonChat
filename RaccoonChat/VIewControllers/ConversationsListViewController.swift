//
//  ConversationsListViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 24/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {

  @IBAction func goToProfile(_ sender: Any) {
    if let viewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfViewController") as? ProfileViewController {
      self.present(viewController, animated: true, completion: nil)
      
    }
    print("hello")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.reloadData()
    // Do any additional setup after loading the view.
  }
  
  // MARK: - Table view data source
  
  // Just for representing cell styles
  let onlineUsers = [User(name: "Name 1", message: nil, date: nil, online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 7", message: "Hello", date: Date(timeIntervalSince1970: 10000000), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 2", message: "Hello", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 3", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 4", message: "Hello", date: Date(timeIntervalSinceNow: -900), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 5", message: "Hello", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: true, photo: nil),
                     User(name: "Name 6", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: true, hasUnreadMessages: true, photo: nil),
                     User(name: "Name 8", message: "Hello", date: Date(timeIntervalSinceNow: -30000), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 9", message: "Hello", date: Date(timeIntervalSince1970: 500), online: true, hasUnreadMessages: false, photo: nil),
                     User(name: "Name 10", message: "Hello", date: Date(timeIntervalSinceNow: -90), online: true, hasUnreadMessages: false, photo: nil)]
  
  let offlineUsers = [User(name: "Name 11", message: nil, date: nil, online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 12", message: "Hello", date: Date(timeIntervalSince1970: 500), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 13", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 14", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 15", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 16", message: "Hello", date: Date(timeIntervalSince1970: 500), online: false, hasUnreadMessages: true, photo: nil),
                      User(name: "Name 17", message: "Hello", date: Date(timeIntervalSinceNow: -300), online: false, hasUnreadMessages: true, photo: nil),
                      User(name: "Name 18", message: "Hello", date: Date(timeIntervalSinceNow: -30), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 19", message: "Hello", date: Date(timeIntervalSince1970: 5000000), online: false, hasUnreadMessages: false, photo: nil),
                      User(name: "Name 20", message: "Hello", date: Date(timeIntervalSinceNow: -3000000), online: false, hasUnreadMessages: false, photo: nil)]
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
    if indexPath.section == 0 {
      cell.name = onlineUsers[indexPath.row].name
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
    return 10
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
      viewController.title = indexPath.section == 0 ? onlineUsers[indexPath.row].name : offlineUsers[indexPath.row].name
      navigationController?.pushViewController(viewController, animated: true)
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
