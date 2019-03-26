//
//  ConversationViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 25/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet var newMessageView: UIView!
  @IBOutlet var newMessageTextView: UITextView!
  @IBOutlet var sendButton: UIButton!
  @IBAction func sendMessage(_ sender: Any) {
    //newMessageTextView.resignFirstResponder()
    guard let user = CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!}), user.connected else {
      return
    }
    CommunicationManager.shared.communicator.sendMessage(string: newMessageTextView.text, to: self.title!) { isSent, error in
      if !isSent {
        Logger.write(error?.localizedDescription ?? "Message sending error: user is unknown")
        return
      }
      let message = Message(isInput: false, text: newMessageTextView.text, date: Date(timeIntervalSinceReferenceDate: 0))
      CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!})?.chatHistory.append(message)
      self.tableView.reloadData()
      DispatchQueue.main.async { self.tableView.reloadData() }
      newMessageTextView.text = ""
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    CommunicationManager.shared.updateChat = {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
    
    // Listen for keyboard events
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    // Theme managing
    newMessageView.backgroundColor = ThemeManager.currentTheme().mainColor
    newMessageTextView.layer.cornerRadius = newMessageTextView.frame.height / 4
    
    // Add gesture recognizer to close tho keyboard
    configureTapGesture()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    // To insert messages from bottom
    tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    
    self.tableView.reloadData()
    
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  deinit {
    // Stop listening for keyboard hide/show events
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }

  // MARK: - Table view data source

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!})?.chatHistory.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let numberOfMessages = (CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!})?.chatHistory.count)! - 1
    let identifier = (CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!})?.chatHistory[numberOfMessages-indexPath.row].isInput)! ? "InputMessageCell" : "OutputMessageCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
    cell.textMessage = CommunicationManager.shared.communicator.onlineUsers.first(where: {$0.name == self.title!})?.chatHistory[numberOfMessages-indexPath.row].text
    cell.sizeToFit()

    // To insert messages from bottom
    cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    return cell
  }
}


// MARK: - UITextViewDelegate
extension ConversationViewController: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    textView.inputAccessoryView = newMessageView
    return true
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.resignFirstResponder()
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    textView.inputAccessoryView = nil
    return true
  }
  
  // Private functions
  private func configureTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
    view.addGestureRecognizer(tapGesture)
  }
  
  // Resign keyboard if tapped on view
  @objc func handleTap() {
    newMessageTextView.resignFirstResponder()
  }
  
  // Handling covering TextView by keyboard
  @objc func keyboardWillChange(notification: Notification) {
    
    Logger.write("Keyboard is changing the state")
    guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
      //self.descriptionTextView.inputAccessoryView = keyboardToolbar
      view.frame.origin.y = -keyboardRect.height
    } else  if notification.name == UIResponder.keyboardWillHideNotification {
      //self.descriptionTextView.inputAccessoryView = nil
      //view.frame.origin.y += keyboardRect.height * 1.2
      
      view.frame.origin.y = 0
    }
  }
}
