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
  @IBOutlet var inputMessageLabel: MyLabel!
  @IBOutlet var outputMessageLabel: MyLabel!
  
  
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
    let label = inputMessageLabel ?? outputMessageLabel!
    label.layer.borderWidth = 1
    label.layer.borderColor = UIColor.black.cgColor
    label.layer.cornerRadius = label.frame.height / 4
        // Initialization code
  }
  

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
  }

}

// MARK: - Customizing margins in labels
class MyLabel: UILabel{
  override func drawText(in rect: CGRect) {
    super.drawText(in: CGRect(x: bounds.origin.x + 5, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height))
  }
}


