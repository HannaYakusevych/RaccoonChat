//
//  inputMessageCell.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 25/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
  var textMessage: String? {get set}
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
  
  // MARK: - Outlets
  @IBOutlet var inputMessageLabel: UILabel!
  @IBOutlet var outputMessageLabel: UILabel!
  
  
  var textMessage: String? {
    get {
      return inputMessageLabel?.text ?? outputMessageLabel.text
    }
    set {
      if inputMessageLabel != nil {
        inputMessageLabel.text = newValue
      }
      else {
        outputMessageLabel.text = newValue
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
        // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
  }

}


