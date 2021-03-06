//
//  ConversationCell.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 24/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit
import Foundation

protocol ConversationCellConfiguration: class {
  var name: String? {get set}
  var message: String? {get set}
  var date: Date? {get set}
  var online: Bool {get set}
  var hasUnreadMessages: Bool {get set}
  var photo: UIImage? {get set}
}

class ConversationCell: UITableViewCell, ConversationCellConfiguration {

  // MARK: ConversationCellConfiguration conformance
  var name: String? {
    get {
      return nameLabel.text
    }
    set {
      nameLabel.text = newValue ?? "Name"
    }
  }

  var message: String? {
    get {
      return messageLabel.text == "No messages yet" ? nil : messageLabel.text
    }
    set {
      if newValue == nil {
        messageLabel.text = "No messages yet"
        messageLabel.font = UIFont.italicSystemFont(ofSize: messageLabel.font.pointSize)
      } else {
        messageLabel.text = newValue
        messageLabel.font = UIFont.systemFont(ofSize: 17)
      }
    }
  }

  var date: Date? {
    get {
      if dateLabel.text == nil {
        return nil
      }
      let dateFormatter = DateFormatter()
      return dateFormatter.date(from: dateLabel.text!)
    }
    set {
      let dateFormatter = DateFormatter()
      let calendar = Calendar.current

      if newValue == nil {
        dateLabel.text = nil
      } else {
        if calendar.isDateInToday(newValue!) {
          dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        } else {
          dateFormatter.setLocalizedDateFormatFromTemplate("dd MMM")
        }
        dateLabel.text = dateFormatter.string(from: newValue!)
      }
    }
  }

  var online: Bool {
    get {
      return self.backgroundColor != #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    set {
      self.backgroundColor = newValue ? ThemeManager.currentTheme().mainColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
  }

  var hasUnreadMessages: Bool {
    get {
      return messageLabel.font.fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    set {
      if message != nil {
        if newValue {
          messageLabel.font = UIFont.boldSystemFont(ofSize: messageLabel.font.pointSize)
        } else {
          messageLabel.font = UIFont.systemFont(ofSize: messageLabel.font.pointSize)
        }
      }
    }
  }

  var photo: UIImage? {
    get {
      return profileImageView.image
    }
    set {
      profileImageView.image = newValue ?? UIImage(named: "placeholder-user")
    }
  }

  // MARK: Outlets

  @IBOutlet var profileImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var messageLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
