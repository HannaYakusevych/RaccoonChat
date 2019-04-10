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

  var contextManager: ContextManagerProtocol?
  var conversationListService: ConversationListServiceProtocol?
  var conversationDataManager: ConversationDataManagerProtocol?

  @IBAction func sendMessage(_ sender: Any) {
    // If the message is empty, don't send anything
    if newMessageTextView.text == "" {
      return
    }
    RootAssembly.communicationManager.communicator.sendMessage(string: self.newMessageTextView.text, to: self.title!) { isSent, error in
      if !isSent {
        Logger.write(error?.localizedDescription ?? "Message sending error: user is unknown")
        return
      }
      guard let user = self.conversationListService?.findOrInsertNewUser(userId: self.title!) else {
        return
      }
      user.lastMessage = self.newMessageTextView.text
      user.lastMessageDate = Date()
      self.conversationListService?.insertNewMessage(text: self.newMessageTextView.text,
                                           to: self.title!, isInput: false)
      self.contextManager?.performSave(completion: nil)
      self.newMessageTextView.text = ""
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Listen for keyboard events
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)),
                                           name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)),
                                           name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    // Theme managing
    newMessageView.backgroundColor = ThemeManager.currentTheme().mainColor
    newMessageTextView.layer.cornerRadius = newMessageTextView.frame.height / 4

    // Add gesture recognizer to close tho keyboard
    configureTapGesture()

    self.tableView.delegate = self
    self.tableView.dataSource = self

    // To insert messages from bottom
    self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

    let conversationListService = ConversationListService()
    self.conversationListService = conversationListService
    self.contextManager = conversationListService

    guard let mainContext = self.contextManager?.getMainContext() else {
      assert(false, "Error: mainContext doesn't exist")
      return
    }
    self.conversationDataManager = ConversationDataManager(conversationID: self.title!,
                                                             tableView: self.tableView,
                                                             context: mainContext)
    self.conversationDataManager?.loadMessages()

    self.tableView.reloadData()
  }

  deinit {
    // Stop listening for keyboard hide/show events
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }

  // MARK: - Table view data source

  func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = self.conversationDataManager?.fetchedResultsController.sections else {
      return 0
    }
    return sections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = self.conversationDataManager?.fetchedResultsController.sections else {
      return 0
    }
    return sections[section].numberOfObjects
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let fetchResult = self.conversationDataManager?.fetchedResultsController.sections?[indexPath.section]
    let numberOfMessages = fetchResult?.numberOfObjects ?? 0
    let messages = fetchResult?.objects
    let identifier = (messages?[numberOfMessages-indexPath.row] as? Message)?.isInput ?? false ? "InputMessageCell" : "OutputMessageCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageCell else {
      fatalError("Cell configuration is wrong")
    }
    cell.textMessage = (messages?[numberOfMessages-indexPath.row] as? Message)?.text
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
      view.frame.origin.y = -keyboardRect.height
    } else  if notification.name == UIResponder.keyboardWillHideNotification {
      view.frame.origin.y = 0
    }
  }
}

extension ConversationViewController: UserStateDelegate {
  func setOffline(userId: String) {
    if userId == self.title {
      self.sendButton.isEnabled = false
    }
  }
  func setOnline(userId: String) {
    if userId == self.title {
      self.sendButton.isEnabled = true
    }
  }
}
