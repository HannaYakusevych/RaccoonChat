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
    self.resignFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Listen for keyboard events
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    newMessageView.backgroundColor = ThemeManager.currentTheme().mainColor
    newMessageTextView.layer.cornerRadius = newMessageTextView.frame.height / 2
    sendButton.layer.cornerRadius = sendButton.frame.height / 2
    
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
    return messages?.count ?? 0
  }
  var messages: [Message]!
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let numberOfMessages = messages.count - 1
    let identifier = messages[numberOfMessages-indexPath.row].isInput ? "InputMessageCell" : "OutputMessageCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
    cell.textMessage = messages[numberOfMessages-indexPath.row].text
    cell.sizeToFit()

    // To insert messages from bottom
    cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    return cell
  }
  
  
  
  // MARK: - Table view delegate
  /*
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UILabel(frame: CGRect(x: 16, y: 16, width: 100, height: 100))
    header.text = "Name"
    header.textAlignment = .center
    header.font = UIFont.boldSystemFont(ofSize: 20)
    header.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
    return header
  }
 */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
  
  @objc func handleTap() {
    view.endEditing(true)
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
