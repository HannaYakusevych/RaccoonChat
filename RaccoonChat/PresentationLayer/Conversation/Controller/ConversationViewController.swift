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
  var isOnline: Bool = true
  var userId: String?

  var particleEmitter: ParticleEmitter!

  // It looks strange, but it is the easiest way I could find
  lazy var titleLabel = UILabel(frame: CGRect(x: (self.navigationController?.navigationBar.frame.width)!/4,
                                y: 0,
                                width: (self.navigationController?.navigationBar.frame.width)! / 2,
                                height: (self.navigationController?.navigationBar.frame.height)!))

  var contextManager: ContextManagerProtocol?
  var conversationListService: ConversationListServiceProtocol?
  var conversationDataManager: ConversationDataManagerProtocol?

  @IBAction func sendMessage(_ sender: Any) {
    // If the message is empty, don't send anything
    if newMessageTextView.text == "" {
      self.makeSendButtonUnenabled()
      return
    }
    RootAssembly.communicationManager.communicator.sendMessage(string: self.newMessageTextView.text, to: self.userId!) { isSent, error in
      if !isSent {
        Logger.write(error?.localizedDescription ?? "Message sending error: user is unknown")
        return
      }
      guard let user = self.conversationListService?.findOrInsertNewUser(userId: self.userId!) else {
        return
      }
      user.lastMessage = self.newMessageTextView.text
      user.lastMessageDate = Date()
      self.conversationListService?.insertNewMessage(text: self.newMessageTextView.text,
                                           to: self.userId!, isInput: false)
      self.contextManager?.performSave { _ in
        DispatchQueue.main.async {
          self.newMessageTextView.text = ""
          self.makeSendButtonUnenabled()
          self.conversationDataManager?.loadMessages()
        }
      }
    }
  }

  @IBAction func viewWasTapped(_ sender: UIGestureRecognizer) {
    let point = sender.location(in: self.tableView)
    print(self.tableView.frame.height - point.y)
    if sender.state == .began {
      self.particleEmitter.touchBegan(CGPoint(x: point.x, y: -self.tableView.frame.height/8 + point.y))
    } else if sender.state == .ended {
      self.particleEmitter.touchEnded(CGPoint(x: point.x, y: -self.tableView.frame.height/8 + point.y))
    } else if sender.state == .changed {
      self.particleEmitter.touchBegan(sender.location(in: self.view))
    } else {
      self.newMessageTextView.resignFirstResponder()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.userId = self.title
    self.title = ""
    self.titleLabel.textAlignment = .center
    self.titleLabel.text = self.userId
    self.titleLabel.font = UIFont.boldSystemFont(ofSize: (self.navigationController?.navigationBar.frame.height)! / 2.5)
    self.titleLabel.lineBreakMode = .byWordWrapping
    self.navigationItem.titleView = titleLabel

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
    self.conversationDataManager = ConversationDataManager(conversationID: self.userId!,
                                                             tableView: self.tableView,
                                                             context: mainContext)
    self.conversationDataManager?.loadMessages()

    RootAssembly.communicationManager.newMessageDelegate = self

    self.makeSendButtonUnenabled()
    if self.isOnline {
      self.titleLabel.textColor = UIColor(red: 51/255, green: 237/255, blue: 178/255, alpha: 1.0)
      self.titleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.11)
    }

    self.particleEmitter = ParticleEmitter()
    self.particleEmitter.frame = self.tableView.frame
    self.particleEmitter.isUserInteractionEnabled = false
    self.tableView.addSubview(particleEmitter)

    self.tableView.reloadData()
  }

  deinit {
    RootAssembly.communicationManager.newMessageDelegate = nil

    // UserStateDelegate
    if let numberOfVc = self.navigationController?.viewControllers.count,
      let parent = self.navigationController?.viewControllers[numberOfVc - 2] as? ConversationsListViewController {
      parent.userStateDelegate = nil
    }

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
    let identifier = (messages?[numberOfMessages - 1 - indexPath.row] as? Message)?.isInput ?? false ? "InputMessageCell" : "OutputMessageCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageCell else {
      fatalError("Cell configuration is wrong")
    }
    cell.textMessage = (messages?[numberOfMessages - 1 - indexPath.row] as? Message)?.text
    cell.sizeToFit()

    // To insert messages from bottom
    cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    return cell
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
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
    tableView.addGestureRecognizer(tapGesture)
  }

  // Resign keyboard if tapped on view
  @objc func handleTap() {
    if self.newMessageTextView.text.isEmpty {
      self.makeSendButtonUnenabled()
    }
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
      if self.isOnline {
        self.makeSendButtonEnabled()
      }
    } else  if notification.name == UIResponder.keyboardWillHideNotification {
      view.frame.origin.y = 0
      if self.newMessageTextView.text.isEmpty {
        self.makeSendButtonUnenabled()
      }
    }
  }
}

extension ConversationViewController: UserStateDelegate {

  func setOffline(userId: String) {
    if userId == self.userId {
      self.isOnline = false
      self.makeSendButtonUnenabled()
      UIView.transition(with: self.titleLabel, duration: 1, options: .transitionCrossDissolve, animations: {
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.transform = CGAffineTransform.identity
      }, completion: nil)
    }
  }
  func setOnline(userId: String) {
    if userId == self.userId {
      self.isOnline = true
      if !self.newMessageTextView.text.isEmpty {
        self.makeSendButtonEnabled()
      }
      UIView.transition(with: self.titleLabel, duration: 1, options: .transitionCrossDissolve, animations: {
        self.titleLabel.textColor = UIColor(red: 51/255, green: 237/255, blue: 178/255, alpha: 1.0)
        self.titleLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.11)
      }, completion: nil)
    }
  }
}

extension ConversationViewController: NewMessageDelegate {
  func reloadData() {
    self.conversationDataManager?.loadMessages()
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}

extension ConversationViewController {
  func changeSendButtonState() {
    self.sendButton.isEnabled = !self.sendButton.isEnabled
  }

  func makeSendButtonUnenabled() {
    Logger.write("Make button unenabled")
    if !self.sendButton.isEnabled {
      return
    }
    self.sendButton.isEnabled = false

    UIView.animate(withDuration: 0.5, delay: 0, animations: {
      self.sendButton.setTitleColor(UIColor.gray, for: .normal)
    }, completion: nil)
    UIView.animate(withDuration: 0.25, delay: 0, animations: {
      self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
    }, completion: { _ in
      UIView.animate(withDuration: 0.25) {
        self.sendButton.transform = CGAffineTransform.identity
      }
    })
  }
  func makeSendButtonEnabled() {
    Logger.write("Make button enabled")
    if self.sendButton.isEnabled {
      return
    }
    self.sendButton.isEnabled = true

    UIView.animate(withDuration: 0.5, delay: 0, animations: {
      self.sendButton.setTitleColor(UIColor.black, for: .normal)
    }, completion: nil)
    UIView.animate(withDuration: 0.25, delay: 0, animations: {
      self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
    }, completion: { _ in
      UIView.animate(withDuration: 0.25) {
        self.sendButton.transform = CGAffineTransform.identity
      }
    })
  }
}
